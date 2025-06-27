import SwiftUI
import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct AppearanceSettingsView: View {
    @Binding public var selectedStyleKindRaw: String
    @Binding public var selectedColorSchemeRaw: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempStyleKind: UIAIStyleKind?
    @State private var tempColorScheme: UIAIColorScheme?
    
    private var styleKinds: [UIAIStyleKind] = UIAIStyleKind.allCases
    private var colorSchemes: [UIAIColorScheme] = UIAIColorScheme.allCases
    
    private var selectedStyleKind: UIAIStyleKind {
        get { UIAIStyleKind(rawValue: selectedStyleKindRaw) ?? .minimal }
        set { selectedStyleKindRaw = newValue.rawValue }
    }
    
    private var selectedColorScheme: UIAIColorScheme {
        get { UIAIColorScheme(rawValue: selectedColorSchemeRaw) ?? .light }
        set { selectedColorSchemeRaw = newValue.rawValue }
    }
    
    private var currentStyle: any UIAIStyle {
        UIAIStyleRegistry.style(for: selectedStyleKind, colorScheme: selectedColorScheme)
    }
    
    public init(selectedStyleKindRaw: Binding<String>, selectedColorSchemeRaw: Binding<String>) {
        self._selectedStyleKindRaw = selectedStyleKindRaw
        self._selectedColorSchemeRaw = selectedColorSchemeRaw
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            header
            stylePicker
            colorSchemePicker
            Spacer()
            actionButtons
        }
        .background(systemGroupedBackgroundColor.ignoresSafeArea())
        .onAppear {
            tempStyleKind = selectedStyleKind
            tempColorScheme = selectedColorScheme
        }
    }
    
    private var header: some View {
        Text("Appearance")
            .font(.title.bold())
            .padding(.top, 16)
    }
    
    private var stylePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(styleKinds, id: \.self) { kind in
                    styleButton(for: kind)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var colorSchemePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(colorSchemes, id: \.self) { scheme in
                    colorSchemeButton(for: scheme)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: {
                tempStyleKind = nil
                tempColorScheme = nil
                selectedStyleKindRaw = UIAIStyleKind.minimal.rawValue
                selectedColorSchemeRaw = UIAIColorScheme.light.rawValue
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset")
                }
                .foregroundColor(.red)
            }
            Spacer()
            Button(action: {
                if let kind = tempStyleKind {
                    selectedStyleKindRaw = kind.rawValue
                }
                if let scheme = tempColorScheme {
                    selectedColorSchemeRaw = scheme.rawValue
                }
                dismiss()
            }) {
                Text("Use this style")
                    .fontWeight(.semibold)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            Button(action: {
                dismiss()
            }) {
                Text("Done")
                    .fontWeight(.regular)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(systemGray5Color)
                    .foregroundColor(.primary)
                    .cornerRadius(12)
            }
        }
        .padding(24)
        .background(systemBackgroundColor)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
    }
    
    private func styleButton(for kind: UIAIStyleKind) -> some View {
        Button {
            tempStyleKind = kind
        } label: {
            HStack(spacing: 8) {
                Image(systemName: kind.iconName)
                    .foregroundColor(kind == (tempStyleKind ?? selectedStyleKind) ? .white : .primary)
                Text(kind.displayName)
                    .font(.headline)
                    .foregroundColor(kind == (tempStyleKind ?? selectedStyleKind) ? .white : .primary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 18)
            .background(kind == (tempStyleKind ?? selectedStyleKind) ? Color.accentColor : systemGray6Color)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(kind == (tempStyleKind ?? selectedStyleKind) ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .shadow(color: kind == (tempStyleKind ?? selectedStyleKind) ? Color.accentColor.opacity(0.2) : .clear, radius: 4, x: 0, y: 2)
        }
    }
    
    private func colorSchemeButton(for scheme: UIAIColorScheme) -> some View {
        Button {
            tempColorScheme = scheme
        } label: {
            VStack {
                Text(scheme.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(systemGray5Color)
            .foregroundColor(.primary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(tempColorScheme == scheme ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Platform Colors
private extension AppearanceSettingsView {
    var systemGroupedBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGroupedBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.secondary.opacity(0.2)
        #endif
    }
    
    var systemBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.white
        #endif
    }
    
    var systemGray5Color: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGray5)
        #elseif canImport(AppKit)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color.gray.opacity(0.2)
        #endif
    }
    
    var systemGray6Color: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGray6)
        #elseif canImport(AppKit)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }
}

#Preview {
    AppearanceSettingsView(
        selectedStyleKindRaw: .constant(UIAIStyleKind.minimal.rawValue),
        selectedColorSchemeRaw: .constant(UIAIColorScheme.light.rawValue)
    )
}

// MARK: - Helpers for display names and icons

extension UIAIStyleKind {
    var displayName: String {
        switch self {
        case .minimal: return "Minimal"
        case .liquidGlass: return "Liquid Glass"
        case .skeuomorphic: return "Skeuomorphic"
        }
    }
    var iconName: String {
        switch self {
        case .minimal: return "rectangle"
        case .liquidGlass: return "sparkles"
        case .skeuomorphic: return "circle.lefthalf.filled"
        }
    }
} 