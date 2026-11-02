import Foundation
import MapKit
import SwiftUI

// MARK: - SpotCategory

enum SpotCategory: String, CaseIterable, Codable, Identifiable {
    case restaurant = "restaurant"
    case cafe = "cafe"
    case bar = "bar"
    case park = "park"
    case museum = "museum"
    case shopping = "shopping"
    case music = "music"
    case fitness = "fitness"
    case hotel = "hotel"
    case beach = "beach"
    case art = "art"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .restaurant: return "Restaurant"
        case .cafe:       return "Café"
        case .bar:        return "Bar"
        case .park:       return "Park"
        case .museum:     return "Museum"
        case .shopping:   return "Shopping"
        case .music:      return "Music Venue"
        case .fitness:    return "Fitness"
        case .hotel:      return "Hotel"
        case .beach:      return "Beach"
        case .art:        return "Art"
        case .other:      return "Other"
        }
    }

    var symbolName: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .cafe:       return "cup.and.saucer.fill"
        case .bar:        return "wineglass.fill"
        case .park:       return "leaf.fill"
        case .museum:     return "building.columns.fill"
        case .shopping:   return "bag.fill"
        case .music:      return "music.note"
        case .fitness:    return "figure.run"
        case .hotel:      return "bed.double.fill"
        case .beach:      return "water.waves"
        case .art:        return "paintpalette.fill"
        case .other:      return "mappin.fill"
        }
    }

    var color: Color {
        switch self {
        case .restaurant: return Color(hex: "#FF6B6B")
        case .cafe:       return Color(hex: "#C9A96E")
        case .bar:        return Color(hex: "#9B59B6")
        case .park:       return Color(hex: "#27AE60")
        case .museum:     return Color(hex: "#2980B9")
        case .shopping:   return Color(hex: "#E91E8C")
        case .music:      return Color(hex: "#F39C12")
        case .fitness:    return Color(hex: "#1ABC9C")
        case .hotel:      return Color(hex: "#3498DB")
        case .beach:      return Color(hex: "#00BCD4")
        case .art:        return Color(hex: "#FF5722")
        case .other:      return Color(hex: "#95A5A6")
        }
    }
}

// MARK: - Tag

struct Tag: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String
    var colorHex: String

    var color: Color { Color(hex: colorHex) }

    static let presets: [Tag] = [
        Tag(name: "date night", colorHex: "#FF6B6B"),
        Tag(name: "solo", colorHex: "#3498DB"),
        Tag(name: "group", colorHex: "#27AE60"),
        Tag(name: "outdoor", colorHex: "#27AE60"),
        Tag(name: "cozy", colorHex: "#C9A96E"),
        Tag(name: "lively", colorHex: "#F39C12"),
        Tag(name: "hidden gem", colorHex: "#9B59B6"),
        Tag(name: "must return", colorHex: "#E91E8C"),
        Tag(name: "brunch", colorHex: "#FF9800"),
        Tag(name: "late night", colorHex: "#1A237E"),
        Tag(name: "casual", colorHex: "#607D8B"),
        Tag(name: "upscale", colorHex: "#37474F"),
        Tag(name: "kid friendly", colorHex: "#00BCD4"),
        Tag(name: "dog friendly", colorHex: "#8D6E63"),
        Tag(name: "work friendly", colorHex: "#455A64"),
    ]
}

// MARK: - Spot

struct Spot: Identifiable, Codable {
    var id: UUID = UUID()

    // Place info
    var name: String
    var address: String
    var coordinate: SpotCoordinate
    var category: SpotCategory
    var googlePlaceId: String?
    var phoneNumber: String?
    var website: String?

    // Google data
    var googleRating: Double?
    var googleReviewCount: Int?
    var priceLevel: Int?      // 1-4

    // User data
    var userRating: Int?      // 1-5 stars
    var tags: [Tag]
    var notes: String
    var savedAt: Date = Date()

    // Derived
    var coordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    var priceLevelString: String {
        guard let p = priceLevel else { return "" }
        return String(repeating: "$", count: p)
    }
}

struct SpotCoordinate: Codable {
    var latitude: Double
    var longitude: Double
}

// MARK: - Place Search Result (from Google / MapKit)

struct PlaceResult: Identifiable {
    var id: String          // place ID or map item hash
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
    var category: SpotCategory
    var googleRating: Double?
    var googleReviewCount: Int?
    var priceLevel: Int?
    var phoneNumber: String?
    var website: String?
    var suggestedTags: [Tag]
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toHex() -> String {
        let uic = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uic.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
