import SwiftUI

/// A SwiftUI view that showcases all built-in UIAI styles and color schemes.
public struct StyleGallery: View {
  public init() {}
  public var body: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 24)], spacing: 24) {
        ForEach(UIAIStyleKind.allCases, id: \.self) { kind in
          ForEach(UIAIColorScheme.allCases, id: \.self) { scheme in
            stylePreview(kind: kind, scheme: scheme)
          }
        }
      }
      .padding()
    }
  }
  private func stylePreview(kind: UIAIStyleKind, scheme: UIAIColorScheme) -> some View {
    let style = UIAIStyleRegistry.style(for: kind, colorScheme: scheme)
    return VStack(spacing: 12) {
      HStack {
        Spacer()
        if let logo = style.logo {
          logo
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
        } else {
          Image(systemName: "sparkles")
            .resizable()
            .scaledToFit()
            .frame(width: 32, height: 32)
            .foregroundColor(style.accentColor)
        }
        Spacer()
      }
      Text("\(kind.rawValue.capitalized) / \(scheme.displayName)")
        .font(.headline)
        .foregroundColor(style.foregroundColor)
      ModelCardView(
        model: .init(
          id: "preview", name: "Preview Model", description: "A preview model.",
          statusMessage: "Ready", statusColor: style.successColor)
      )
      .frame(width: 220, height: 120)
      .uiaiStyle(style)
      ErrorBanner(message: "Preview error banner.", style: .error, isPresented: .constant(true))
        .uiaiStyle(style)
    }
    .padding()
    .background(style.backgroundColor)
    .cornerRadius(style.cornerRadius)
    .shadow(color: style.shadow?.color ?? .clear, radius: style.shadow?.radius ?? 0)
  }
}

#if DEBUG
  struct StyleGallery_Previews: PreviewProvider {
    static var previews: some View {
      StyleGallery()
        .uiaiStyle(MinimalStyle(colorScheme: .light))
    }
  }
#endif
