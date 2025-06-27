//
//  ChatInputView.swift
//  UIAI
//
//  Created for MLXEngine Shared SwiftUI Library
//
//  A reusable SwiftUI view for chat input (text field + send button).
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// A SwiftUI view for chat input (text field + send button).
///
/// - Exposes the input text as a binding and provides a send action closure.
/// - Supports multi-line input and keyboard submit.
/// - Public, documented, and cross-platform.
public struct ChatInputView: View {
    @Binding public var text: String
    @Binding public var isGenerating: Bool
    public let onSend: () -> Void
    public let onStop: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    public init(text: Binding<String>, isGenerating: Binding<Bool>, onSend: @escaping () -> Void, onStop: @escaping () -> Void) {
        self._text = text
        self._isGenerating = isGenerating
        self.onSend = onSend
        self.onStop = onStop
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .bottom, spacing: 12) {
                TextField("Type a message...", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .focused($isTextFieldFocused)
                    .lineLimit(1...5)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(backgroundColor)
                    )
                
                if isGenerating {
                    Button(action: onStop) {
                        Image(systemName: "stop.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: onSend) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                    }
                    .buttonStyle(.plain)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .onSubmit {
            if !isGenerating && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                onSend()
            }
        }
    }

    private var backgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.secondarySystemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color.secondary.opacity(0.1)
        #endif
    }
}

#if DEBUG
struct ChatInputView_Previews: PreviewProvider {
    static var previews: some View {
        @State var text = ""
        @State var isGenerating = false
        return ChatInputView(text: $text, isGenerating: $isGenerating, onSend: { print("Send: \(text)") }, onStop: {})
            .uiaiStyle(MinimalStyle(colorScheme: .light))
    }
}
#endif 