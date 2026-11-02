import SwiftUI

/// Black pill button (Uber). `secondary` is the warm-gray variant.
struct AtlasButtonStyle: ButtonStyle {
    enum Kind { case primary, secondary, outline }
    var kind: Kind = .primary
    var height: CGFloat = 48
    var fillWidth = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Font.headline)
            .padding(.horizontal, Theme.Space.s4 + 2)
            .frame(maxWidth: fillWidth ? .infinity : nil)
            .frame(height: height)
            .foregroundStyle(foreground)
            .background(Capsule().fill(background))
            .overlay(Capsule().strokeBorder(kind == .outline ? Theme.Palette.ink : .clear, lineWidth: 1.5))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }

    private var foreground: Color {
        kind == .primary ? Theme.Palette.onInk : Theme.Palette.ink
    }

    private var background: Color {
        switch kind {
        case .primary: return Theme.Palette.ink
        case .secondary: return Theme.Palette.surfaceRaised
        case .outline: return Theme.Palette.surface
        }
    }
}

/// Round 44pt button floating over the map.
struct RoundIconButton: View {
    let symbol: String
    let label: String
    var filled = false
    var badge: Int? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(filled ? Theme.Palette.onInk : Theme.Palette.ink)
                .frame(width: Theme.Size.control, height: Theme.Size.control)
                .background(Circle().fill(filled ? Theme.Palette.ink : Theme.Palette.surface))
                .floatShadow()
                .overlay(alignment: .topTrailing) {
                    if let badge, badge > 0 {
                        Text("\(badge)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 20, minHeight: 20)
                            .background(Circle().fill(Theme.Palette.badge))
                            .overlay(Circle().stroke(Theme.Palette.surface, lineWidth: 2))
                            .offset(x: 4, y: -4)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

/// Notion-tight chip that toggles.
struct Chip: View {
    let title: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Font.label)
                .padding(.horizontal, 10)
                .frame(height: 30)
                .foregroundStyle(isOn ? Theme.Palette.onInk : Theme.Palette.ink)
                .background(RoundedRectangle(cornerRadius: Theme.Radius.sm).fill(isOn ? Theme.Palette.ink : Theme.Palette.surface))
                .overlay(RoundedRectangle(cornerRadius: Theme.Radius.sm).strokeBorder(isOn ? Theme.Palette.ink : Theme.Palette.rule))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

/// A read-only tag, as on the spot sheet.
struct TagLabel: View {
    let title: String
    var muted = false

    var body: some View {
        Text(title)
            .font(Theme.Font.label)
            .foregroundStyle(muted ? Theme.Palette.inkMuted : Theme.Palette.ink)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(RoundedRectangle(cornerRadius: Theme.Radius.sm).fill(muted ? Theme.Palette.surface : Theme.Palette.surfaceRaised))
            .overlay(RoundedRectangle(cornerRadius: Theme.Radius.sm).strokeBorder(muted ? Theme.Palette.rule : .clear))
    }
}

/// Notion-style segmented control.
struct Segmented<Value: Hashable>: View {
    let options: [(Value, String)]
    @Binding var selection: Value

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.0) { option in
                let isOn = option.0 == selection
                Button { selection = option.0 } label: {
                    Text(option.1)
                        .font(.system(size: 13, weight: isOn ? .semibold : .medium))
                        .foregroundStyle(Theme.Palette.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(isOn ? Theme.Palette.surface : .clear)
                                .shadow(color: .black.opacity(isOn ? 0.12 : 0), radius: 1, y: 1)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isOn ? .isSelected : [])
            }
        }
        .padding(2)
        .background(RoundedRectangle(cornerRadius: Theme.Radius.sm).fill(Theme.Palette.surfaceRaised))
    }
}

/// Label and switch on one row.
struct ToggleRow: View {
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(Theme.Font.body)
                if let subtitle {
                    Text(subtitle).font(Theme.Font.caption).foregroundStyle(Theme.Palette.inkMuted)
                }
            }
        }
        .tint(Theme.Palette.ink)
    }
}

/// Wrapping layout for chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, widest: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            widest = max(widest, x - spacing)
        }
        return CGSize(width: proposal.width ?? widest, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
