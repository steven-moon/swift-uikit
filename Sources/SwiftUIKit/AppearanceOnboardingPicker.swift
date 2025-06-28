import SwiftUI

public struct AppearanceOnboardingPicker: View {
    @Binding public var tempStyleKind: UIAIStyleKind
    @Binding public var tempColorScheme: UIAIColorScheme
    @Environment(\.uiaiStyle) private var style
    
    private var styleKinds: [UIAIStyleKind] = UIAIStyleKind.allCases
    private var colorSchemes: [UIAIColorScheme] = UIAIColorScheme.allCases
    
    public init(tempStyleKind: Binding<UIAIStyleKind>, tempColorScheme: Binding<UIAIColorScheme>) {
        self._tempStyleKind = tempStyleKind
        self._tempColorScheme = tempColorScheme
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Style picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Branding Style")
                    .font(.subheadline.bold())
                    .foregroundColor(style.foregroundColor)
                let columns = [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ]
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(styleKinds, id: \ .self) { kind in
                        let isSelected = tempStyleKind == kind
                        Button(action: { tempStyleKind = kind }) {
                            stylePreviewCard(for: kind, isSelected: isSelected)
                                .frame(width: 120, height: 70)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            // Color scheme picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Color Scheme")
                    .font(.subheadline.bold())
                    .foregroundColor(style.foregroundColor)
                VStack(spacing: 14) {
                    ForEach(colorSchemes, id: \ .self) { scheme in
                        let isSelected = tempColorScheme == scheme
                        Button(action: { tempColorScheme = scheme }) {
                            HStack(alignment: .center, spacing: 16) {
                                colorSchemeSwatch(for: scheme, isSelected: isSelected)
                                    .frame(width: 24, height: 24)
                                Text(scheme.displayName)
                                    .font(.system(size: 15, weight: .medium))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(style.foregroundColor)
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .foregroundColor(style.accentColor)
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.leading, 8)
                            .padding(.trailing, 8)
                            .background(isSelected ? style.accentColor.opacity(0.08) : Color.clear)
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .background(Color.clear)
        .uiaiStyle(style)
    }
    
    // MARK: - Style Preview Card
    private func stylePreviewCard(for kind: UIAIStyleKind, isSelected: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(UIAIStyleRegistry.style(for: kind, colorScheme: tempColorScheme).backgroundColor)
                    .frame(width: 56, height: 36)
                    .shadow(color: isSelected ? style.accentColor.opacity(0.18) : .clear, radius: 4, x: 0, y: 2)
                    .overlay(
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(UIAIStyleRegistry.style(for: kind, colorScheme: tempColorScheme).accentColor)
                                .frame(height: 6)
                                .cornerRadius(3)
                            Spacer()
                            Text("Aa")
                                .font(.headline)
                                .foregroundColor(UIAIStyleRegistry.style(for: kind, colorScheme: tempColorScheme).foregroundColor)
                        }
                        .padding(4)
                    )
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(style.accentColor)
                        .offset(x: 6, y: -6)
                }
            }
        }
    }
    
    // MARK: - Color Scheme Swatch
    private func colorSchemeSwatch(for scheme: UIAIColorScheme, isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(scheme == .dark ? Color.black : Color.white)
                .overlay(
                    Circle()
                        .stroke(isSelected ? style.accentColor : style.secondaryForegroundColor.opacity(0.2), lineWidth: 2)
                )
            if scheme == .dark {
                Image(systemName: "moon.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)
            } else {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
            }
        }
    }
} 