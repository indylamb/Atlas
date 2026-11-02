import Foundation
import Observation

/// The single source of Atlas data. Slice 1 runs on `SampleData`; slice 2 swaps in Supabase
/// behind these same methods so the screens don't change.
@Observable
final class AtlasStore {
    private(set) var me: Person
    private(set) var friends: [Person]
    private(set) var places: [String: Place]
    /// Every visible take, keyed by place id. Your own take has `personID == Person.meID`.
    private(set) var takes: [String: [Take]]
    private(set) var incoming: [IncomingMap]

    init(sample: SampleData = SampleData()) {
        me = sample.me
        friends = sample.friends
        places = Dictionary(uniqueKeysWithValues: sample.places.map { ($0.id, $0) })
        takes = sample.takes
        incoming = sample.incoming
    }

    // MARK: Reading

    var everyone: [Person] { [me] + friends }

    func person(_ id: String) -> Person? {
        id == me.id ? me : friends.first { $0.id == id }
    }

    func place(_ id: String) -> Place? { places[id] }

    func takes(for placeID: String) -> [Take] { takes[placeID] ?? [] }

    func myTake(_ placeID: String) -> Take? {
        takes(for: placeID).first { $0.personID == me.id }
    }

    func friendTakes(_ placeID: String) -> [Take] {
        takes(for: placeID).filter { $0.personID != me.id }
    }

    func isSaved(_ placeID: String) -> Bool { myTake(placeID) != nil }

    var unreadCount: Int { incoming.filter(\.isNew).count }

    /// How many places each person has saved, for the filters panel.
    func savedCount(_ personID: String) -> Int {
        takes.values.filter { list in list.contains { $0.personID == personID } }.count
    }

    var allTags: [String] {
        Array(Set(places.values.flatMap(\.tags))).sorted()
    }

    // MARK: Your takes

    /// Save a place with no rating (Haven't been).
    func save(_ placeID: String) {
        guard !isSaved(placeID) else { return }
        takes[placeID, default: []].append(Take(personID: me.id, rating: 0))
    }

    func unsave(_ placeID: String) {
        takes[placeID]?.removeAll { $0.personID == me.id }
    }

    func toggleSaved(_ placeID: String) {
        isSaved(placeID) ? unsave(placeID) : save(placeID)
    }

    /// Rating a place also saves it.
    func setRating(_ rating: Double, for placeID: String) {
        updateMyTake(placeID) { $0.rating = rating }
    }

    func setNote(_ note: String, for placeID: String) {
        updateMyTake(placeID) { $0.note = note }
    }

    private func updateMyTake(_ placeID: String, _ change: (inout Take) -> Void) {
        save(placeID)
        guard let index = takes[placeID]?.firstIndex(where: { $0.personID == me.id }) else { return }
        change(&takes[placeID]![index])
    }

    // MARK: Places from Apple Maps

    /// Adds a place found on the map (no one has saved it yet) so the sheet can show it.
    func addPlace(_ place: Place) -> Place {
        if let match = places.values.first(where: { $0.name == place.name && abs($0.latitude - place.latitude) < 0.0015 && abs($0.longitude - place.longitude) < 0.0015 }) {
            return match
        }
        places[place.id] = place
        return place
    }

    // MARK: Sending and receiving

    /// Opening a map reveals the sender's takes as a friend layer.
    func open(_ mapID: String) {
        guard let index = incoming.firstIndex(where: { $0.id == mapID }) else { return }
        incoming[index].isNew = false
        let map = incoming[index]
        for (placeID, take) in map.takes where !takes(for: placeID).contains(where: { $0.personID == take.personID }) {
            takes[placeID, default: []].append(take)
        }
    }

    /// Saves every listed place you don't already have. Returns how many were new.
    @discardableResult
    func saveAll(_ placeIDs: [String]) -> Int {
        let new = placeIDs.filter { !isSaved($0) }
        new.forEach(save)
        return new.count
    }

    /// Slice 1 only records the send locally. Slice 3 sends it for real.
    func send(placeIDs: [String], to recipientID: String) {
        print("[Atlas] would send \(placeIDs.count) places to \(recipientID)")
    }
}
