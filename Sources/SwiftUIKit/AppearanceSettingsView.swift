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
    @State private var showDebugPanel = false
    @State private var showApplyConfirmation = false
    
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
    
    private var previewStyle: any UIAIStyle {
        UIAIStyleRegistry.style(for: tempStyleKind ?? selectedStyleKind, colorScheme: tempColorScheme ?? selectedColorScheme)
    }
    
    private let buildHash = UUID().uuidString.prefix(8)
    
    public init(selectedStyleKindRaw: Binding<String>, selectedColorSchemeRaw: Binding<String>) {
        self._selectedStyleKindRaw = selectedStyleKindRaw
        self._selectedColorSchemeRaw = selectedColorSchemeRaw
    }
    
    public var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Style picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Branding Style")
                            .font(.subheadline.bold())
                            .padding(.leading)
                        let columns = [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ]
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(styleKinds, id: \.self) { kind in
                                let isSelected = (tempStyleKind ?? selectedStyleKind) == kind
                                Button(action: { tempStyleKind = kind }) {
                                    stylePreviewCard(for: kind, isSelected: isSelected)
                                        .frame(width: 140, height: 90)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    // Color scheme picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color Scheme")
                            .font(.subheadline.bold())
                            .padding(.leading)
                        VStack(spacing: 14) {
                            ForEach(colorSchemes, id: \.self) { scheme in
                                let isSelected = (tempColorScheme ?? selectedColorScheme) == scheme
                                Button(action: { tempColorScheme = scheme }) {
                                    HStack(alignment: .center, spacing: 16) {
                                        colorSchemeSwatch(for: scheme, isSelected: isSelected)
                                            .frame(width: 24, height: 24)
                                        Text(scheme.displayName)
                                            .font(.system(size: 15, weight: .medium))
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.primary)
                                        if isSelected {
                                            Image(systemName: "checkmark.circle.fill")
                                                .resizable()
                                                .frame(width: 18, height: 18)
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.leading, 12)
                                    .padding(.trailing, 10)
                                    .background(isSelected ? Color.accentColor.opacity(0.08) : Color.clear)
                                    .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    Spacer(minLength: 24)
                    HStack {
                        Spacer()
                        Text("Build #\(buildHash)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 8)
                    }
                    Button("Show Debug Panel (Developer)") {
                        showDebugPanel = true
                    }
                    .font(.caption)
                    .padding(.bottom, 8)
                    .sheet(isPresented: $showDebugPanel) {
                        DebugPanelView()
                    }
                }
                .padding(.vertical, 24)
            }
            .background(systemGroupedBackgroundColor.ignoresSafeArea())
            .onAppear {
                tempStyleKind = selectedStyleKind
                tempColorScheme = selectedColorScheme
                print("[SwiftUIKit] Build #\(buildHash)")
            }
            .safeAreaInset(edge: .bottom) {
                if (tempStyleKind != selectedStyleKind || tempColorScheme != selectedColorScheme) {
                    Button(action: {
                        if let newKind = tempStyleKind { selectedStyleKindRaw = newKind.rawValue }
                        if let newScheme = tempColorScheme { selectedColorSchemeRaw = newScheme.rawValue }
                        #if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        #endif
                        withAnimation {
                            showApplyConfirmation = true
                        }
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Apply Changes")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(radius: 4, y: 2)
                    }
                    .padding([.horizontal, .bottom], 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            // Confirmation toast/banner
            if showApplyConfirmation {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Label("Changes applied!", systemImage: "checkmark.seal.fill")
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .shadow(radius: 6)
                        Spacer()
                    }
                    .padding(.bottom, 40)
                }
                .transition(.opacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { showApplyConfirmation = false }
                    }
                }
            }
        }
    }
    
    // MARK: - Style Preview Card
    private func stylePreviewCard(for kind: UIAIStyleKind, isSelected: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(UIAIStyleRegistry.style(for: kind, colorScheme: tempColorScheme ?? selectedColorScheme).backgroundColor)
                    .frame(width: 64, height: 48)
                    .shadow(color: isSelected ? Color.accentColor.opacity(0.18) : .clear, radius: 6, x: 0, y: 2)
                    .overlay(
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(UIAIStyleRegistry.style(for: kind, colorScheme: tempColorScheme ?? selectedColorScheme).accentColor)
                                .frame(height: 8)
                                .cornerRadius(4)
                            Spacer()
                            Text("Aa")
                                .font(.headline)
                                .foregroundColor(UIAIStyleRegistry.style(for: kind, colorScheme: tempColorScheme ?? selectedColorScheme).foregroundColor)
                                .padding(.bottom, 6)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    )
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                        .background(Circle().fill(Color.white).frame(width: 22, height: 22))
                        .offset(x: 8, y: -8)
                }
            }
            Text(kind.displayName)
                .font(.footnote)
                .foregroundColor(isSelected ? .accentColor : .primary)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.accentColor.opacity(0.08) : systemGray6Color)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }
    
    // Swatch for color scheme
    private func colorSchemeSwatch(for scheme: UIAIColorScheme, isSelected: Bool) -> some View {
        Button(action: { tempColorScheme = scheme }) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(scheme == .light ? Color.white : Color.black)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.accentColor : Color.gray, lineWidth: 2)
                        )
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .background(Circle().fill(Color.white).frame(width: 18, height: 18))
                            .offset(x: 10, y: -10)
                    }
                }
                Text(scheme.displayName)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
    }
}

// Simple live chat preview for style
private struct ChatPreviewView: View {
    @Environment(\.uiaiStyle) private var style
    var body: some View {
        ZStack {
            style.backgroundColor
            VStack(spacing: 8) {
                HStack {
                    Circle().fill(style.accentColor).frame(width: 28, height: 28)
                    Text("You: Hello!")
                        .font(.body)
                        .foregroundColor(style.foregroundColor)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Text("AI: Hi there!")
                        .font(.body)
                        .foregroundColor(style.secondaryForegroundColor)
                    Circle().fill(style.accentColor).frame(width: 28, height: 28)
                }
            }
            .padding(.horizontal)
        }
        .cornerRadius(16)
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