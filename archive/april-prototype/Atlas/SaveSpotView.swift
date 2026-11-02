import SwiftUI

struct SaveSpotView: View {
    @EnvironmentObject var spotManager: SpotManager

    let place: PlaceResult
    var existingSpot: Spot? = nil
    var onSave: (Spot) -> Void
    var onDismiss: () -> Void

    // Form state
    @State private var selectedCategory: SpotCategory
    @State private var userRating: Int = 0
    @State private var selectedTags: [Tag] = []
    @State private var notes: String = ""
    @State private var tagQuery: String = ""
    @State private var showCategoryPicker = false
    @FocusState private var tagFieldFocused: Bool

    init(place: PlaceResult, existingSpot: Spot? = nil,
         onSave: @escaping (Spot) -> Void, onDismiss: @escaping () -> Void) {
        self.place = place
        self.existingSpot = existingSpot
        self.onSave = onSave
        self.onDismiss = onDismiss
        _selectedCategory = State(initialValue: existingSpot?.category ?? place.category)
        _userRating = State(initialValue: existingSpot?.userRating ?? 0)
        _selectedTags = State(initialValue: existingSpot?.tags ?? [])
        _notes = State(initialValue: existingSpot?.notes ?? "")
    }

    var suggestedTags: [Tag] {
        let query = tagQuery.trimmingCharacters(in: .whitespaces)
        if query.isEmpty {
            return spotManager.suggestedTags(for: selectedCategory)
                .filter { t in !selectedTags.contains(where: { $0.id == t.id }) }
        } else {
            return spotManager.tagSuggestions(matching: query)
                .filter { t in !selectedTags.contains(where: { $0.id == t.id }) }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.Atlas.textSecondary)
                        .frame(width: 30, height: 30)
                        .background(Color.Atlas.secondaryBg)
                        .clipShape(Circle())
                }

                Spacer()

                Text(existingSpot == nil ? "Save Spot" : "Edit Spot")
                    .font(AtlasFont.label(15))
                    .foregroundStyle(Color.Atlas.textPrimary)

                Spacer()

                Button("Save") {
                    commitSave()
                }
                .font(AtlasFont.label(15))
                .foregroundStyle(userRating > 0 ? Color.Atlas.blue : Color.Atlas.textTertiary)
                .disabled(userRating == 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 4)

            SheetHandle().frame(maxWidth: .infinity)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Place summary
                    HStack(spacing: 12) {
                        CategoryBadge(category: selectedCategory, size: 44)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(place.name)
                                .font(AtlasFont.title(17))
                                .foregroundStyle(Color.Atlas.textPrimary)
                            Text(place.address)
                                .font(AtlasFont.caption())
                                .foregroundStyle(Color.Atlas.textSecondary)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    // Rating
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel("Your rating")
                        StarRatingView(rating: $userRating, size: 28)
                            .padding(.horizontal, 16)
                    }

                    // Category picker
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel("Category")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(SpotCategory.allCases) { cat in
                                    CategoryChip(category: cat, isSelected: selectedCategory == cat)
                                        .onTapGesture {
                                            HapticsHelper.light()
                                            selectedCategory = cat
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }

                    // Tags
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel("Tags")

                        // Selected tags
                        if !selectedTags.isEmpty {
                            FlowLayout(spacing: 6) {
                                ForEach(selectedTags) { tag in
                                    HStack(spacing: 4) {
                                        Text(tag.name)
                                            .font(AtlasFont.tag())
                                        Button {
                                            selectedTags.removeAll { $0.id == tag.id }
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 9, weight: .semibold))
                                        }
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(tag.color))
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // Tag input
                        HStack(spacing: 8) {
                            Image(systemName: "tag")
                                .font(.system(size: 13, weight: .light))
                                .foregroundStyle(Color.Atlas.textTertiary)

                            TextField("Add a tag...", text: $tagQuery)
                                .font(AtlasFont.body(14))
                                .focused($tagFieldFocused)
                                .submitLabel(.done)
                                .onSubmit { createCustomTag() }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.Atlas.secondaryBg)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(.horizontal, 16)

                        // Suggestions
                        if !suggestedTags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(suggestedTags) { tag in
                                        Button {
                                            HapticsHelper.light()
                                            selectedTags.append(tag)
                                            tagQuery = ""
                                        } label: {
                                            AtlasPill(text: tag.name, color: tag.color)
                                        }
                                    }

                                    // Create new if no exact match
                                    if !tagQuery.isEmpty && !suggestedTags.contains(where: { $0.name.lowercased() == tagQuery.lowercased() }) {
                                        Button { createCustomTag() } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: "plus")
                                                    .font(.system(size: 10, weight: .medium))
                                                Text("Create "\(tagQuery)"")
                                            }
                                            .font(AtlasFont.tag())
                                            .foregroundStyle(Color.Atlas.blue)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Capsule().strokeBorder(Color.Atlas.blue.opacity(0.4), lineWidth: 1))
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel("Notes  (optional)")
                        TextField("Add a note...", text: $notes, axis: .vertical)
                            .font(AtlasFont.body(14))
                            .lineLimit(3...6)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.Atlas.secondaryBg)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 100)
                }
                .padding(.top, 16)
            }
        }
        .background(Color.Atlas.background)
    }

    private func createCustomTag() {
        let name = tagQuery.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let colors = ["#FF6B6B", "#3498DB", "#27AE60", "#9B59B6", "#F39C12", "#E91E8C", "#00BCD4"]
        let hex = colors.randomElement()!
        let tag = Tag(name: name, colorHex: hex)
        spotManager.addCustomTag(tag)
        selectedTags.append(tag)
        tagQuery = ""
        HapticsHelper.light()
    }

    private func commitSave() {
        let spot = Spot(
            id: existingSpot?.id ?? UUID(),
            name: place.name,
            address: place.address,
            coordinate: SpotCoordinate(latitude: place.coordinate.latitude,
                                       longitude: place.coordinate.longitude),
            category: selectedCategory,
            googlePlaceId: place.id,
            phoneNumber: place.phoneNumber,
            website: place.website,
            googleRating: place.googleRating,
            googleReviewCount: place.googleReviewCount,
            priceLevel: place.priceLevel,
            userRating: userRating,
            tags: selectedTags,
            notes: notes
        )
        onSave(spot)
    }
}

// MARK: - Helpers

private struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .medium, design: .default))
            .foregroundStyle(Color.Atlas.textTertiary)
            .tracking(0.8)
            .padding(.horizontal, 16)
    }
}

private struct CategoryChip: View {
    let category: SpotCategory
    let isSelected: Bool
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: category.symbolName)
                .font(.system(size: 12, weight: .regular))
            Text(category.displayName)
                .font(AtlasFont.tag(12))
        }
        .foregroundStyle(isSelected ? .white : category.color)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(isSelected ? category.color : category.color.opacity(0.12))
        )
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width,
                                subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: frame.minX + bounds.minX,
                                              y: frame.minY + bounds.minY),
                                  proposal: ProposedViewSize(frame.size))
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth, x > 0 {
                    x = 0; y += rowHeight + spacing; rowHeight = 0
                }
                frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}
