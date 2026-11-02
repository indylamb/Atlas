import SwiftUI
import MapKit

struct ContentView: View {
    @EnvironmentObject var spotManager: SpotManager
    @EnvironmentObject var locationManager: LocationManager

    // Sheet states
    @State private var showSearch = false
    @State private var showFilter = false
    @State private var showSaveSpot = false

    // Selected spot (saved pin tapped)
    @State private var selectedSpot: Spot? = nil

    // Place from search (before saving)
    @State private var previewPlace: PlaceResult? = nil
    @State private var showPlacePreview = false

    // Edit mode
    @State private var editingSpot: Spot? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            // MAP
            MapContainerView(
                selectedSpot: $selectedSpot,
                showSearch: $showSearch,
                showFilter: $showFilter
            )
            .ignoresSafeArea()
            .onTapGesture {
                // Deselect when tapping map
                withAnimation(.spring(response: 0.3)) {
                    selectedSpot = nil
                }
            }

            // BOTTOM STACK
            VStack(spacing: 0) {
                // Saved spot detail card (slides up when pin selected)
                if let spot = selectedSpot {
                    SpotDetailCard(
                        spot: spot,
                        onDismiss: {
                            withAnimation(.spring(response: 0.35)) { selectedSpot = nil }
                        },
                        onEdit: {
                            editingSpot = spot
                            // Build a PlaceResult from the spot to reuse SaveSpotView
                            previewPlace = PlaceResult(
                                id: spot.googlePlaceId ?? spot.id.uuidString,
                                name: spot.name,
                                address: spot.address,
                                coordinate: spot.coordinate2D,
                                category: spot.category,
                                googleRating: spot.googleRating,
                                googleReviewCount: spot.googleReviewCount,
                                priceLevel: spot.priceLevel,
                                phoneNumber: spot.phoneNumber,
                                website: spot.website,
                                suggestedTags: []
                            )
                            showSaveSpot = true
                        }
                    )
                    .floatingCard()
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // BOTTOM TOOLBAR
                BottomToolbar(
                    onSearch: { showSearch = true },
                    onFilter: { showFilter = true },
                    onLocate: { locationManager.centerOnUser() },
                    activeFilterCount: spotManager.activeFilters.count
                )
                .padding(.bottom, 32)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedSpot?.id)
        }
        // SEARCH SHEET
        .sheet(isPresented: $showSearch) {
            SearchView(isPresented: $showSearch) { place in
                previewPlace = place
                editingSpot = nil
                showPlacePreview = true
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(24)
        }
        // FILTER SHEET
        .sheet(isPresented: $showFilter) {
            FilterView(onDismiss: { showFilter = false })
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(24)
        }
        // PLACE PREVIEW SHEET (after search result selected)
        .sheet(isPresented: $showPlacePreview) {
            if let place = previewPlace {
                let alreadySaved = spotManager.spots.contains {
                    $0.name == place.name && $0.address == place.address
                }
                PlacePreviewCard(
                    place: place,
                    alreadySaved: alreadySaved,
                    onSave: {
                        showPlacePreview = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            showSaveSpot = true
                        }
                    },
                    onDismiss: { showPlacePreview = false }
                )
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(24)
            }
        }
        // SAVE SPOT SHEET
        .sheet(isPresented: $showSaveSpot) {
            if let place = previewPlace {
                SaveSpotView(
                    place: place,
                    existingSpot: editingSpot,
                    onSave: { spot in
                        spotManager.save(spot: spot)
                        showSaveSpot = false
                        selectedSpot = nil
                        editingSpot = nil
                    },
                    onDismiss: { showSaveSpot = false }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(24)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SpotManager())
        .environmentObject(LocationManager())
}
