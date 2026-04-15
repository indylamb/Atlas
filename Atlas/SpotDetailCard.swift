import SwiftUI
import MapKit

// MARK: - Spot Detail Card (shown when a saved spot is tapped)

struct SpotDetailCard: View {
    let spot: Spot
    var onDismiss: () -> Void
    var onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Handle + dismiss
            HStack {
                SheetHandle()
                    .frame(maxWidth: .infinity)
            }

            HStack(alignment: .top, spacing: 12) {
                CategoryBadge(category: spot.category, size: 40)

                VStack(alignment: .leading, spacing: 3) {
                    Text(spot.name)
                        .font(AtlasFont.title(18))
                        .foregroundStyle(Color.Atlas.textPrimary)
                    Text(spot.address)
                        .font(AtlasFont.caption())
                        .foregroundStyle(Color.Atlas.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.Atlas.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(Color.Atlas.secondaryBg)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            Divider().opacity(0.4).padding(.horizontal, 16)

            // Stats row
            HStack(spacing: 20) {
                if let rating = spot.googleRating, let count = spot.googleReviewCount {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Google")
                            .font(AtlasFont.caption(10))
                            .foregroundStyle(Color.Atlas.textTertiary)
                        GoogleRatingView(rating: rating, reviewCount: count)
                    }
                }

                if let userRating = spot.userRating {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your rating")
                            .font(AtlasFont.caption(10))
                            .foregroundStyle(Color.Atlas.textTertiary)
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { i in
                                Image(systemName: i <= userRating ? "star.fill" : "star")
                                    .font(.system(size: 10, weight: .regular))
                                    .foregroundStyle(i <= userRating ? Color(hex: "#F5A623") : Color.Atlas.textTertiary)
                            }
                        }
                    }
                }

                if let price = spot.priceLevel {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Price")
                            .font(AtlasFont.caption(10))
                            .foregroundStyle(Color.Atlas.textTertiary)
                        Text(spot.priceLevelString)
                            .font(AtlasFont.label(12))
                            .foregroundStyle(Color.Atlas.textSecondary)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Tags
            if !spot.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(spot.tags) { tag in
                            AtlasPill(text: tag.name, color: tag.color, isSelected: true)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }
            }

            // Notes
            if !spot.notes.isEmpty {
                Text(spot.notes)
                    .font(AtlasFont.caption())
                    .foregroundStyle(Color.Atlas.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .lineLimit(2)
            }

            // Action buttons
            HStack(spacing: 12) {
                Button(action: openInMaps) {
                    Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond")
                        .font(AtlasFont.label(13))
                }
                .buttonStyle(AtlasSecondaryButtonStyle())

                Spacer()

                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                        .font(AtlasFont.label(13))
                }
                .buttonStyle(AtlasSecondaryButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
        .background(Color.Atlas.background)
    }

    private func openInMaps() {
        let coord = spot.coordinate2D
        let item = MKMapItem(placemark: MKPlacemark(coordinate: coord))
        item.name = spot.name
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

// MARK: - Place Preview Card (shown after searching, before saving)

struct PlacePreviewCard: View {
    let place: PlaceResult
    var alreadySaved: Bool
    var onSave: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SheetHandle().frame(maxWidth: .infinity)

            HStack(alignment: .top, spacing: 12) {
                CategoryBadge(category: place.category, size: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text(place.name)
                        .font(AtlasFont.title(18))
                        .foregroundStyle(Color.Atlas.textPrimary)
                    Text(place.address)
                        .font(AtlasFont.caption())
                        .foregroundStyle(Color.Atlas.textSecondary)
                        .lineLimit(2)

                    if let r = place.googleRating, let c = place.googleReviewCount {
                        GoogleRatingView(rating: r, reviewCount: c)
                            .padding(.top, 2)
                    }
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.Atlas.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(Color.Atlas.secondaryBg)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)

            // Price level
            if let price = place.priceLevel {
                HStack(spacing: 6) {
                    Text(String(repeating: "$", count: price))
                        .font(AtlasFont.label(13))
                        .foregroundStyle(Color.Atlas.textSecondary)

                    Text(place.category.displayName)
                        .font(AtlasFont.caption())
                        .foregroundStyle(Color.Atlas.textTertiary)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }

            Divider().opacity(0.4).padding(.horizontal, 16)

            // CTA
            HStack(spacing: 12) {
                if alreadySaved {
                    Label("Already saved", systemImage: "checkmark.circle.fill")
                        .font(AtlasFont.label(14))
                        .foregroundStyle(Color.Atlas.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                } else {
                    Button(action: onSave) {
                        Label("Save to Atlas", systemImage: "plus.circle.fill")
                            .font(AtlasFont.label(14))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.Atlas.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.Atlas.background)
    }
}

// MARK: - Button Styles

struct AtlasSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.Atlas.blue)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Color.Atlas.blueLight)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
