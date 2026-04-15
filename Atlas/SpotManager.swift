import Foundation
import MapKit
import Combine

@MainActor
final class SpotManager: ObservableObject {
    @Published var spots: [Spot] = []
    @Published var customTags: [Tag] = []
    @Published var activeFilters: Set<UUID> = []   // tag IDs

    private let spotsKey = "atlas_spots"
    private let tagsKey  = "atlas_custom_tags"

    init() {
        loadFromDisk()
        if spots.isEmpty { loadSampleData() }
    }

    // MARK: - Filtered spots

    var filteredSpots: [Spot] {
        guard !activeFilters.isEmpty else { return spots }
        return spots.filter { spot in
            spot.tags.contains { activeFilters.contains($0.id) }
        }
    }

    // MARK: - All available tags (presets + custom)

    var allTags: [Tag] {
        var all = Tag.presets
        all.append(contentsOf: customTags)
        return all
    }

    // MARK: - CRUD

    func save(spot: Spot) {
        if let idx = spots.firstIndex(where: { $0.id == spot.id }) {
            spots[idx] = spot
        } else {
            spots.insert(spot, at: 0)
        }
        HapticsHelper.success()
        saveToDisk()
    }

    func delete(spot: Spot) {
        spots.removeAll { $0.id == spot.id }
        saveToDisk()
    }

    func addCustomTag(_ tag: Tag) {
        customTags.append(tag)
        saveToDisk()
    }

    func updateCustomTag(_ tag: Tag) {
        if let idx = customTags.firstIndex(where: { $0.id == tag.id }) {
            customTags[idx] = tag
        }
        saveToDisk()
    }

    // MARK: - Filter helpers

    func toggleFilter(_ tagId: UUID) {
        if activeFilters.contains(tagId) {
            activeFilters.remove(tagId)
        } else {
            activeFilters.insert(tagId)
        }
    }

    func clearFilters() { activeFilters.removeAll() }

    // MARK: - Suggestions

    func suggestedTags(for category: SpotCategory) -> [Tag] {
        switch category {
        case .restaurant:
            return allTags.filter { ["date night", "group", "casual", "upscale", "brunch"].contains($0.name) }
        case .cafe:
            return allTags.filter { ["solo", "cozy", "work friendly", "casual"].contains($0.name) }
        case .bar:
            return allTags.filter { ["date night", "group", "lively", "late night"].contains($0.name) }
        case .park:
            return allTags.filter { ["outdoor", "dog friendly", "kid friendly", "solo"].contains($0.name) }
        case .music:
            return allTags.filter { ["group", "date night", "lively", "late night"].contains($0.name) }
        default:
            return allTags.prefix(4).map { $0 }
        }
    }

    func tagSuggestions(matching query: String) -> [Tag] {
        guard !query.isEmpty else { return [] }
        let q = query.lowercased()
        return allTags.filter { $0.name.lowercased().hasPrefix(q) }
    }

    // MARK: - Persistence

    private func saveToDisk() {
        if let data = try? JSONEncoder().encode(spots) {
            UserDefaults.standard.set(data, forKey: spotsKey)
        }
        if let data = try? JSONEncoder().encode(customTags) {
            UserDefaults.standard.set(data, forKey: tagsKey)
        }
    }

    private func loadFromDisk() {
        if let data = UserDefaults.standard.data(forKey: spotsKey),
           let decoded = try? JSONDecoder().decode([Spot].self, from: data) {
            spots = decoded
        }
        if let data = UserDefaults.standard.data(forKey: tagsKey),
           let decoded = try? JSONDecoder().decode([Tag].self, from: data) {
            customTags = decoded
        }
    }

    // MARK: - Sample data

