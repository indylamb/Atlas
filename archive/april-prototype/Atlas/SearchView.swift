import SwiftUI
import MapKit

struct SearchView: View {
    @EnvironmentObject var spotManager: SpotManager
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var searchManager = PlaceSearchManager()

    @Binding var isPresented: Bool
    var onSelectPlace: (PlaceResult) -> Void

    @State private var query = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            SheetHandle()

            // Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(Color.Atlas.textSecondary)

                TextField("Search places...", text: $query)
                    .font(AtlasFont.body())
                    .foregroundStyle(Color.Atlas.textPrimary)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        searchManager.search(query: query, region: locationManager.region)
                    }
                    .onChange(of: query) { _, new in
                        searchManager.search(query: new, region: locationManager.region)
                    }

                if !query.isEmpty {
                    Button {
                        query = ""
                        searchManager.clear()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.Atlas.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(Color.Atlas.secondaryBg)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)

            Divider().opacity(0.5)

            if searchManager.isSearching {
                // Loading state
                HStack(spacing: 10) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Searching...")
                        .font(AtlasFont.caption())
                        .foregroundStyle(Color.Atlas.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(24)
            } else if searchManager.results.isEmpty && !query.isEmpty {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "mappin.slash")
                        .font(.system(size: 28, weight: .thin))
                        .foregroundStyle(Color.Atlas.textTertiary)
                    Text("No places found")
                        .font(AtlasFont.body())
                        .foregroundStyle(Color.Atlas.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(32)
            } else if searchManager.results.isEmpty && query.isEmpty {
                // Hint state
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent")
                        .font(AtlasFont.caption())
                        .foregroundStyle(Color.Atlas.textTertiary)
                        .padding(.horizontal, 16)
                    ForEach(spotManager.spots.prefix(3)) { spot in
                        RecentSpotRow(spot: spot)
                    }
                }
                .padding(.top, 16)
            } else {
                // Results
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(searchManager.results) { place in
                            SearchResultRow(place: place)
                                .onTapGesture {
                                    HapticsHelper.light()
                                    onSelectPlace(place)
                                    isPresented = false
                                }
                            Divider()
                                .padding(.leading, 56)
                                .opacity(0.5)
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .background(Color.Atlas.background)
        .onAppear { isFocused = true }
    }
}

// MARK: - Search Result Row

struct SearchResultRow: View {
    let place: PlaceResult

    var body: some View {
        HStack(spacing: 12) {
            CategoryBadge(category: place.category, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(place.name)
                    .font(AtlasFont.body())
                    .foregroundStyle(Color.Atlas.textPrimary)
                    .lineLimit(1)
                Text(place.address)
                    .font(AtlasFont.caption())
                    .foregroundStyle(Color.Atlas.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .light))
                .foregroundStyle(Color.Atlas.textTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Recent Spot Row

struct RecentSpotRow: View {
    let spot: Spot

    var body: some View {
        HStack(spacing: 12) {
            CategoryBadge(category: spot.category, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(spot.name)
                    .font(AtlasFont.body())
                    .foregroundStyle(Color.Atlas.textPrimary)
                    .lineLimit(1)
                Text(spot.address)
                    .font(AtlasFont.caption())
                    .foregroundStyle(Color.Atlas.textSecondary)
                    .lineLimit(1)
            }
            Spacer()

            Image(systemName: "clock")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(Color.Atlas.textTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
