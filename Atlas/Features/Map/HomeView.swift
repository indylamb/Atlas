import SwiftUI
import MapKit

/// The home screen: one map with your spots, friends' spots and Apple Maps places no one saved.
struct HomeView: View {
    @Environment(AtlasStore.self) private var store
    @State private var model = HomeModel()
    @State private var position: MapCameraPosition = .region(.williamsburg)
    @State private var selectedFeature: MapFeature?

    var body: some View {
        ZStack(alignment: .top) {
            map
            if model.mode == .sending {
                ShareFrame(count: sendablePlaceIDs.count)
            }
            TopControls(model: model, sendIDs: sendablePlaceIDs, receivedCount: receivedIDs.count, saveAll: saveAllReceived)
            if let toast = model.toast {
                ToastView(message: toast)
                    .padding(.top, 176)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.2), value: model.toast)
        .sheet(item: $model.sheet) { sheet in
            switch sheet {
            case .spot:
                SpotSheet(model: model)
                    .presentationDetents([.fraction(Theme.Size.spotDetent), .large])
                    .presentationBackgroundInteraction(.enabled(upThrough: .fraction(Theme.Size.spotDetent)))
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(Theme.Radius.lg)
            case .sendTo:
                SendToSheet(model: model)
                    .presentationDetents([.large])
                    .presentationCornerRadius(Theme.Radius.lg)
            case .receivedList:
                ReceivedListSheet(model: model, placeIDs: receivedIDs, saveAll: saveAllReceived)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(Theme.Radius.lg)
            }
        }
        .onChange(of: selectedFeature) { _, feature in
            guard let feature else { return }
            openFeature(feature)
        }
        .onChange(of: model.mode) { _, mode in
            if case .receiving(let id) = mode, let map = store.incoming.first(where: { $0.id == id }) {
                frame(placeIDs: map.placeIDs)
            }
        }
    }

    // MARK: Map

    private var map: some View {
        Map(position: $position, selection: $selectedFeature) {
            UserAnnotation()
            ForEach(pins) { pin in
                Annotation(store.place(pin.placeID)?.name ?? "", coordinate: pin.coordinate, anchor: .center) {
                    PinView(store: store, pin: pin, isSelected: model.sheet == .spot && model.selectedPlaceID == pin.placeID)
                        .onTapGesture { model.openSpot(pin.placeID) }
                }
                .annotationTitles(.hidden)
            }
        }
        .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: pointsOfInterest, showsTraffic: false))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .onMapCameraChange(frequency: .continuous) { context in
            model.visibleRegion = context.region
        }
    }

    private var pins: [AtlasPin] {
        if let map = receivingMap {
            return MapFilter.receivedPins(store: store, map: map, filter: model.filter)
        }
        return MapFilter.pins(store: store, filter: model.filter, sending: model.mode == .sending)
    }

    /// Apple Maps places show as quiet "unsaved" spots while browsing everyone's map.
    private var pointsOfInterest: PointOfInterestCategories {
        guard model.mode == .browsing, model.filter.showUnsaved, model.filter.who == .everyone else { return .excludingAll }
        return .including([.restaurant, .cafe, .bakery, .museum, .park, .nightlife, .brewery, .winery, .theater])
    }

    // MARK: Sending and receiving

    private var receivingMap: IncomingMap? {
        guard let id = model.receivingMapID else { return nil }
        return store.incoming.first { $0.id == id }
    }

    private var receivedIDs: [String] {
        guard let map = receivingMap else { return [] }
        return MapFilter.receivedPlaceIDs(store: store, map: map, filter: model.filter)
    }

    /// Your visible spots inside the frame.
    private var sendablePlaceIDs: [String] {
        guard let region = model.visibleRegion else { return [] }
        return pins
            .filter { $0.dots.contains(where: \.isMe) && region.contains($0.coordinate) }
            .map(\.placeID)
    }

    private func saveAllReceived() {
        guard let map = receivingMap else { return }
        let count = store.saveAll(receivedIDs)
        let name = store.person(map.fromID)?.name ?? "your friend"
        model.finishReceiving(message: "Saved \(count) new spots from \(name). To see only theirs, open Filters and choose \(name) under Saved by.")
    }

    private func frame(placeIDs: [String]) {
        let coordinates = placeIDs.compactMap { store.place($0)?.coordinate }
        guard !coordinates.isEmpty else { return }
        withAnimation { position = .region(.fitting(coordinates)) }
    }

    // MARK: Apple Maps places

    private func openFeature(_ feature: MapFeature) {
        let category = PlaceCategory(poi: feature.pointOfInterestCategory)
        let place = store.addPlace(Place(
            id: "apple-\(UUID().uuidString)",
            name: feature.title ?? "Place",
            detail: category.displayName,
            category: category,
            latitude: feature.coordinate.latitude,
            longitude: feature.coordinate.longitude,
            tags: category.defaultTags
        ))
        selectedFeature = nil
        model.openSpot(place.id)
    }
}

// MARK: - Helpers

extension MKCoordinateRegion {
    static let williamsburg = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7160, longitude: -73.9700),
        span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)
    )

    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        abs(coordinate.latitude - center.latitude) <= span.latitudeDelta / 2 &&
        abs(coordinate.longitude - center.longitude) <= span.longitudeDelta / 2
    }

    /// A region that fits every coordinate with some padding.
    static func fitting(_ coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        let lats = coordinates.map(\.latitude), lons = coordinates.map(\.longitude)
        let minLat = lats.min() ?? 0, maxLat = lats.max() ?? 0, minLon = lons.min() ?? 0, maxLon = lons.max() ?? 0
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2),
            span: MKCoordinateSpan(latitudeDelta: max(0.01, (maxLat - minLat) * 1.8), longitudeDelta: max(0.01, (maxLon - minLon) * 1.8))
        )
    }
}

extension PlaceCategory {
    init(poi: MKPointOfInterestCategory?) {
        guard let poi else { self = .other; return }
        switch poi {
        case .restaurant, .bakery, .foodMarket: self = .dinner
        case .cafe: self = .coffee
        case .museum, .theater: self = .museum
        case .park, .nationalPark, .beach: self = .park
        case .nightlife, .brewery, .winery: self = .bar
        default: self = .other
        }
    }

    var displayName: String {
        switch self {
        case .dinner: return "Restaurant"
        case .coffee: return "Café"
        case .museum: return "Museum"
        case .park: return "Park"
        case .bar: return "Bar"
        case .other: return "Place"
        }
    }

    var defaultTags: [String] {
        switch self {
        case .dinner: return ["Dinner"]
        case .coffee: return ["Coffee"]
        case .museum: return ["Museums"]
        case .park: return ["Parks"]
        case .bar: return ["Bars"]
        case .other: return []
        }
    }
}
