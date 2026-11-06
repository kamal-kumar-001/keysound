import AppKit
import SwiftUI
import Carbon.HIToolbox
import ApplicationServices

@MainActor(unsafe)
final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupPopover()
        setupGlobalShortcut()

        // Preload sound synthesizer samples in background
        SoundSynthesizer.shared.preloadAll()

        // Start keyboard monitoring
        KeyboardMonitor.shared.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        KeyboardMonitor.shared.stop()
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        guard let button = statusItem.button else { return }

        button.image = NSImage(
            systemSymbolName: "keyboard.fill",
            accessibilityDescription: "KeySound"
        )
        button.image?.isTemplate = true
        button.action = #selector(menuBarButtonClicked)
        button.target = self
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.delegate = self
        popover.contentSize = NSSize(width: 360, height: 550)

        let contentView = KeySoundPopover(
            onQuit: { [weak self] in
                self?.quitApp()
            }
        )

        popover.contentViewController = NSHostingController(rootView: contentView)
    }

    private func setupGlobalShortcut() {
        // Cmd + Option + K to toggle KeySound Enable / Disable
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let callback: EventHandlerUPP = { _, _, userData in
            guard let userData = userData else { return noErr }
            _ = Unmanaged<AppDelegate>.fromOpaque(userData).takeUnretainedValue()

            DispatchQueue.main.async {
                let settings = AppSettings.shared
                settings.isEnabled.toggle()
                if settings.isEnabled {
                    SoundEngine.shared.preview(pack: settings.selectedPack)
                }
            }

            return noErr
        }

        InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )

        let hotKeyID = EventHotKeyID(
            signature: OSType(0x4B59534E), // "KYSN"
            id: 1
        )

        // kVK_ANSI_K = 40
        RegisterEventHotKey(
            UInt32(kVK_ANSI_K),
            UInt32(cmdKey | optionKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    @objc private func menuBarButtonClicked() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            // Re-check accessibility permission when opening popover
            KeyboardMonitor.shared.checkAccessibilityStatus()

            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }

    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
