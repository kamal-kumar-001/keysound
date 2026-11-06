import SwiftUI
import AppKit
import UniformTypeIdentifiers

public struct AddSoundSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var store = CustomSoundStore.shared
    @ObservedObject var settings = AppSettings.shared

    @State private var packName: String = ""
    @State private var selectedIcon: String = "waveform"
    @State private var standardAudioURL: URL?
    @State private var spaceAudioURL: URL?
    @State private var returnAudioURL: URL?
    @State private var showAdvancedOptions: Bool = false
    @State private var errorMessage: String?

    private let availableIcons = [
        "waveform", "music.note", "star.fill", "bolt.fill",
        "bell.fill", "gamecontroller.fill", "sparkles", "drop.fill",
        "cpu.fill", "shield.fill"
    ]

    public var onSave: (() -> Void)?

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 16))

                    Text("Add Custom Sound Pack")
                        .font(.system(size: 14, weight: .bold))
                }

                Spacer()

                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()
                .opacity(0.25)

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    // Name Field
                    VStack(alignment: .leading, spacing: 5) {
                        Text("SOUND PACK NAME")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)

                        TextField("e.g. My Custom Switch, Laser, Meow...", text: $packName)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                    }

                    // Icon Picker
                    VStack(alignment: .leading, spacing: 5) {
                        Text("ICON")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)

                        HStack(spacing: 8) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(selectedIcon == icon ? Color.accentColor : Color.primary.opacity(0.06))
                                            .frame(width: 28, height: 28)

                                        Image(systemName: icon)
                                            .font(.system(size: 12))
                                            .foregroundColor(selectedIcon == icon ? .white : .primary.opacity(0.8))
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Primary Audio File
                    VStack(alignment: .leading, spacing: 5) {
                        Text("PRIMARY AUDIO FILE (WAV, MP3, M4A, AIFF)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)

                        HStack(spacing: 8) {
                            Button {
                                pickAudioFile { url in
                                    standardAudioURL = url
                                    if packName.isEmpty {
                                        packName = url.deletingPathExtension().lastPathComponent
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: standardAudioURL == nil ? "folder" : "checkmark.circle.fill")
                                        .foregroundColor(standardAudioURL == nil ? .accentColor : .green)

                                    Text(standardAudioURL?.lastPathComponent ?? "Choose Audio File...")
                                        .font(.system(size: 11, weight: .medium))
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.primary.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)

                            if let url = standardAudioURL {
                                Button {
                                    testAudio(url: url)
                                } label: {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.accentColor)
                                        .frame(width: 28, height: 28)
                                        .background(
                                            Circle()
                                                .fill(Color.accentColor.opacity(0.15))
                                        )
                                }
                                .buttonStyle(.plain)
                                .help("Preview sound")
                            }
                        }
                    }

                    // Optional Variations Disclosure
                    DisclosureGroup("Key Variations (Optional)", isExpanded: $showAdvancedOptions) {
                        VStack(alignment: .leading, spacing: 10) {
                            // Spacebar sound
                            HStack {
                                Text("Spacebar:")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .leading)

                                Button {
                                    pickAudioFile { spaceAudioURL = $0 }
                                } label: {
                                    Text(spaceAudioURL?.lastPathComponent ?? "Choose Space File...")
                                        .font(.system(size: 10))
                                        .lineLimit(1)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)

                                if let url = spaceAudioURL {
                                    Button {
                                        testAudio(url: url)
                                    } label: {
                                        Image(systemName: "speaker.wave.2.fill")
                                            .font(.system(size: 10))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            // Return key sound
                            HStack {
                                Text("Return:")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .leading)

                                Button {
                                    pickAudioFile { returnAudioURL = $0 }
                                } label: {
                                    Text(returnAudioURL?.lastPathComponent ?? "Choose Return File...")
                                        .font(.system(size: 10))
                                        .lineLimit(1)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)

                                if let url = returnAudioURL {
                                    Button {
                                        testAudio(url: url)
                                    } label: {
                                        Image(systemName: "speaker.wave.2.fill")
                                            .font(.system(size: 10))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.top, 6)
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)

                    if let err = errorMessage {
                        Text(err)
                            .font(.system(size: 11))
                            .foregroundColor(.red)
                    }
                }
                .padding(16)
            }

            Divider()
                .opacity(0.25)

            // Bottom Actions
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.plain)
                .font(.system(size: 11))
                .foregroundColor(.secondary)

                Spacer()

                Button("Save Sound Pack") {
                    saveCustomPack()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .font(.system(size: 11, weight: .semibold))
                .disabled(standardAudioURL == nil)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(width: 350, height: 420)
        .background(
            VisualEffectView(material: .popover, blendingMode: .behindWindow)
        )
    }

    private func pickAudioFile(completion: @escaping (URL) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            UTType.audio,
            UTType.wav,
            UTType.mp3,
            UTType.aiff,
            UTType(filenameExtension: "m4a") ?? .audio,
            UTType(filenameExtension: "aac") ?? .audio,
            UTType(filenameExtension: "caf") ?? .audio
        ]

        if panel.runModal() == .OK, let url = panel.url {
            completion(url)
        }
    }

    private func testAudio(url: URL) {
        if let data = try? Data(contentsOf: url) {
            SoundEngine.shared.playAudioDataViaVoicePool(data)
        }
    }

    private func saveCustomPack() {
        guard let stdURL = standardAudioURL else {
            errorMessage = "Please choose a primary audio file."
            return
        }

        do {
            let pack = try store.importPack(
                name: packName,
                icon: selectedIcon,
                standardURL: stdURL,
                spaceURL: spaceAudioURL,
                returnURL: returnAudioURL
            )

            // Select the newly added pack immediately
            settings.selectedPackKey = "custom_\(pack.id)"
            SoundEngine.shared.preview(packKey: "custom_\(pack.id)")

            onSave?()
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = "Failed to import sound: \(error.localizedDescription)"
        }
    }
}
