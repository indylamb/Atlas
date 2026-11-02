import SwiftUI

/// Five tappable stars with half steps. Tap the left half of a star for a half star;
/// drag across to scrub; tap the current value again to clear it.
struct StarRatingInput: View {
    @Binding var rating: Double
    var starSize: CGFloat = 24
    var spacing: CGFloat = 2

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...5, id: \.self) { index in
                StarGlyph(fill: fill(for: index), size: starSize)
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { drag in
                    guard abs(drag.translation.width) > 4 else { return }
                    rating = ratingAt(x: drag.location.x)
                }
                .onEnded { drag in
                    let picked = ratingAt(x: drag.location.x)
                    let wasTap = abs(drag.translation.width) <= 4
                    rating = (wasTap && picked == rating) ? 0 : picked
                }
        )
        .sensoryFeedback(.selection, trigger: rating)
        .accessibilityElement()
        .accessibilityLabel("Your rating")
        .accessibilityValue(rating == 0 ? "Not rated" : "\(rating.formatted()) stars")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: rating = min(5, rating + 0.5)
            case .decrement: rating = max(0, rating - 0.5)
            @unknown default: break
            }
        }
    }

    private var totalWidth: CGFloat { starSize * 5 + spacing * 4 }

    private func ratingAt(x: CGFloat) -> Double {
        let clamped = min(max(x, 0), totalWidth)
        let raw = Double(clamped / (starSize + spacing))
        return min(5, max(0.5, (raw * 2).rounded(.up) / 2))
    }

    private func fill(for index: Int) -> Double {
        if rating >= Double(index) { return 1 }
        if rating >= Double(index) - 0.5 { return 0.5 }
        return 0
    }
}

/// One star, filled 0, 0.5 or 1.
struct StarGlyph: View {
    let fill: Double
    var size: CGFloat = 14

    var body: some View {
        ZStack(alignment: .leading) {
            Image(systemName: "star.fill")
                .font(.system(size: size))
                .foregroundStyle(Theme.Palette.rule)
            Image(systemName: "star.fill")
                .font(.system(size: size))
                .foregroundStyle(Theme.Palette.star)
                .mask(alignment: .leading) {
                    Rectangle().frame(width: size * 1.1 * fill)
                }
        }
        .frame(width: size * 1.1, height: size * 1.1, alignment: .leading)
    }
}

/// Read-only small stars plus the label, e.g. ★★★★½ Must hit.
struct RatingSummary: View {
    let rating: Double
    var starSize: CGFloat = 11

    var body: some View {
        let label = RatingLabel(rating: rating)
        HStack(spacing: 6) {
            if rating > 0 {
                HStack(spacing: 1) {
                    ForEach(1...5, id: \.self) { index in
                        StarGlyph(fill: rating >= Double(index) ? 1 : (rating >= Double(index) - 0.5 ? 0.5 : 0), size: starSize)
                    }
                }
            }
            Text(label.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(label.color)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rating > 0 ? "\(rating.formatted()) stars, \(label.title)" : label.title)
    }
}
