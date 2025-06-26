import SwiftUI
import SwiftUIKit

struct ContentView: View {
    var body: some View {
        #if os(watchOS)
        List {
            NavigationLink("Chat", destination: ChatView().uiaiStyle(MinimalStyle(colorScheme: .light)))
            NavigationLink("Models", destination: ModelDiscoveryView().uiaiStyle(MinimalStyle(colorScheme: .light)))
            NavigationLink("Settings", destination: SettingsPanel(selectedStyleKindRaw: .constant(UIAIStyleKind.minimal.rawValue), selectedColorSchemeRaw: .constant(UIAIColorScheme.light.rawValue)).uiaiStyle(MinimalStyle(colorScheme: .light)))
            NavigationLink("Styles", destination: StyleGallery().uiaiStyle(MinimalStyle(colorScheme: .light)))
        }
        .navigationTitle("SwiftUIKit Demo")
        #else
        TabView {
            ChatView()
                .tabItem { Label("Chat", systemImage: "bubble.left.and.bubble.right") }
                .uiaiStyle(MinimalStyle(colorScheme: .light))
            ModelDiscoveryView()
                .tabItem { Label("Models", systemImage: "cube") }
                .uiaiStyle(MinimalStyle(colorScheme: .light))
            SettingsPanel(selectedStyleKindRaw: .constant(UIAIStyleKind.minimal.rawValue), selectedColorSchemeRaw: .constant(UIAIColorScheme.light.rawValue))
                .tabItem { Label("Settings", systemImage: "gear") }
                .uiaiStyle(MinimalStyle(colorScheme: .light))
            StyleGallery()
                .tabItem { Label("Styles", systemImage: "paintpalette") }
                .uiaiStyle(MinimalStyle(colorScheme: .light))
        }
        #endif
    }
}

#if DEBUG
#Preview {
    ContentView()
}
#endif 