import Foundation
import CoreLocation

/// Everything the Filters panel controls.
struct FilterState: Equatable {
    enum RatingFilter: Hashable { case any, goodPlus, mustHit }
    enum Who: Hashable { case everyone, me, friends }

    var tags: Set<String> = []
    var matchAll = false
    var rating: RatingFilter = .any
    var showHaventBeen = true
    var showSkip = false
    var who: Who = .everyone
    var hiddenPeople: Set<String> = []
    /// Apple Maps places no one you know has saved.
    var showUnsaved = true

    /// Shown on the Filters button badge.
    var activeCount: Int {
        var count = tags.count + hiddenPeople.count
        if rating != .any { count += 1 }
        if who != .everyone { count += 1 }
        if !showHaventBeen { count += 1 }
        if showSkip { count += 1 }
        if !showUnsaved { count += 1 }
        return count
    }
}

/// One person's dot on a pin.
struct PinDot: Hashable, Identifiable {
    let personID: String
    let isMe: Bool
    var id: String { personID }
}

/// A pin on the map. Several dots means several people saved it.
struct AtlasPin: Identifiable, Hashable {
    let placeID: String
    let latitude: Double
    let longitude: Double
    let category: PlaceCategory
    let dots: [PinDot]
    let isMustHit: Bool
    /// Every visible take is unrated, so the pin is drawn as an outline.
    let isHaventBeen: Bool
    /// In receive mode: you already have this place.
    let isOnMyMap: Bool
    /// In send mode: not yours, so it won't be sent.
    let isDimmed: Bool

    var id: String { placeID }
    var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
}

/// Decides which pins show. Pure logic, no SwiftUI, so it can be unit tested.
enum MapFilter {

    /// Your map: your spots plus friends' spots, filtered.
    static func pins(store: AtlasStore, filter: FilterState, sending: Bool) -> [AtlasPin] {
        store.places.values.compactMap { place -> AtlasPin? in
            guard matchesTags(place, filter) else { return nil }
            let visible = store.takes(for: place.id).filter { isVisible($0, store: store, filter: filter) }
            guard !visible.isEmpty else { return nil }
            let best = visible.map(\.rating).max() ?? 0
            guard passesRating(best, filter) else { return nil }
            let ordered = visible.sorted { a, b in a.personID == store.me.id && b.personID != store.me.id }
            let mine = ordered.first?.personID == store.me.id
            return AtlasPin(
                placeID: place.id, latitude: place.latitude, longitude: place.longitude, category: place.category,
                dots: ordered.map { PinDot(personID: $0.personID, isMe: $0.personID == store.me.id) },
                isMustHit: RatingLabel(rating: best) == .mustHit,
                isHaventBeen: best == 0,
                isOnMyMap: false,
                isDimmed: sending && !mine
            )
        }
        .sorted { $0.placeID < $1.placeID }
    }

    /// A friend's map you're viewing: only their spots, filtered by tags and rating.
    static func receivedPins(store: AtlasStore, map: IncomingMap, filter: FilterState) -> [AtlasPin] {
        receivedPlaceIDs(store: store, map: map, filter: filter).compactMap { id in
            guard let place = store.place(id), let take = map.takes[id] else { return nil }
            return AtlasPin(
                placeID: id, latitude: place.latitude, longitude: place.longitude, category: place.category,
                dots: [PinDot(personID: map.fromID, isMe: false)],
                isMustHit: RatingLabel(rating: take.rating) == .mustHit,
                isHaventBeen: take.rating == 0,
                isOnMyMap: store.isSaved(id),
                isDimmed: false
            )
        }
    }

    /// The places in a received map that pass the current filters. "Save all" saves these.
    static func receivedPlaceIDs(store: AtlasStore, map: IncomingMap, filter: FilterState) -> [String] {
        map.placeIDs.filter { id in
            guard let place = store.place(id), let take = map.takes[id] else { return false }
            return matchesTags(place, filter) && passesRating(take.rating, filter)
        }
    }

    // MARK: Rules

    static func matchesTags(_ place: Place, _ filter: FilterState) -> Bool {
        guard !filter.tags.isEmpty else { return true }
        let placeTags = Set(place.tags)
        return filter.matchAll ? filter.tags.isSubset(of: placeTags) : !filter.tags.isDisjoint(with: placeTags)
    }

    static func isVisible(_ take: Take, store: AtlasStore, filter: FilterState) -> Bool {
        guard !filter.hiddenPeople.contains(take.personID) else { return false }
        let isMine = take.personID == store.me.id
        switch filter.who {
        case .everyone: return true
        case .me: return isMine
        case .friends: return !isMine
        }
    }

    /// Applies the rating rules to the best visible rating for a place.
    static func passesRating(_ best: Double, _ filter: FilterState) -> Bool {
        switch RatingLabel(rating: best) {
        case .haventBeen: return filter.showHaventBeen && filter.rating == .any
        case .skip: return filter.showSkip && filter.rating == .any
        case .good: return filter.rating != .mustHit
        case .mustHit: return true
        }
    }
}
