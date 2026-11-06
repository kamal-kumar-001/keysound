import SwiftUI
import AppKit

public struct KeySoundPopover: View {
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var keyboardMonitor = KeyboardMonitor.shared
    @ObservedObject var customStore = CustomSoundStore.shared
    @State private var selectedFilter: String = "All"
    @State private var searchText: String = ""
    @State private var isShowingAddSoundSheet: Bool = false

    public let onQuit: () -> Void

    private let categories = ["All", "Custom", "Mechanical", "Tactical", "Vintage", "Digital", "Playful", "Acoustic"]

    private var filteredCustomPacks: [CustomSoundPack] {
        guard selectedFilter == "All" || selectedFilter == "Custom" else { return [] }
        if searchText.isEmpty {
            return customStore.customPacks
        }
        return customStore.customPacks.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var filteredBuiltInPacks: [SoundPackID] {
        guard selectedFilter != "Custom" else { return [] }
        return SoundPackID.allCases.filter { pack in
            let matchesCategory = (selectedFilter == "All" || pack.category == selectedFilter)
            let matchesSearch = searchText.isEmpty ||
                pack.title.localizedCaseInsensitiveContains(searchText) ||
                pack.subtitle.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    private var totalAvailableCount: Int {
        filteredCustomPacks.count + filteredBuiltInPacks.count
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
                    .transition(.opacity.combined(with: .move(edge: .top)))
                Divider()
                    .opacity(0.25)
            }

            // Sound Controls Section (Volume & Pitch & Autostart)
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
        .frame(width: 360, height: 585)
        .animation(.easeInOut(duration: 0.25), value: keyboardMonitor.isAccessibilityGranted)
        .background(
            VisualEffectView(material: .popover, blendingMode: .behindWindow)
        )
        .sheet(isPresented: $isShowingAddSoundSheet) {
            AddSoundSheet()
        }
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

                Text(settings.isEnabled ? "Active • \(settings.selectedPackTitle)" : "Disabled")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
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

    // MARK: - Sound Controls
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

            // Launch at Login Row
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise.circle")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Text("Launch at Login")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Toggle("", isOn: $settings.launchAtLogin)
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
            // Header with "+ Add Sound" Button
            HStack {
                Text("SOUND PACKS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)

                Button {
                    isShowingAddSoundSheet = true
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "plus")
                            .font(.system(size: 9, weight: .bold))
                        Text("Add Sound")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.accentColor.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
                .help("Add a custom sound pack")

                Spacer()

                Text("\(totalAvailableCount) available")
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
                            HStack(spacing: 4) {
                                Text(cat)
                                if cat == "Custom" && !customStore.customPacks.isEmpty {
                                    Text("\(customStore.customPacks.count)")
                                        .font(.system(size: 9, weight: .bold))
                                        .padding(.horizontal, 4)
                                        .background(Capsule().fill(Color.primary.opacity(0.15)))
                                }
                            }
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

            // Combined Sound Pack List
            ScrollView {
                VStack(spacing: 4) {
                    // Custom Packs First
                    ForEach(filteredCustomPacks) { pack in
                        CustomSoundPackCard(
                            pack: pack,
                            isSelected: settings.selectedPackKey == "custom_\(pack.id)",
                            onSelect: {
                                settings.selectedPackKey = "custom_\(pack.id)"
                                SoundEngine.shared.preview(packKey: "custom_\(pack.id)")
                            },
                            onPreview: {
                                SoundEngine.shared.preview(packKey: "custom_\(pack.id)")
                            },
                            onDelete: {
                                withAnimation(.easeOut(duration: 0.15)) {
                                    customStore.removePack(id: pack.id)
                                    if settings.selectedPackKey == "custom_\(pack.id)" {
                                        settings.selectedPackKey = SoundPackID.cherryBlue.rawValue
                                    }
                                }
                            }
                        )
                    }

                    // Built-In Packs
                    ForEach(filteredBuiltInPacks) { pack in
                        SoundPackCard(
                            pack: pack,
                            isSelected: settings.selectedPackKey == pack.rawValue,
                            onSelect: {
                                settings.selectedPackKey = pack.rawValue
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
