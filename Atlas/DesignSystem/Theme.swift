import SwiftUI
import UIKit

/// Every visual token in Atlas. Mirrors the Atlas Design System (v0.2: Uber meets NYT meets Notion).
/// Views use these instead of literal colors, fonts or sizes so the look can change in one place.
enum Theme {

    // MARK: Color

    enum Palette {
        static let surface = Color(light: 0xFFFFFF, dark: 0x191919)
        static let surfaceRaised = Color(light: 0xF6F6F4, dark: 0x252525)
        static let ink = Color(light: 0x111111, dark: 0xF2F2F0)
        static let onInk = Color(light: 0xFFFFFF, dark: 0x111111)
        static let inkMuted = Color(light: 0x6B6B68, dark: 0xA1A19C)
        static let rule = Color(light: 0xE7E7E4, dark: 0x2F2F2F)
        static let unsaved = Color(light: 0x9B9B97, dark: 0x6B6B68)
        static let star = Color(light: 0xF0A500, dark: 0xF0B429)
        static let ratingMust = Color(light: 0x8A5A00, dark: 0xF0B429)
        static let badge = Color(light: 0xE5484D, dark: 0xF2555A)
        static let scrim = Color.black.opacity(0.2)

        /// Friend layer colors, assigned in order. Pins always carry the friend's initial too.
        static let friends: [Color] = [
            Color(light: 0xC2410C, dark: 0xFB923C),
            Color(light: 0x2F7D4F, dark: 0x4ADE80),
            Color(light: 0x3B5BDB, dark: 0x7C9CFF),
        ]

        static func friend(_ index: Int) -> Color {
            friends[((index % friends.count) + friends.count) % friends.count]
        }
    }

    // MARK: Type

    enum Font {
        /// Serif, the NYT voice: spot names, screen titles.
        static func display(_ size: CGFloat = 30) -> SwiftUI.Font { .system(size: size, weight: .medium, design: .serif) }
        /// Friends' notes, set like pull quotes.
        static let quote = SwiftUI.Font.system(size: 16, weight: .regular, design: .serif).italic()
        static let headline = SwiftUI.Font.system(size: 17, weight: .semibold)
        static let body = SwiftUI.Font.system(size: 15, weight: .regular)
        static let bodyStrong = SwiftUI.Font.system(size: 15, weight: .semibold)
        static let label = SwiftUI.Font.system(size: 13, weight: .medium)
        static let caption = SwiftUI.Font.system(size: 12, weight: .regular)
        /// Small-caps section labels.
        static let kicker = SwiftUI.Font.system(size: 11, weight: .semibold)
    }

    // MARK: Space, shape, shadow

    enum Space {
        static let s1: CGFloat = 4
        static let s2: CGFloat = 8
        static let s3: CGFloat = 12
        static let s4: CGFloat = 16
        static let s6: CGFloat = 24
    }

    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
    }

    enum Size {
        static let control: CGFloat = 44
        static let pin: CGFloat = 30
        static let pinOverlap: CGFloat = 14
        static let unsavedDot: CGFloat = 14
        static let spotDetent: CGFloat = 0.56
    }
}

extension View {
    /// Shadow for anything floating over the map.
    func floatShadow() -> some View {
        shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
    }

    /// Small-caps kicker styling for section labels.
    func kickerStyle() -> some View {
        font(Theme.Font.kicker)
            .tracking(0.9)
            .textCase(.uppercase)
            .foregroundStyle(Theme.Palette.inkMuted)
    }
}

extension Color {
    /// A color that switches between light and dark hex values.
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
