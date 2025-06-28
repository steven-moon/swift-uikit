import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Provides runtime debug/build info for SwiftUIKit apps.
public final class DebugInfoProvider: ObservableObject {
    public static let shared = DebugInfoProvider()
    
    @Published public private(set) var buildHash: String = ""
    @Published public private(set) var buildDate: String = ""
    @Published public private(set) var appVersion: String = ""
    @Published public private(set) var bundleID: String = ""
    @Published public private(set) var deviceModel: String = ""
    @Published public private(set) var osVersion: String = ""
    @Published public private(set) var locale: String = ""
    @Published public private(set) var screenSize: String = ""
    @Published public private(set) var swiftUIKitVersion: String = "1.0.0"
    @Published public private(set) var isSimulator: Bool = false
    @Published public private(set) var isDebug: Bool = false
    @Published public private(set) var logs: [String] = []
    
    private init() {
        refresh()
    }
    
    public func refresh() {
        // Build hash and date
        buildHash = (Bundle.main.infoDictionary?["BuildHash"] as? String) ?? "N/A"
        buildDate = (Bundle.main.infoDictionary?["BuildDate"] as? String) ?? "N/A"
        appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
        bundleID = Bundle.main.bundleIdentifier ?? "N/A"
        locale = Locale.current.identifier

        #if canImport(UIKit)
        deviceModel = UIDevice.current.model
        osVersion = UIDevice.current.systemVersion
        let size = UIScreen.main.bounds.size
        screenSize = "\(Int(size.width))x\(Int(size.height))"
        #else
        deviceModel = "macOS"
        osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        screenSize = "N/A"
        #endif

        #if targetEnvironment(simulator)
        isSimulator = true
        #else
        isSimulator = false
        #endif
        #if DEBUG
        isDebug = true
        #else
        isDebug = false
        #endif
    }
    
    public func addLog(_ message: String) {
        DispatchQueue.main.async {
            self.logs.append(message)
            if self.logs.count > 200 { self.logs.removeFirst(self.logs.count - 200) }
        }
    }
    
    public func clearLogs() {
        logs.removeAll()
    }
} 