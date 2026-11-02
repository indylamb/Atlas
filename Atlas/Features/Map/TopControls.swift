import SwiftUI

/// Search bar (or the friend's-map header) plus the action buttons under it on the right,
/// and the panels those buttons open.
struct TopControls: View {
    @Environment(AtlasStore.self) private var store
    @Bindable var model: HomeModel
    /// Your spots inside the frame while sending.
    let sendIDs: [String]
    let receivedCount: Int
    let saveAll: () -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            if let mapID = model.receivingMapID, let map = store.incoming.first(where: { $0.id == mapID }) {
                ReceiveHeader(map: map, count: receivedCount) { model.finishReceiving() }
            } else {
                SearchBar()
            }
            actions
            if model.showFilters {
                FiltersPanel(filter: $model.filter, isReceiving: model.receivingMapID != nil, matchingCount: nil)
                    .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .topTrailing)))
            }
            if model.showSendMenu {
                SendMenu(model: model)
                    .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .topTrailing)))
            }
        }
        .padding(.horizontal, Theme.Space.s4)
        .padding(.top, Theme.Space.s2)
        .animation(.easeOut(duration: 0.15), value: model.showFilters)
        .animation(.easeOut(duration: 0.15), value: model.showSendMenu)
    }

    @ViewBuilder
    private var actions: some View {
        HStack(spacing: Theme.Space.s2) {
            RoundIconButton(symbol: "slider.horizontal.3", label: "Filters", filled: model.showFilters, badge: model.filter.activeCount) {
                model.toggleFilters()
            }
            switch model.mode {
            case .browsing:
                RoundIconButton(symbol: "paperplane", label: "Send and receive", filled: true, badge: store.unreadCount) {
                    model.toggleSendMenu()
                }
            case .sending:
                Button("Cancel") { model.cancelSending() }
                    .buttonStyle(AtlasButtonStyle(kind: .outline, height: Theme.Size.control))
                    .floatShadow()
                Button("Send \(sendIDs.count)") {
                    model.chooseRecipient(placeIDs: sendIDs, title: "\(sendIDs.count) spots")
                }
                .buttonStyle(AtlasButtonStyle(kind: .primary, height: Theme.Size.control))
                .disabled(sendIDs.isEmpty)
                .floatShadow()
            case .receiving:
                Button("List") { model.sheet = .receivedList }
                    .buttonStyle(AtlasButtonStyle(kind: .outline, height: Theme.Size.control))
                    .floatShadow()
                Button("Save all \(receivedCount)", action: saveAll)
                    .buttonStyle(AtlasButtonStyle(kind: .primary, height: Theme.Size.control))
                    .disabled(receivedCount == 0)
                    .floatShadow()
            }
        }
    }
}

/// White pill search bar (Uber). Search arrives with Apple Maps search in slice 2.
struct SearchBar: View {
    @Environment(AtlasStore.self) private var store
    @State private var query = ""

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
            TextField("Search places or friends", text: $query)
                .font(.system(size: 16, weight: .medium))
                .submitLabel(.search)
            Avatar(person: store.me, size: 34)
        }
        .padding(.leading, Theme.Space.s4)
        .padding(.trailing, 7)
        .frame(height: 48)
        .background(Capsule().fill(Theme.Palette.surface))
        .floatShadow()
    }
}

/// Replaces the search bar while you look at a friend's map.
struct ReceiveHeader: View {
    @Environment(AtlasStore.self) private var store
    let map: IncomingMap
    let count: Int
    let done: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            if let sender = store.person(map.fromID) {
                Avatar(person: sender, size: 38)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("\(store.person(map.fromID)?.name ?? "Friend")\u{2019}s map")
                    .font(Theme.Font.display(18))
                Text("\(map.title) · \(count) spots · live")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.Palette.inkMuted)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Button("Done", action: done)
                .buttonStyle(AtlasButtonStyle(kind: .secondary, height: 36))
        }
        .padding(.horizontal, 8)
        .frame(height: 54)
        .background(Capsule().fill(Theme.Palette.surface))
        .floatShadow()
    }
}

/// The menu behind the Send button: maps sent to you, then sending your own.
struct SendMenu: View {
    @Environment(AtlasStore.self) private var store
    @Bindable var model: HomeModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Sent to you").kickerStyle()
                .padding(.horizontal, Theme.Space.s4)
                .padding(.top, 14)
                .padding(.bottom, 6)
            if store.incoming.isEmpty {
                Text("Nothing yet. When a friend sends you a map, it shows up here.")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.Palette.inkMuted)
                    .padding(.horizontal, Theme.Space.s4)
                    .padding(.bottom, 14)
            }
            ForEach(store.incoming) { map in
                Button {
                    store.open(map.id)
                    model.startReceiving(map.id)
                } label: {
                    row(person: store.person(map.fromID),
                        title: "\(store.person(map.fromID)?.name ?? "A friend") sent you \(map.placeIDs.count) spots",
                        subtitle: "\(map.title) · \(map.sentAt.formatted(.relative(presentation: .named)))",
                        isNew: map.isNew)
                }
                .buttonStyle(.plain)
            }
            Divider().overlay(Theme.Palette.rule)
            Button(action: model.startSending) {
                HStack(spacing: Theme.Space.s3) {
                    Image(systemName: "paperplane")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.Palette.onInk)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Theme.Palette.ink))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Send what\u{2019}s on screen").font(Theme.Font.bodyStrong)
                        Text("Outline the map, then choose who gets it").font(Theme.Font.caption).foregroundStyle(Theme.Palette.inkMuted)
                    }
                    Spacer(minLength: 0)
                }
                .padding(Theme.Space.s4)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(width: 318)
        .background(RoundedRectangle(cornerRadius: Theme.Radius.md).fill(Theme.Palette.surface))
        .floatShadow()
    }

    private func row(person: Person?, title: String, subtitle: String, isNew: Bool) -> some View {
        HStack(spacing: Theme.Space.s3) {
            if let person { Avatar(person: person, size: 36) }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(Theme.Font.bodyStrong)
                Text(subtitle).font(Theme.Font.caption).foregroundStyle(Theme.Palette.inkMuted)
            }
            Spacer(minLength: 0)
            if isNew {
                Text("New")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(RoundedRectangle(cornerRadius: Theme.Radius.sm).fill(Theme.Palette.badge))
            }
        }
        .padding(.horizontal, Theme.Space.s4)
        .padding(.top, 6)
        .padding(.bottom, 14)
        .contentShape(Rectangle())
    }
}

/// The border around the screen in send mode, and the count pill.
struct ShareFrame: View {
    let count: Int

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .strokeBorder(Theme.Palette.ink, lineWidth: 4)
                .ignoresSafeArea()
            Text("\(count) of your spots inside the frame · pan or zoom to change")
                .font(Theme.Font.label)
                .foregroundStyle(Theme.Palette.onInk)
                .padding(.horizontal, Theme.Space.s4)
                .padding(.vertical, 10)
                .background(Capsule().fill(Theme.Palette.ink))
                .floatShadow()
                .padding(.bottom, 40)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(Theme.Font.body)
            .foregroundStyle(Theme.Palette.onInk)
            .padding(.horizontal, Theme.Space.s4)
            .padding(.vertical, Theme.Space.s3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: Theme.Radius.md).fill(Theme.Palette.ink))
            .floatShadow()
            .padding(.horizontal, Theme.Space.s4)
            .accessibilityAddTraits(.isStaticText)
    }
}
