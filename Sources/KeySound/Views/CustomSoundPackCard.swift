import SwiftUI

public struct CustomSoundPackCard: View {
    public let pack: CustomSoundPack
    public let isSelected: Bool
    public let onSelect: () -> Void
    public let onPreview: () -> Void
    public let onDelete: () -> Void

    @State private var isHovering = false

    public var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Pack Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.accentColor : Color.primary.opacity(0.06))
                        .frame(width: 34, height: 34)

                    Image(systemName: pack.iconName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .primary.opacity(0.85))
                }

                // Title and Subtitle
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(pack.name)
                            .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                            .foregroundColor(.primary)

                        Text("Custom")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(isSelected ? Color.accentColor : Color.orange)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.orange.opacity(0.12))
                            )
                    }

                    Text("Imported audio file • \(pack.standardFileName)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Preview Button
                Button(action: onPreview) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(isHovering || isSelected ? Color.accentColor : Color.secondary.opacity(0.6))
                        .frame(width: 26, height: 26)
                        .background(
                            Circle()
                                .fill(Color.primary.opacity(isHovering ? 0.08 : 0.03))
                        )
                }
                .buttonStyle(.plain)
                .help("Preview this custom sound")

                // Delete Button (visible on hover or always accessible)
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary.opacity(0.7))
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
                .help("Delete custom sound pack")

                // Selection checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.accentColor)
                } else {
                    Circle()
                        .stroke(Color.primary.opacity(0.15), lineWidth: 1.5)
                        .frame(width: 16, height: 16)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.09) : (isHovering ? Color.primary.opacity(0.04) : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor.opacity(0.35) : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.12)) {
                isHovering = hovering
            }
        }
    }
}