    private func loadSampleData() {
        spots = [
            Spot(name: "Eleven Madison Park",
                 address: "11 Madison Ave, New York, NY",
                 coordinate: SpotCoordinate(latitude: 40.7416, longitude: -73.9874),
                 category: .restaurant,
                 googleRating: 4.6, googleReviewCount: 3421, priceLevel: 4,
                 userRating: 5,
                 tags: [Tag.presets[0], Tag.presets[11]],
                 notes: "Incredible tasting menu. Book months ahead."),
            Spot(name: "Café Integral",
                 address: "149 Elizabeth St, New York, NY",
                 coordinate: SpotCoordinate(latitude: 40.7218, longitude: -73.9951),
                 category: .cafe,
                 googleRating: 4.4, googleReviewCount: 892, priceLevel: 2,
                 userRating: 4,
                 tags: [Tag.presets[1], Tag.presets[4], Tag.presets[14]],
                 notes: "Best cortado in the city. Very cozy."),
            Spot(name: "Death & Co",
                 address: "433 E 6th St, New York, NY",
                 coordinate: SpotCoordinate(latitude: 40.7261, longitude: -73.9836),
                 category: .bar,
                 googleRating: 4.5, googleReviewCount: 2103, priceLevel: 3,
                 userRating: 5,
                 tags: [Tag.presets[0], Tag.presets[5], Tag.presets[9]],
                 notes: "Outstanding cocktails. Get there early."),
            Spot(name: "The High Line",
                 address: "New York, NY 10011",
                 coordinate: SpotCoordinate(latitude: 40.7480, longitude: -74.0048),
                 category: .park,
                 googleRating: 4.7, googleReviewCount: 89241, priceLevel: 1,
                 userRating: 4,
                 tags: [Tag.presets[3], Tag.presets[1]],
                 notes: "Walk north to south for the best light."),
            Spot(name: "Music Hall of Williamsburg",
                 address: "66 N 6th St, Brooklyn, NY",
                 coordinate: SpotCoordinate(latitude: 40.7172, longitude: -73.9614),
                 category: .music,
                 googleRating: 4.4, googleReviewCount: 1752, priceLevel: 2,
                 userRating: 5,
                 tags: [Tag.presets[2], Tag.presets[5], Tag.presets[9]],
                 notes: "Perfect mid-size venue. Great sound."),
        ]
    }
}

// MARK: - Place Search (MapKit local search)

@MainActor
final class PlaceSearchManager: ObservableObject {
    @Published var results: [PlaceResult] = []
    @Published var isSearching: Bool = false

    private var searchTask: Task<Void, Never>?

    func search(query: String, region: MKCoordinateRegion) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }
        searchTask?.cancel()
        searchTask = Task {
            isSearching = true
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = region
            do {
                let search = MKLocalSearch(request: request)
                let response = try await search.start()
                guard !Task.isCancelled else { return }
                results = response.mapItems.map { item in
                    PlaceResult(
                        id: item.placemark.description,
                        name: item.name ?? "Unknown",
                        address: [item.placemark.thoroughfare,
                                  item.placemark.locality]
                            .compactMap { $0 }.joined(separator: ", "),
                        coordinate: item.placemark.coordinate,
                        category: category(for: item),
                        googleRating: nil,
                        googleReviewCount: nil,
                        priceLevel: nil,
                        phoneNumber: item.phoneNumber,
                        website: item.url?.absoluteString,
                        suggestedTags: []
                    )
                }
            } catch {
                if !Task.isCancelled { results = [] }
            }
            isSearching = false
        }
    }

    func clear() {
        searchTask?.cancel()
        results = []
        isSearching = false
    }

    private func category(for item: MKMapItem) -> SpotCategory {
        let cats = item.pointOfInterestCategory
        switch cats {
        case .restaurant, .bakery, .brewery, .foodMarket:
            return .restaurant
        case .cafe:
            return .cafe
        case .nightlife, .winery:
            return .bar
        case .park, .nationalPark:
            return .park
        case .museum, .library:
            return .museum
        case .hotel:
            return .hotel
        case .fitnessCenter, .gym:
            return .fitness
        case .beach:
            return .beach
        default:
            return .other
        }
    }
}
