import SwiftUI

@main
public struct StillFantasyiPadApp: App {
    public init() {}

    public var body: some Scene {
        WindowGroup {
            MainLayoutView()
                #if os(macOS)
                .frame(minWidth: 1024, minHeight: 768)
                #endif
        }
    }
}
