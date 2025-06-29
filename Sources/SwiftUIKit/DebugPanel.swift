//
//  DebugPanel.swift
//  UIAI
//
//  Created for MLXEngine Shared SwiftUI Library
//
//  A cross-platform SwiftUI diagnostics panel for logs, debug reports, and health checks.
//

import Foundation
import Logging
import SwiftUI

#if os(iOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

/// A SwiftUI diagnostics panel for logs, debug reports, and health checks.
///
/// - Designed for iOS, macOS, visionOS, tvOS, and watchOS.
/// - Integrates with MLXEngine diagnostics APIs.
public struct DebugPanel: View {
  @Environment(\.uiaiStyle) private var uiaiStyle: any UIAIStyle
  @State private var selectedLevels: [LogLevel] = [.error, .warning, .critical]
  @State private var recentLogs: [LogEntry] = []
  @State private var debugReport: String = ""
  @State private var isReportCopied = false
  @State private var isLoadingReport = false
  @State private var logLimit: Double = 50
  private let allLevels: [LogLevel] = [.debug, .info, .warning, .error, .critical]

  public init() {}

  public var body: some View {
    #if os(iOS) || os(macOS) || os(visionOS)
      VStack(alignment: .leading, spacing: 16) {
        Text("Debug Panel")
          .font(uiaiStyle.font)
          .fontWeight(.bold)
          .foregroundColor(uiaiStyle.foregroundColor)
        HStack {
          Text("Log Levels:")
          ForEach(allLevels, id: \.self) { level in
            Button(action: {
              if let idx = selectedLevels.firstIndex(of: level) {
                selectedLevels.remove(at: idx)
              } else {
                selectedLevels.append(level)
              }
              loadLogs()
            }) {
              Text(level.rawValue.capitalized)
                .font(.caption)
                .padding(6)
                .background(
                  selectedLevels.contains(level)
                    ? uiaiStyle.accentColor.opacity(0.2) : uiaiStyle.backgroundColor
                )
                .cornerRadius(uiaiStyle.cornerRadius)
            }
          }
        }
        HStack {
          Text("Show last \(Int(logLimit)) logs")
          Slider(value: $logLimit, in: 10...200, step: 10) { _ in loadLogs() }
            .frame(width: 160)
        }
        Divider()
        ScrollView {
          VStack(alignment: .leading, spacing: 4) {
            ForEach(recentLogs) { log in
              HStack(alignment: .top, spacing: 8) {
                Text("[\(log.level.rawValue.uppercased())]")
                  .font(.caption2)
                  .foregroundColor(color(for: log.level))
                Text(log.message)
                  .font(.caption)
                  .foregroundColor(uiaiStyle.secondaryForegroundColor)
              }
            }
          }
          .padding(.vertical, 4)
        }
        Divider()
        HStack {
          Button(action: generateReport) {
            Label("Generate Debug Report", systemImage: "doc.text.magnifyingglass")
          }
          if !debugReport.isEmpty {
            Button(action: copyReport) {
              Label(isReportCopied ? "Copied!" : "Copy Report", systemImage: "doc.on.doc")
            }
          }
        }
        if isLoadingReport {
          ProgressView("Generating report...")
        }
        if !debugReport.isEmpty {
          ScrollView {
            Text(debugReport)
              .font(.caption2)
              .padding(8)
              .background(uiaiStyle.backgroundColor.opacity(0.5))
              .cornerRadius(8)
              .contextMenu {
                Button("Copy Report") { copyReport() }
              }
          }
          .frame(maxHeight: 200)
        }
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: uiaiStyle.cornerRadius).fill(uiaiStyle.backgroundColor)
      )
      .onAppear(perform: loadLogs)
    #else
      Text("Debug panel is not yet available on this platform.")
        .foregroundColor(uiaiStyle.secondaryForegroundColor)
    #endif
  }

  private func loadLogs() {
    recentLogs = AppLogger.shared.recentLogs(limit: Int(logLimit), levels: selectedLevels)
  }

  private func generateReport() {
    isLoadingReport = true
    Task {
      let report = await DebugUtility.shared.generateDebugReport(
        onlyErrorsAndWarnings: selectedLevels.contains(.error) || selectedLevels.contains(.critical)
          || selectedLevels.contains(.warning))
      await MainActor.run {
        debugReport = report
        isLoadingReport = false
        isReportCopied = false
      }
    }
  }

  private func copyReport() {
    #if os(iOS)
      UIPasteboard.general.string = debugReport
    #elseif os(macOS)
      NSPasteboard.general.clearContents()
      NSPasteboard.general.setString(debugReport, forType: .string)
    #endif
    isReportCopied = true
  }

  private func color(for level: LogLevel) -> Color {
    uiaiStyle.logLevelColor(for: level.rawValue)
  }
}

