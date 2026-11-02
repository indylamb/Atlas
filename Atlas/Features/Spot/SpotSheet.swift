import SwiftUI
import MapKit

/// The half sheet for a place: what it is, who saved it, your take as a property list (Notion),
/// then friends' takes set as pull quotes (NYT).
struct SpotSheet: View {
    @Environment(AtlasStore.self) private var store
    @Bindable var model: HomeModel

    var body: some View {
        if let id = model.selectedPlaceID, let place = store.place(id) {
            content(place)
        } else {
            Color.clear
        }
    }

    private func content(_ place: Place) -> some View {
        let mine = store.myTake(place.id)
        return ScrollView {
            VStack(alignment: .leading, spacing: Theme.Space.s4) {
                header(place)
                social(place)
                if let map = receivingMap {
                    Text(mine == nil
                         ? "From \(store.person(map.fromID)?.name ?? "your friend")\u{2019}s map. Save it to keep it; a rating is optional."
                         : "From \(store.person(map.fromID)?.name ?? "your friend")\u{2019}s map. Already on your map.")
                        .font(Theme.Font.label)
                        .foregroundStyle(Theme.Palette.inkMuted)
                }
                YourTake(place: place)
                friendsSection(place)
            }
            .padding(.horizontal, Theme.Space.s4)
            .padding(.top, Theme.Space.s6)
            .padding(.bottom, Theme.Space.s4)
        }
        .safeAreaInset(edge: .bottom) { actions(place, isSaved: mine != nil) }
        .background(Theme.Palette.surface)
    }

    private var receivingMap: IncomingMap? {
        guard let id = model.receivingMapID else { return nil }
        return store.incoming.first { $0.id == id }
    }

    // MARK: Pieces

    private func header(_ place: Place) -> some View {
        HStack(alignment: .top, spacing: Theme.Space.s3) {
            IconTile(category: place.category)
            VStack(alignment: .leading, spacing: 2) {
                Text(place.name)
                    .font(Theme.Font.display())
                    .fixedSize(horizontal: false, vertical: true)
                Text(place.detail)
                    .font(Theme.Font.body)
                    .foregroundStyle(Theme.Palette.inkMuted)
            }
            Spacer(minLength: 0)
            Button { model.closeSheet() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.Palette.ink)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Theme.Palette.surfaceRaised))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
    }

    private func social(_ place: Place) -> some View {
        let savers = store.takes(for: place.id).compactMap { store.person($0.personID) }
            .sorted { $0.isMe && !$1.isMe }
        let friendNames = savers.filter { !$0.isMe }.map(\.name)
        let line: String
        if savers.isEmpty {
            line = "No one you know has saved this yet"
        } else if savers.contains(where: \.isMe) {
            line = friendNames.isEmpty ? "Only you have saved this" : "Saved by you and \(ListFormatter.localizedString(byJoining: friendNames))"
        } else {
            line = "Saved by \(ListFormatter.localizedString(byJoining: friendNames))"
        }
        return HStack(spacing: 10) {
            if !savers.isEmpty { AvatarStack(people: savers) }
            Text(line).font(.system(size: 14, weight: .medium))
        }
    }

    @ViewBuilder
    private func friendsSection(_ place: Place) -> some View {
        let friendTakes = store.friendTakes(place.id)
        if friendTakes.isEmpty {
            Text(store.isSaved(place.id) ? "None of your friends have saved this yet." : "Be the first in your circle to save it.")
                .font(Theme.Font.body)
                .foregroundStyle(Theme.Palette.inkMuted)
        } else {
            VStack(alignment: .leading, spacing: Theme.Space.s3) {
                Text("Friends").kickerStyle()
                ForEach(friendTakes, id: \.personID) { take in
                    if let person = store.person(take.personID) {
                        FriendTakeRow(person: person, take: take)
                    }
                }
            }
        }
    }

    private func actions(_ place: Place, isSaved: Bool) -> some View {
        HStack(spacing: Theme.Space.s2) {
            Button(isSaved ? "\u{2713} On your map" : "Save to my map") {
                store.toggleSaved(place.id)
            }
            .buttonStyle(AtlasButtonStyle(kind: isSaved ? .outline : .primary, fillWidth: true))

            Button("Directions") { openInMaps(place) }
                .buttonStyle(AtlasButtonStyle(kind: .secondary))

            Button {
                model.chooseRecipient(placeIDs: [place.id], title: place.name)
            } label: {
                Image(systemName: "paperplane")
            }
            .buttonStyle(AtlasButtonStyle(kind: .secondary))
            .accessibilityLabel("Send this spot")
        }
        .padding(.horizontal, Theme.Space.s4)
        .padding(.top, 10)
        .padding(.bottom, Theme.Space.s2)
        .background(Theme.Palette.surface)
        .overlay(alignment: .top) { Divider().overlay(Theme.Palette.rule) }
    }

    private func openInMaps(_ place: Place) {
        let item = MKMapItem(placemark: MKPlacemark(coordinate: place.coordinate))
        item.name = place.name
        item.openInMaps()
    }
}

/// Your rating, tags and note, as Notion-style property rows.
private struct YourTake: View {
    @Environment(AtlasStore.self) private var store
    let place: Place

    var body: some View {
        let mine = store.myTake(place.id)
        VStack(spacing: 0) {
            property("Your rating") {
                HStack(spacing: Theme.Space.s2) {
                    StarRatingInput(rating: Binding(
                        get: { store.myTake(place.id)?.rating ?? 0 },
                        set: { store.setRating($0, for: place.id) }
                    ))
                    Text(mine == nil ? "Not saved" : RatingLabel(rating: mine?.rating ?? 0).title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(RatingLabel(rating: mine?.rating ?? 0).color)
                }
            }
            property("Tags") {
                FlowLayout {
                    ForEach(place.tags, id: \.self) { TagLabel(title: $0, muted: mine == nil) }
                    Text("+ Tag")
                        .font(Theme.Font.label)
                        .foregroundStyle(Theme.Palette.inkMuted)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .overlay(RoundedRectangle(cornerRadius: Theme.Radius.sm).strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3])).foregroundStyle(Theme.Palette.rule))
                }
            }
            property("Your note") {
                if mine == nil {
                    Text("Save it to add a note for friends")
                        .font(Theme.Font.body)
                        .foregroundStyle(Theme.Palette.unsaved)
                } else {
                    TextField("Add a note for friends", text: Binding(
                        get: { store.myTake(place.id)?.note ?? "" },
                        set: { store.setNote($0, for: place.id) }
                    ), axis: .vertical)
                    .font(Theme.Font.body)
                    .lineLimit(1...4)
                }
            }
        }
        .overlay(alignment: .top) { Divider().overlay(Theme.Palette.rule) }
    }

    private func property<Value: View>(_ label: String, @ViewBuilder value: () -> Value) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Space.s3) {
            Text(label)
                .font(Theme.Font.label)
                .foregroundStyle(Theme.Palette.inkMuted)
                .frame(width: 92, alignment: .leading)
            value()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) { Divider().overlay(Theme.Palette.rule) }
    }
}

/// A friend's rating and note, the note set as a pull quote.
struct FriendTakeRow: View {
    let person: Person
    let take: Take

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Avatar(person: person, size: 30)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: Theme.Space.s2) {
                    Text(person.name).font(Theme.Font.bodyStrong)
                    RatingSummary(rating: take.rating)
                }
                if !take.note.isEmpty {
                    Text("\u{201C}\(take.note)\u{201D}")
                        .font(Theme.Font.quote)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
