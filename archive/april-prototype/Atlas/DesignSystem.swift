import SwiftUI

// MARK: - Atlas Color Palette

extension Color {
    enum Atlas {
        // Primary
        static let blue         = Color(hex: "#0A84FF")   // iOS system blue (electric)
        static let blueDark     = Color(hex: "#0060D0")
        static let blueLight    = Color(hex: "#E8F2FF")
        static let blueMid      = Color(hex: "#4DA3FF")

        // Neutrals
        static let white        = Color.white
        static let background   = Color(UIColor.systemBackground)
        static let secondaryBg  = Color(UIColor.secondarySystemBackground)
        static let groupedBg    = Color(UIColor.systemGroupedBackground)

        // Text
        static let textPrimary  = Color(UIColor.label)
        static let textSecondary = Color(UIColor.secondaryLabel)
        static let textTertiary = Color(UIColor.tertiaryLabel)

        // Separators
        static let separator    = Color(UIColor.separator).opacity(0.5)

        // Map overlay
        static let mapSheet     = Color(UIColor.systemBackground)
        static let pill         = Color(UIColor.secondarySystemBackground)
    }
}

// MARK: - Typography

enum AtlasFont {
    // Display
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .thin, design: .default)
    }
    // Title
    static func title(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .light, design: .default)
    }
    // Body
    static func body(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .light, design: .default)
    }
    // Caption
    static func caption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .light, design: .default)
    }
    // Label
    static func label(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    // Tag pill
    static func tag(_ size: CGFloat = 11) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
}

// MARK: - Shared Components

struct AtlasCard<Content: View>: View {
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 16
    let content: Content

    init(cornerRadius: CGFloat = 16, padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(Color.Atlas.background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
    }
}

struct AtlasPill: View {
    let text: String
    var color: Color = Color.Atlas.blue
    var isSelected: Bool = false

    var body: some View {
        Text(text)
            .font(AtlasFont.tag())
            .foregroundStyle(isSelected ? .white : color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(isSelected ? color : color.opacity(0.12))
            )
    }
}

struct AtlasIconButton: View {
    let symbol: String
    var size: CGFloat = 18
    var color: Color = Color.Atlas.blue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: size, weight: .light))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(Color.Atlas.background)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
        }
    }
}

// Star row
struct StarRatingView: View {
    @Binding var rating: Int
    var maxRating: Int = 5
    var size: CGFloat = 22
    var interactive: Bool = true

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...maxRating, id: \.self) { i in
                Image(systemName: i <= rating ? "star.fill" : "star")
                    .font(.system(size: size, weight: .thin))
                    .foregroundStyle(i <= rating ? Color(hex: "#F5A623") : Color.Atlas.textTertiary)
                    .onTapGesture {
                        if interactive {
                            rating = (rating == i) ? 0 : i
                        }
                    }
            }
        }
    }
}

// Google-style star display (read-only, small)
struct GoogleRatingView: View {
    let rating: Double
    let reviewCount: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Color(hex: "#F5A623"))
            Text(String(format: "%.1f", rating))
                .font(AtlasFont.label(12))
                .foregroundStyle(Color.Atlas.textPrimary)
            Text("(\(reviewCount.formatted()))")
                .font(AtlasFont.caption(12))
                .foregroundStyle(Color.Atlas.textSecondary)
        }
    }
}

// Category icon badge
struct CategoryBadge: View {
    let category: SpotCategory
    var size: CGFloat = 32

    var body: some View {
        ZStack {
            Circle()
                .fill(category.color.opacity(0.15))
                .frame(width: size, height: size)
            Image(systemName: category.symbolName)
                .font(.system(size: size * 0.42, weight: .regular))
                .foregroundStyle(category.color)
        }
    }
}

// MARK: - Sheet drag handle

struct SheetHandle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.Atlas.textTertiary.opacity(0.4))
            .frame(width: 36, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 4)
    }
}

// MARK: - Haptics

enum HapticsHelper {
    static func light()   { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func medium()  { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
}

// MARK: - View modifiers

struct FloatingCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.Atlas.background)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.10), radius: 20, x: 0, y: 8)
    }
}

extension View {
    func floatingCard() -> some View {
        modifier(FloatingCardModifier())
    }
}
