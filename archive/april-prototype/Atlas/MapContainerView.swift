import SwiftUI
import MapKit

struct MapContainerView: View {
    @EnvironmentObject var spotManager: SpotManager
    @EnvironmentObject var locationManager: LocationManager

    @Binding var selectedSpot: Spot?
    @Binding var showSearch: Bool
    @Binding var showFilter: Bool

    @State private var mapPosition: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $mapPosition) {
            // User location
            UserAnnotation()

            // Saved spots
            ForEach(spotManager.filteredSpots) { spot in
                Annotation(spot.name, coordinate: spot.coordinate2D) {
                    SpotAnnotationView(spot: spot, isSelected: selectedSpot?.id == spot.id)
                        .onTapGesture {
                            HapticsHelper.light()
                            withAnimation(.spring(response: 0.35)) {
                                selectedSpot = spot
                            }
                        }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic, emphasis: .muted, pointsOfInterest: .excluding([])))
        .mapControls {
            MapCompass()
                .mapControlVisibility(.hidden)
        }
        .onAppear {
            if let coord = locationManager.userLocation?.coordinate {
                mapPosition = .region(MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                ))
            }
        }
        .onChange(of: locationManager.region) { _, newRegion in
            withAnimation(.easeInOut(duration: 0.5)) {
                mapPosition = .region(newRegion)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Annotation View

struct SpotAnnotationView: View {
    let spot: Spot
    var isSelected: Bool

    @State private var appear = false

    var body: some View {
        ZStack {
            // Drop shadow layer
            Circle()
                .fill(spot.category.color.opacity(0.25))
                .frame(width: isSelected ? 56 : 44, height: isSelected ? 56 : 44)
                .blur(radius: 6)
                .offset(y: 3)

            // Main pin
            ZStack {
                Circle()
                    .fill(isSelected ? spot.category.color : Color.Atlas.background)
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .overlay(
                        Circle()
                            .strokeBorder(spot.category.color, lineWidth: isSelected ? 0 : 1.5)
                    )
                Image(systemName: spot.category.symbolName)
                    .font(.system(size: isSelected ? 18 : 14, weight: .regular))
                    .foregroundStyle(isSelected ? .white : spot.category.color)
            }

            // Tiny stem
            Triangle()
                .fill(isSelected ? spot.category.color : Color.Atlas.background)
                .frame(width: 8, height: 6)
                .offset(y: isSelected ? 25 : 21)
        }
        .scaleEffect(appear ? 1 : 0.3)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: appear)
        .animation(.spring(response: 0.3), value: isSelected)
        .onAppear { appear = true }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.closeSubpath()
        }
    }
}
