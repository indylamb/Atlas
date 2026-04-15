import SwiftUI

@main
struct AtlasApp: App {
    @StateObject private var spotManager = SpotManager()
    @StateObject private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(spotManager)
                .environmentObject(locationManager)
                .preferredColorScheme(.light)
        }
    }
}
