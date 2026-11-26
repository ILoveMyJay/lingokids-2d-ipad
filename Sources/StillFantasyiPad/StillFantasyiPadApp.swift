import SwiftUI

@main
public struct StillFantasyiPadApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var router = AppRouter()

    public init() {}

    public var body: some Scene {
        WindowGroup {
            MainLayoutView()
                .environmentObject(appState)
                .environmentObject(router)
                #if os(macOS)
                .frame(minWidth: 1024, minHeight: 768)
                #endif
        }
    }
}
