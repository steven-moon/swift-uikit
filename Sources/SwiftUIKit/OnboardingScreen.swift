import SwiftUI

/// A full onboarding flow for MLXEngine-powered apps.
///
/// - Guides the user through welcome, features, and style selection.
/// - Uses OnboardingBanner and StyleGallery.
/// - Persists onboarding completion and style choice.
public struct OnboardingScreen: View {
    @AppStorage("UIAI.hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("UIAI.selectedStyleKind") private var selectedStyleKindRaw: String = UIAIStyleKind.minimal.rawValue
    @AppStorage("UIAI.selectedColorScheme") private var selectedColorSchemeRaw: String = UIAIColorScheme.light.rawValue
    @State private var step: Int = 0
    @State private var pickedStyleKind: UIAIStyleKind = .minimal
    @State private var pickedColorScheme: UIAIColorScheme = .light

    public init() {}

    public var body: some View {
        if hasSeenOnboarding {
            EmptyView()
        } else {
            VStack(spacing: 32) {
                Spacer()
                Group {
                    switch step {
                    case 0:
                        OnboardingBanner(
                            title: "Welcome to SummaCoding Companion!",
                            message: "Your all-in-one AI, Git, and project management tool for Apple platforms."
                        )
                    case 1:
                        OnboardingBanner(
                            title: "Features",
                            message: "• Chat with AI\n• Manage projects\n• GitHub integration\n• Customizable styles"
                        )
                    case 2:
                        VStack(spacing: 16) {
                            Text("Choose Your Style")
                                .font(.title2).bold()
                            StyleGalleryPicker(
                                pickedStyleKind: $pickedStyleKind,
                                pickedColorScheme: $pickedColorScheme
                            )
                        }
                    case 3:
                        OnboardingBanner(
                            title: "You're Ready!",
                            message: "Enjoy exploring SummaCoding Companion. You can change your style anytime in Settings."
                        )
                    default:
                        EmptyView()
                    }
                }
                Spacer()
                HStack {
                    if step > 0 {
                        Button("Back") { step -= 1 }
                    }
                    Spacer()
                    Button(step == 3 ? "Get Started" : "Continue") {
                        if step == 2 {
                            // Persist style choice
                            selectedStyleKindRaw = pickedStyleKind.rawValue
                            selectedColorSchemeRaw = pickedColorScheme.rawValue
                        }
                        if step < 3 {
                            step += 1
                        } else {
                            hasSeenOnboarding = true
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .frame(maxWidth: 480)
            .uiaiStyle(UIAIStyleRegistry.style(for: pickedStyleKind, colorScheme: pickedColorScheme))
            .animation(.easeInOut, value: step)
        }
    }
}

struct StylePair: Hashable {
    let kind: UIAIStyleKind
    let scheme: UIAIColorScheme
}

/// A style picker using StyleGallery for onboarding.
struct StyleGalleryPicker: View {
    @Binding var pickedStyleKind: UIAIStyleKind
    @Binding var pickedColorScheme: UIAIColorScheme

    private let stylePairs: [StylePair] = {
        var pairs: [StylePair] = []
        for kind in UIAIStyleKind.allCases {
            for scheme in UIAIColorScheme.allCases {
                pairs.append(StylePair(kind: kind, scheme: scheme))
            }
        }
        return pairs
    }()

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(stylePairs, id: \.self) { pair in
                    let style = UIAIStyleRegistry.style(for: pair.kind, colorScheme: pair.scheme)
                    VStack(spacing: 8) {
                        ZStack(alignment: .topTrailing) {
                            RoundedRectangle(cornerRadius: style.cornerRadius)
                                .fill(style.backgroundColor)
                                .frame(width: 180, height: 180)
                                .overlay(
                                    RoundedRectangle(cornerRadius: style.cornerRadius)
                                        .stroke(style.accentColor.opacity(0.3), lineWidth: 2)
                                )
                                .shadow(radius: 4)
                                .onTapGesture {
                                    pickedStyleKind = pair.kind
                                    pickedColorScheme = pair.scheme
                                }
                            if pickedStyleKind == pair.kind && pickedColorScheme == pair.scheme {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(style.accentColor)
                                    .padding(8)
                            }
                        }
                        Text("\(pair.kind.rawValue.capitalized) / \(pair.scheme.displayName)")
                            .font(.caption)
                            .foregroundColor(style.foregroundColor)
                    }
                    .padding(4)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

#if DEBUG
struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen()
            .uiaiStyle(MinimalStyle(colorScheme: .light))
    }
}
#endif 