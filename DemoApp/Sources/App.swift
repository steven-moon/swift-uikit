import SwiftUI
import SwiftUIKit

@main
struct SwiftUIKitDemoApp: App {
    var body: some Scene {
        #if os(watchOS)
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
        #else
        WindowGroup {
            ContentView()
        }
        #endif
    }
} 