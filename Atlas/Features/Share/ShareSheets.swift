import SwiftUI

/// Pick who gets the spots. Friends on Atlas first, then contacts who get an invite.
struct SendToSheet: View {
    @Environment(AtlasStore.self) private var store
    @Bindable var model: HomeModel
    @State private var query = ""
    @State private var recipientID: String?

    /// A contact who isn't on Atlas yet. Slice 2 reads real contacts.
    private let inviteContact = Person(id: "contact-sam", name: "Sam", colorIndex: 0)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("Send \(model.sendTitle)")
                    .font(Theme.Font.display(28))
                    .lineLimit(2)
                Spacer()
                Button("Back") { model.sheet = nil }
                    .font(Theme.Font.bodyStrong)
                    .foregroundStyle(Theme.Palette.ink)
            }
            HStack(spacing: Theme.Space.s2) {
                Image(systemName: "magnifyingglass").foregroundStyle(Theme.Palette.inkMuted)
                TextField("Search friends and contacts", text: $query)
                    .font(Theme.Font.body)
            }
            .padding(.horizontal, Theme.Space.s4)
            .frame(height: Theme.Size.control)
            .background(Capsule().fill(Theme.Palette.surfaceRaised))

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(matches, id: \.0.id) { item in
                        row(item.0, subtitle: item.1)
                    }
                }
            }

            Button(buttonTitle, action: send)
                .buttonStyle(AtlasButtonStyle(kind: .primary, height: 50, fillWidth: true))
                .disabled(recipient == nil)
                .opacity(recipient == nil ? 0.4 : 1)
        }
        .padding(.horizontal, Theme.Space.s4)
        .padding(.top, Theme.Space.s6)
        .padding(.bottom, Theme.Space.s2)
        .background(Theme.Palette.surface)
    }

    private var candidates: [(Person, String)] {
        store.friends.map { ($0, $0.isFullAccess ? "Full access friend · on Atlas" : "Friend · on Atlas") }
            + [(inviteContact, "From your contacts · not on Atlas yet, gets an invite")]
    }

    private var matches: [(Person, String)] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return candidates }
        return candidates.filter { $0.0.name.lowercased().hasPrefix(q) }
    }

    private var recipient: Person? {
        candidates.first { $0.0.id == recipientID }?.0
    }

    private var buttonTitle: String {
        recipient.map { "Send to \($0.name)" } ?? "Choose who to send to"
    }

    private func row(_ person: Person, subtitle: String) -> some View {
        let isOn = recipientID == person.id
        return Button { recipientID = person.id } label: {
            HStack(spacing: Theme.Space.s3) {
                Avatar(person: person, size: 36)
                    .saturation(person.id == inviteContact.id ? 0 : 1)
                VStack(alignment: .leading, spacing: 2) {
                    Text(person.name).font(.system(size: 16, weight: .medium))
                    Text(subtitle).font(Theme.Font.caption).foregroundStyle(Theme.Palette.inkMuted)
                }
                Spacer()
                Circle()
                    .strokeBorder(isOn ? Theme.Palette.ink : Theme.Palette.rule, lineWidth: isOn ? 7 : 1.5)
                    .frame(width: 22, height: 22)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .overlay(alignment: .bottom) { Divider().overlay(Theme.Palette.rule) }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    private func send() {
        guard let recipient else { return }
        store.send(placeIDs: model.sendPlaceIDs, to: recipient.id)
        let invite = recipient.id == inviteContact.id
        model.finishSending(message: invite
            ? "Sent \(model.sendTitle) to \(recipient.name), with an invite to Atlas."
            : "Sent \(model.sendTitle) to \(recipient.name). They\u{2019}ll land right on this map.")
    }
}

/// The list view of a friend's map: save spots one by one, or all at once.
struct ReceivedListSheet: View {
    @Environment(AtlasStore.self) private var store
    @Bindable var model: HomeModel
    let placeIDs: [String]
    let saveAll: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(senderName)\u{2019}s map").font(Theme.Font.display(28))
                    Text("\(placeIDs.count) spots match your filters")
                        .font(Theme.Font.label)
                        .foregroundStyle(Theme.Palette.inkMuted)
                }
                Spacer()
                Button("Map") { model.sheet = nil }
                    .font(Theme.Font.bodyStrong)
                    .foregroundStyle(Theme.Palette.ink)
            }
            .padding(.horizontal, Theme.Space.s4)
            .padding(.top, Theme.Space.s6)
            .padding(.bottom, Theme.Space.s3)
            .overlay(alignment: .bottom) { Divider().overlay(Theme.Palette.rule) }

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(placeIDs, id: \.self) { id in
                        if let place = store.place(id) { row(place) }
                    }
                }
                .padding(.horizontal, Theme.Space.s4)
            }

            Button("Save all \(placeIDs.count) to my map", action: saveAll)
                .buttonStyle(AtlasButtonStyle(kind: .primary, height: 50, fillWidth: true))
                .padding(.horizontal, Theme.Space.s4)
                .padding(.vertical, 10)
                .overlay(alignment: .top) { Divider().overlay(Theme.Palette.rule) }
        }
        .background(Theme.Palette.surface)
    }

    private var map: IncomingMap? {
        guard let id = model.receivingMapID else { return nil }
        return store.incoming.first { $0.id == id }
    }

    private var senderName: String {
        map.flatMap { store.person($0.fromID)?.name } ?? "Friend"
    }

    private func row(_ place: Place) -> some View {
        let take = map?.takes[place.id]
        let saved = store.isSaved(place.id)
        return HStack(spacing: Theme.Space.s3) {
            Button { model.openSpot(place.id) } label: {
                HStack(spacing: Theme.Space.s3) {
                    IconTile(category: place.category, size: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(place.name).font(.system(size: 16, weight: .semibold))
                        if let take {
                            HStack(spacing: 4) {
                                RatingSummary(rating: take.rating)
                                if !take.note.isEmpty {
                                    Text("· \u{201C}\(take.note)\u{201D}")
                                        .font(Theme.Font.caption)
                                        .foregroundStyle(Theme.Palette.inkMuted)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(saved ? "\u{2713} Saved" : "Save") { store.toggleSaved(place.id) }
                .buttonStyle(AtlasButtonStyle(kind: saved ? .outline : .primary, height: 34))
                .font(.system(size: 13, weight: .semibold))
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) { Divider().overlay(Theme.Palette.rule) }
    }
}
