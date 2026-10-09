import SwiftUI

@main
public struct StillFantasyiPadApp: App {
    @StateObject private var appState = AppState()

    public init() {}

    public var body: some Scene {
        WindowGroup {
            MainLayoutView()
                .environmentObject(appState)
                #if os(macOS)
                .frame(minWidth: 1024, minHeight: 768)
                #endif
        }
    }
}
