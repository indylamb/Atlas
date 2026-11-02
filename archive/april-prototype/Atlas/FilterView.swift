import SwiftUI

struct FilterView: View {
    @EnvironmentObject var spotManager: SpotManager
    var onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Filter")
                    .font(AtlasFont.title(18))
                    .foregroundStyle(Color.Atlas.textPrimary)

                Spacer()

                if !spotManager.activeFilters.isEmpty {
                    Button("Clear") {
                        HapticsHelper.light()
                        spotManager.clearFilters()
                    }
                    .font(AtlasFont.label(14))
                    .foregroundStyle(Color.Atlas.blue)
                }

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
            .padding(.top, 16)
            .padding(.bottom, 4)

            SheetHandle().frame(maxWidth: .infinity)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Categories section
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader("Category")

                        FlowLayout(spacing: 8) {
                            ForEach(SpotCategory.allCases) { cat in
                                // Only show categories with spots
                                let count = spotManager.spots.filter { $0.category == cat }.count
                                if count > 0 {
                                    CategoryFilterChip(
                                        category: cat,
                                        count: count,
                                        isActive: false // categories filter separate from tag filter
                                    )
                                    .onTapGesture {
                                        HapticsHelper.light()
                                        // For now categories use a tag-like filter mechanism
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Tags section
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader("Tags")

                        if spotManager.allTags.filter({ tag in
                            spotManager.spots.contains { $0.tags.contains(where: { $0.id == tag.id }) }
                        }).isEmpty {
                            Text("No tags yet. Save spots with tags to filter here.")
                                .font(AtlasFont.caption())
                                .foregroundStyle(Color.Atlas.textTertiary)
                                .padding(.horizontal, 16)
                        } else {
                            FlowLayout(spacing: 8) {
                                ForEach(spotManager.allTags) { tag in
                                    let hasSpots = spotManager.spots.contains { $0.tags.contains(where: { $0.id == tag.id }) }
                                    if hasSpots {
                                        let isOn = spotManager.activeFilters.contains(tag.id)
                                        Button {
                                            HapticsHelper.light()
                                            spotManager.toggleFilter(tag.id)
                                        } label: {
                                            AtlasPill(text: tag.name, color: tag.color, isSelected: isOn)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }

            // Done button
            Button(action: onDismiss) {
                Text(spotManager.activeFilters.isEmpty ? "Show all spots" :
                     "Show \(spotManager.filteredSpots.count) spot\(spotManager.filteredSpots.count == 1 ? "" : "s")")
                    .font(AtlasFont.label(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.Atlas.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .padding(.top, 8)
        }
        .background(Color.Atlas.background)
    }
}

// MARK: - Category Filter Chip

struct CategoryFilterChip: View {
    let category: SpotCategory
    let count: Int
    let isActive: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: category.symbolName)
                .font(.system(size: 13, weight: .regular))
            Text(category.displayName)
                .font(AtlasFont.tag(12))
            Text("\(count)")
                .font(AtlasFont.caption(10))
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(Capsule().fill(isActive ? Color.white.opacity(0.3) : category.color.opacity(0.15)))
        }
        .foregroundStyle(isActive ? .white : category.color)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Capsule().fill(isActive ? category.color : category.color.opacity(0.10)))
        .animation(.spring(response: 0.25), value: isActive)
    }
}

private struct SectionHeader: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(Color.Atlas.textTertiary)
            .tracking(0.8)
            .padding(.horizontal, 16)
    }
}
