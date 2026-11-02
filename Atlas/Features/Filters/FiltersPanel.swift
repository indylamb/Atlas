import SwiftUI

/// Opens under the Filters button. Three sections, each with a quick first action and More for depth.
struct FiltersPanel: View {
    @Environment(AtlasStore.self) private var store
    @Binding var filter: FilterState
    /// On a friend's map, "Saved by" doesn't apply.
    let isReceiving: Bool
    var matchingCount: Int? = nil

    @State private var moreTags = false
    @State private var moreRating = false
    @State private var moreWho = false

    private let quickTags = ["Dinner", "Coffee", "Museums", "Parks"]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                tagsSection
                Divider().overlay(Theme.Palette.rule)
                ratingSection
                if !isReceiving {
                    Divider().overlay(Theme.Palette.rule)
                    whoSection
                }
                Divider().overlay(Theme.Palette.rule)
                HStack {
                    Text(filter.activeCount == 0 ? "No filters on" : "\(filter.activeCount) filters on")
                        .font(Theme.Font.label)
                        .foregroundStyle(Theme.Palette.inkMuted)
                    Spacer()
                    Button("Reset") { filter = FilterState() }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.Palette.ink)
                        .disabled(filter.activeCount == 0)
                }
                .padding(.horizontal, Theme.Space.s4)
                .padding(.vertical, Theme.Space.s3)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(width: 318)
        .frame(maxHeight: 520)
        .fixedSize(horizontal: false, vertical: true)
        .background(RoundedRectangle(cornerRadius: Theme.Radius.md).fill(Theme.Palette.surface))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
        .floatShadow()
    }

    // MARK: Sections

    private var tagsSection: some View {
        section("Tags", isExpanded: $moreTags) {
            FlowLayout {
                ForEach(quickTags, id: \.self) { tagChip($0) }
            }
        } more: {
            FlowLayout {
                ForEach(store.allTags.filter { !quickTags.contains($0) }, id: \.self) { tagChip($0) }
            }
            HStack {
                Text("Match").font(Theme.Font.label).foregroundStyle(Theme.Palette.inkMuted)
                Spacer()
                Segmented(options: [(false, "Any"), (true, "All")], selection: $filter.matchAll)
                    .frame(width: 130)
            }
        }
    }

    private var ratingSection: some View {
        section("Rating", isExpanded: $moreRating) {
            Segmented(options: [(FilterState.RatingFilter.any, "Any"), (.goodPlus, "Good+"), (.mustHit, "Must hit")], selection: $filter.rating)
        } more: {
            ToggleRow(title: "Haven\u{2019}t been", subtitle: "Saved but not rated yet", isOn: $filter.showHaventBeen)
            ToggleRow(title: "Skip", subtitle: "2.5 stars or less, hidden by default", isOn: $filter.showSkip)
        }
    }

    private var whoSection: some View {
        section("Saved by", isExpanded: $moreWho) {
            Segmented(options: [(FilterState.Who.everyone, "Everyone"), (.me, "Me"), (.friends, "Friends")], selection: $filter.who)
        } more: {
            ForEach(store.everyone) { person in
                personRow(person)
            }
            ToggleRow(title: "Places no one saved", subtitle: "Apple Maps places, shown as quiet dots", isOn: $filter.showUnsaved)
        }
    }

    // MARK: Pieces

    private func section<Quick: View, More: View>(
        _ title: String,
        isExpanded: Binding<Bool>,
        @ViewBuilder quick: () -> Quick,
        @ViewBuilder more: () -> More
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title).kickerStyle()
                Spacer()
                Button(isExpanded.wrappedValue ? "Less" : "More") {
                    withAnimation(.easeOut(duration: 0.15)) { isExpanded.wrappedValue.toggle() }
                }
                .font(Theme.Font.label)
                .foregroundStyle(Theme.Palette.inkMuted)
            }
            quick()
            if isExpanded.wrappedValue {
                more()
            }
        }
        .padding(.horizontal, Theme.Space.s4)
        .padding(.vertical, 14)
    }

    private func tagChip(_ tag: String) -> some View {
        Chip(title: tag, isOn: filter.tags.contains(tag)) {
            if filter.tags.contains(tag) { filter.tags.remove(tag) } else { filter.tags.insert(tag) }
        }
    }

    private func personRow(_ person: Person) -> some View {
        let isOn = !filter.hiddenPeople.contains(person.id)
        return Button {
            if isOn { filter.hiddenPeople.insert(person.id) } else { filter.hiddenPeople.remove(person.id) }
        } label: {
            HStack(spacing: 10) {
                Avatar(person: person, size: 24)
                Text(person.name).font(Theme.Font.body)
                Spacer()
                Text("\(store.savedCount(person.id)) spots").font(Theme.Font.caption).foregroundStyle(Theme.Palette.inkMuted)
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18))
                    .foregroundStyle(isOn ? Theme.Palette.ink : Theme.Palette.inkMuted)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}
