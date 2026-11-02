import Foundation
import CoreLocation
import SwiftUI

/// Someone on Atlas: you or a friend.
struct Person: Identifiable, Hashable {
    let id: String
    let name: String
    /// Index into `Theme.Palette.friends`. Ignored for you.
    let colorIndex: Int
    var isMe: Bool = false
    var isFullAccess: Bool = false

    var initial: String { String(name.prefix(1)) }
    var color: Color { isMe ? Theme.Palette.ink : Theme.Palette.friend(colorIndex) }

    static let meID = "me"
}

/// What kind of place it is. Drives the pin and tile icon.
enum PlaceCategory: String, Hashable, CaseIterable {
    case dinner, coffee, museum, park, bar, other

    /// Thin outline SF Symbol, in the Notion manner.
    var symbol: String {
        switch self {
        case .dinner: return "fork.knife"
        case .coffee: return "cup.and.saucer"
        case .museum: return "building.columns"
        case .park: return "tree"
        case .bar: return "wineglass"
        case .other: return "mappin"
        }
    }
}

/// A real-world location. Shared by everyone; a person's opinion of it is a `Take`.
struct Place: Identifiable, Hashable {
    let id: String
    var name: String
    var detail: String
    var category: PlaceCategory
    var latitude: Double
    var longitude: Double
    var tags: [String]

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// One person's relationship to one place.
struct Take: Hashable {
    let personID: String
    /// 0 means Haven't been. Otherwise 0.5 to 5 in half steps.
    var rating: Double
    var note: String = ""
}

/// The word a rating means. Stars are the input; this is the output.
enum RatingLabel: Hashable {
    case haventBeen, skip, good, mustHit

    init(rating: Double) {
        switch rating {
        case ..<0.25: self = .haventBeen
        case ..<2.75: self = .skip
        case ..<4.25: self = .good
        default: self = .mustHit
        }
    }

    var title: String {
        switch self {
        case .haventBeen: return "Haven\u{2019}t been"
        case .skip: return "Skip"
        case .good: return "Good"
        case .mustHit: return "Must hit"
        }
    }

    var color: Color {
        switch self {
        case .haventBeen, .skip: return Theme.Palette.inkMuted
        case .good: return Theme.Palette.ink
        case .mustHit: return Theme.Palette.ratingMust
        }
    }
}

/// A map a friend sent you.
struct IncomingMap: Identifiable, Hashable {
    let id: String
    let fromID: String
    var title: String
    var placeIDs: [String]
    /// The sender's takes on those places. Revealed in your friend layers once you open the map.
    var takes: [String: Take]
    var sentAt: Date
    var isNew: Bool
}