#if DEBUG
  struct DebugPanel_Previews: PreviewProvider {
    static var previews: some View {
      DebugPanel()
        .frame(width: 400, height: 500)
        .uiaiStyle(MinimalStyle(colorScheme: .light))
    }
  }
#endif

public struct DebugPanelView: View {
  @ObservedObject var info = DebugInfoProvider.shared
  @Environment(\.dismiss) private var dismiss

  public init() {}

  public var body: some View {
    NavigationView {
      List {
        Section(header: Text("Build Info")) {
          HStack {
            Text("Build Hash")
            Spacer()
            Text(info.buildHash).font(.caption).foregroundColor(.secondary)
          }
          HStack {
            Text("Build Date")
            Spacer()
            Text(info.buildDate).font(.caption).foregroundColor(.secondary)
          }
          HStack {
            Text("App Version")
            Spacer()
            Text(info.appVersion).font(.caption).foregroundColor(.secondary)
          }
          HStack {
            Text("SwiftUIKit Version")
            Spacer()
            Text(info.swiftUIKitVersion).font(.caption).foregroundColor(.secondary)
          }
          HStack {
            Text("Bundle ID")
            Spacer()
            Text(info.bundleID).font(.caption).foregroundColor(.secondary)
          }
        }
        Section(header: Text("Device Info")) {
          HStack {
            Text("Device")
            Spacer()
            Text(info.deviceModel).font(.caption).foregroundColor(.secondary)
          }
          HStack {
            Text("OS Version")
            Spacer()
            Text(info.osVersion).font(.caption).foregroundColor(.secondary)
          }
          HStack {
            Text("Locale")
            Spacer()
            Text(info.locale).font(.caption).foregroundColor(.secondary)
          }
          HStack {
            Text("Screen Size")
            Spacer()
            Text(info.screenSize).font(.caption).foregroundColor(.secondary)
          }
          HStack {
            Text("Simulator")
            Spacer()
            Text(info.isSimulator ? "Yes" : "No").font(.caption).foregroundColor(.secondary)
          }
          HStack {
            Text("Debug Build")
            Spacer()
            Text(info.isDebug ? "Yes" : "No").font(.caption).foregroundColor(.secondary)
          }
        }
        Section(header: Text("Logs")) {
          ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 2) {
              ForEach(info.logs, id: \.self) { log in
                Text(log).font(.caption2).foregroundColor(.primary)
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
          .frame(minHeight: 120, maxHeight: 240)
          Button("Copy All Logs") {
            #if os(iOS)
              UIPasteboard.general.string = info.logs.joined(separator: "\n")
            #elseif os(macOS)
              NSPasteboard.general.clearContents()
              NSPasteboard.general.setString(info.logs.joined(separator: "\n"), forType: .string)
            #endif
          }
          Button("Clear Logs") {
            info.clearLogs()
          }
        }
      }
      .navigationTitle("Debug Panel")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Close") { dismiss() }
        }
        ToolbarItem(placement: .primaryAction) {
          Button("Copy Info") {
            let all =
              "Build Hash: \(info.buildHash)\nBuild Date: \(info.buildDate)\nApp Version: \(info.appVersion)\nSwiftUIKit: \(info.swiftUIKitVersion)\nBundle: \(info.bundleID)\nDevice: \(info.deviceModel)\nOS: \(info.osVersion)\nLocale: \(info.locale)\nScreen: \(info.screenSize)\nSimulator: \(info.isSimulator)\nDebug: \(info.isDebug)"
            #if os(iOS)
              UIPasteboard.general.string = all
            #elseif os(macOS)
              NSPasteboard.general.clearContents()
              NSPasteboard.general.setString(all, forType: .string)
            #endif
          }
        }
      }
    }
  }
}

public struct UserDebugPanelView: View {
  @ObservedObject var info = DebugInfoProvider.shared
  @Environment(\.dismiss) private var dismiss
  public init() {}
  public var body: some View {
    NavigationView {
      List {
        Section(header: Text("Build Info")) {
          HStack {
            Text("Build Hash")
            Spacer()
            Text(info.buildHash).font(.caption).foregroundColor(.secondary)
          }
          HStack {
            Text("App Version")
            Spacer()
            Text(info.appVersion).font(.caption).foregroundColor(.secondary)
          }
        }
      }
      .navigationTitle("App Info")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Close") { dismiss() }
        }
        ToolbarItem(placement: .primaryAction) {
          Button("Copy Info") {
            let all = "Build Hash: \(info.buildHash)\nApp Version: \(info.appVersion)"
            #if os(iOS)
              UIPasteboard.general.string = all
            #elseif os(macOS)
              NSPasteboard.general.clearContents()
              NSPasteboard.general.setString(all, forType: .string)
            #endif
          }
        }
      }
    }
  }
}
