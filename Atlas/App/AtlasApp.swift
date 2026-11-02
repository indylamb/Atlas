import SwiftUI
import CoreLocation

@main
struct AtlasApp: App {
    @State private var store = AtlasStore()
    private let location = CLLocationManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(store)
                .tint(Theme.Palette.ink)
                .onAppear { location.requestWhenInUseAuthorization() }
        }
    }
}
