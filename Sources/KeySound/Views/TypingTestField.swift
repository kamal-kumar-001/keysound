import SwiftUI

public struct TypingTestField: View {
    @State private var text: String = ""
    @ObservedObject var keyboardMonitor = KeyboardMonitor.shared
    @FocusState private var isFocused: Bool

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("TEST TYPING")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)

                Spacer()

                // Keypress live badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(keyboardMonitor.pressCount > 0 ? Color.green : Color.secondary.opacity(0.4))
                        .frame(width: 6, height: 6)
                        .scaleEffect(keyboardMonitor.pressCount % 2 == 0 ? 1.0 : 1.3)
                        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: keyboardMonitor.pressCount)

                    Text(keyboardMonitor.lastPressedKeyName)
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(.primary.opacity(0.85))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.primary.opacity(0.08))
                        )
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "keyboard")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)

                TextField("Type here to test key sounds...", text: $text)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .focused($isFocused)

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary.opacity(0.7))
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.55))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isFocused ? Color.accentColor.opacity(0.5) : Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
    }
}
