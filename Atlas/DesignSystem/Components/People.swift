import SwiftUI

/// A person's initial in their color.
struct Avatar: View {
    let person: Person
    var size: CGFloat = 30

    var body: some View {
        Text(person.isMe ? "I" : person.initial)
            .font(.system(size: size * 0.42, weight: .bold))
            .foregroundStyle(person.isMe ? Theme.Palette.onInk : .white)
            .frame(width: size, height: size)
            .background(Circle().fill(person.color))
            .accessibilityLabel(person.name)
    }
}

/// Overlapping avatars, as in "Saved by you and Nick".
struct AvatarStack: View {
    let people: [Person]
    var size: CGFloat = 24

    var body: some View {
        HStack(spacing: -size * 0.25) {
            ForEach(people) { person in
                Avatar(person: person, size: size)
                    .overlay(Circle().stroke(Theme.Palette.surface, lineWidth: 2))
            }
        }
    }
}

/// Square warm-gray tile holding a category icon (Notion).
struct IconTile: View {
    let category: PlaceCategory
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: category.symbol)
            .font(.system(size: size * 0.45, weight: .regular))
            .foregroundStyle(Theme.Palette.ink)
            .frame(width: size, height: size)
            .background(RoundedRectangle(cornerRadius: Theme.Radius.sm).fill(Theme.Palette.surfaceRaised))
    }
}
