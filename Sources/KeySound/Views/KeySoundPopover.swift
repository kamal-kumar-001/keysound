import SwiftUI
import AppKit

public struct KeySoundPopover: View {
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var keyboardMonitor = KeyboardMonitor.shared
    @State private var selectedFilter: String = "All"
    @State private var searchText: String = ""

    public let onQuit: () -> Void

    private let categories = ["All", "Mechanical", "Tactical", "Vintage", "Digital", "Playful", "Acoustic"]

    private var filteredPacks: [SoundPackID] {
        SoundPackID.allCases.filter { pack in
            let matchesCategory = (selectedFilter == "All" || pack.category == selectedFilter)
            let matchesSearch = searchText.isEmpty ||
                pack.title.localizedCaseInsensitiveContains(searchText) ||
                pack.subtitle.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header with Master Switch
            headerView

            Divider()
                .opacity(0.25)

            // Accessibility Banner if permission is needed
            if !keyboardMonitor.isAccessibilityGranted {
                accessibilityNoticeView
                Divider()
                    .opacity(0.25)
            }

            // Sound Controls Section (Volume & Pitch)
            soundControlsSection

            Divider()
                .opacity(0.25)

            // Test typing area
            TypingTestField()

            Divider()
                .opacity(0.25)

            // Categories & Sound Packs Section
            soundPacksSection

            Divider()
                .opacity(0.25)

            // Footer
            footerView
        }
        .frame(width: 360, height: 550)
        .background(
            VisualEffectView(material: .popover, blendingMode: .behindWindow)
        )
    }

    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.18))
                    .frame(width: 30, height: 30)

                Image(systemName: "keyboard.fill")
                    .font(.system(size: 15))
                    .foregroundColor(.accentColor)
            }

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 6) {
                    Text("KeySound")
                        .font(.system(size: 14, weight: .bold))

                    Circle()
                        .fill(settings.isEnabled ? Color.green : Color.secondary.opacity(0.5))
                        .frame(width: 7, height: 7)
                }

                Text(settings.isEnabled ? "Active • Playing \(settings.selectedPack.title)" : "Disabled")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: $settings.isEnabled)
                .toggleStyle(.switch)
                .labelsHidden()
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    // MARK: - Accessibility Notice
    private var accessibilityNoticeView: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.system(size: 15))

            VStack(alignment: .leading, spacing: 2) {
                Text("Accessibility Access Needed")
                    .font(.system(size: 11, weight: .semibold))
                Text("Required to detect keystrokes in background.")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Grant") {
                keyboardMonitor.openAccessibilitySettings()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .font(.system(size: 11))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.1))
    }

    // MARK: - Sound Controls (Separate Volume & Pitch Jitter)
    private var soundControlsSection: some View {
        VStack(spacing: 8) {
            // Volume Row
            HStack(spacing: 10) {
                Button {
                    if settings.volume > 0.05 {
                        settings.volume = 0.0
                    } else {
                        settings.volume = 0.75
                    }
                } label: {
                    Image(systemName: settings.volume > 0.05 ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.system(size: 12))
                        .foregroundColor(settings.volume > 0.05 ? .accentColor : .secondary)
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
                .help("Toggle mute")

                Text("Volume")
                    .font(.system(size: 12, weight: .medium))

                Slider(value: $settings.volume, in: 0.0...1.0, step: 0.02)
                    .tint(.accentColor)

                Text("\(Int(settings.volume * 100))%")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 36, alignment: .trailing)
            }

            // Pitch Variation / Natural Feel Row
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Text("Organic Pitch Variation")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Toggle("", isOn: $settings.pitchJitterEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .controlSize(.mini)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    // MARK: - Sound Packs Section
    private var soundPacksSection: some View {
        VStack(spacing: 6) {
            // Header & Category Chips
            HStack {
                Text("SOUND PACKS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(filteredPacks.count) available")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.8))
            }
            .padding(.horizontal, 14)
            .padding(.top, 6)

            // Category Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(categories, id: \.self) { cat in
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedFilter = cat
                            }
                        } label: {
                            Text(cat)
                                .font(.system(size: 10, weight: selectedFilter == cat ? .semibold : .regular))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(selectedFilter == cat ? Color.accentColor : Color.primary.opacity(0.06))
                                )
                                .foregroundColor(selectedFilter == cat ? .white : .primary.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 2)
            }

            // Sound Pack List
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(filteredPacks) { pack in
                        SoundPackCard(
                            pack: pack,
                            isSelected: settings.selectedPack == pack,
                            onSelect: {
                                settings.selectedPack = pack
                                SoundEngine.shared.updateActivePack(pack)
                                SoundEngine.shared.preview(pack: pack)
                            },
                            onPreview: {
                                SoundEngine.shared.preview(pack: pack)
                            }
                        )
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Footer
    private var footerView: some View {
        HStack {
            Text("KeySound v1.0")
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.7))

            Spacer()

            Button("Quit") {
                onQuit()
            }
            .buttonStyle(.plain)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.primary.opacity(0.05))
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }
}
