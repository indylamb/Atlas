import Foundation
import MapKit
import Observation

/// UI state for the home map: what mode it's in, which panel or sheet is open, the filters.
@Observable
final class HomeModel {
    enum Mode: Equatable {
        case browsing
        /// The screen is outlined; everything of yours inside gets sent.
        case sending
        /// Viewing a map a friend sent you.
        case receiving(mapID: String)
    }

    enum Sheet: String, Identifiable {
        case spot, sendTo, receivedList
        var id: String { rawValue }
    }

    var mode: Mode = .browsing
    var filter = FilterState()
    /// Your filters, kept aside while you look at a friend's map.
    private var savedFilter = FilterState()

    var sheet: Sheet?
    var selectedPlaceID: String?
    /// What the Send sheet is sending: everything in the frame, or one spot.
    var sendPlaceIDs: [String] = []
    var sendTitle = ""

    var showFilters = false
    var showSendMenu = false
    var toast: String?
    var visibleRegion: MKCoordinateRegion?

    var receivingMapID: String? {
        if case .receiving(let id) = mode { return id }
        return nil
    }

    // MARK: Spots

    func openSpot(_ placeID: String) {
        showFilters = false
        showSendMenu = false
        selectedPlaceID = placeID
        sheet = .spot
    }

    func closeSheet() {
        sheet = nil
    }

    // MARK: Panels

    func toggleFilters() {
        showSendMenu = false
        showFilters.toggle()
    }

    func toggleSendMenu() {
        showFilters = false
        showSendMenu.toggle()
    }

    // MARK: Sending

    func startSending() {
        showSendMenu = false
        sheet = nil
        mode = .sending
    }

    func cancelSending() {
        mode = .browsing
        sheet = nil
    }

    func chooseRecipient(placeIDs: [String], title: String) {
        sendPlaceIDs = placeIDs
        sendTitle = title
        showFilters = false
        sheet = .sendTo
    }

    func finishSending(message: String) {
        sheet = nil
        mode = .browsing
        show(message)
    }

    // MARK: Receiving

    func startReceiving(_ mapID: String) {
        showSendMenu = false
        showFilters = false
        sheet = nil
        savedFilter = filter
        filter = FilterState()
        mode = .receiving(mapID: mapID)
    }

    func finishReceiving(message: String? = nil) {
        sheet = nil
        showFilters = false
        filter = savedFilter
        mode = .browsing
        if let message { show(message) }
    }

    // MARK: Toast

    func show(_ message: String) {
        toast = message
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(4))
            if self?.toast == message { self?.toast = nil }
        }
    }
}
