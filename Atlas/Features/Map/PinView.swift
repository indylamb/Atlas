import SwiftUI
import MapKit

/// A pin: one disc per person who saved the place, overlapping.
/// Yours shows the category icon; a friend's shows their initial in their color.
struct PinView: View {
    /// Passed in rather than read from the environment: map annotations are hosted separately.
    let store: AtlasStore
    let pin: AtlasPin
    var isSelected = false

    private let size = Theme.Size.pin
    private let step = Theme.Size.pinOverlap

    var body: some View {
        ZStack(alignment: .leading) {
            ForEach(Array(pin.dots.enumerated()), id: \.element.id) { index, dot in
                disc(for: dot)
                    .offset(x: CGFloat(index) * step)
                    .zIndex(Double(pin.dots.count - index))
            }
        }
        .frame(width: size + CGFloat(max(pin.dots.count - 1, 0)) * step, height: size, alignment: .leading)
        .overlay(alignment: .topTrailing) {
            if pin.isMustHit { badge(Image(systemName: "star.fill"), fill: Theme.Palette.star).offset(x: 6, y: -7) }
        }
        .overlay(alignment: .bottomLeading) {
            if pin.isOnMyMap { badge(Image(systemName: "checkmark"), fill: Theme.Palette.ink).offset(x: -6, y: 6) }
        }
        .opacity(pin.isDimmed ? 0.3 : 1)
        .scaleEffect(isSelected ? 1.25 : 1)
        .animation(.spring(duration: 0.2), value: isSelected)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private func disc(for dot: PinDot) -> some View {
        let hollow = dot.isMe && pin.isHaventBeen
        ZStack {
            Circle().fill(hollow ? Theme.Palette.surface : color(for: dot))
            Circle().strokeBorder(hollow ? Theme.Palette.ink : Color.white, lineWidth: 2)
            if dot.isMe {
                Image(systemName: pin.category.symbol)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(hollow ? Theme.Palette.ink : Theme.Palette.onInk)
            } else {
                Text(store.person(dot.personID)?.initial ?? "?")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
    }

    private func badge(_ image: Image, fill: Color) -> some View {
        image
            .font(.system(size: 8, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 16, height: 16)
            .background(Circle().fill(fill))
            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
    }

    private func color(for dot: PinDot) -> Color {
        store.person(dot.personID)?.color ?? Theme.Palette.unsaved
    }

    private var accessibilityText: String {
        let name = store.place(pin.placeID)?.name ?? "Place"
        let who = pin.dots.compactMap { store.person($0.personID)?.name }.joined(separator: " and ")
        var text = "\(name), saved by \(who)"
        if pin.isMustHit { text += ", Must hit" }
        if pin.isOnMyMap { text += ", already on your map" }
        return text
    }
}
