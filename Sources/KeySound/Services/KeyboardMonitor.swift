import Foundation
import AppKit
import ApplicationServices
import Carbon.HIToolbox

@MainActor
public final class KeyboardMonitor: ObservableObject {
    public static let shared = KeyboardMonitor()

    @Published public private(set) var isAccessibilityGranted: Bool = false
    @Published public private(set) var lastPressedKeyName: String = "Ready"
    @Published public private(set) var lastKeyType: KeyType = .standard
    @Published public private(set) var pressCount: Int = 0

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var localMonitor: Any?
    private var checkTimer: Timer?
    private var lastModifierFlags: NSEvent.ModifierFlags = []

    private init() {
        checkAccessibilityStatus()

        // Observe when app becomes active or is focused
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func appDidBecomeActive() {
        checkAccessibilityStatus()
        if isAccessibilityGranted && eventTap == nil {
            setupEventTap()
        }
    }

    public func start() {
        checkAccessibilityStatus()
        setupEventTap()
        setupLocalMonitor()

        // Check accessibility status periodically (1.0s) while not granted
        checkTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(timerTick),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func timerTick() {
        checkAccessibilityStatus()
        if isAccessibilityGranted {
            if eventTap == nil {
                setupEventTap()
            }
            // Once granted, slow down check interval
            checkTimer?.invalidate()
            checkTimer = Timer.scheduledTimer(
                timeInterval: 4.0,
                target: self,
                selector: #selector(timerTick),
                userInfo: nil,
                repeats: true
            )
        }
    }

    public func stop() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            if let runLoopSource = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            }
            self.eventTap = nil
            self.runLoopSource = nil
        }

        if let localMonitor = localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }

        checkTimer?.invalidate()
        checkTimer = nil
    }

    public func checkAccessibilityStatus() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false] as CFDictionary
        let isTrusted = AXIsProcessTrustedWithOptions(options)
        self.isAccessibilityGranted = isTrusted
    }

    public func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    public func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    private func setupLocalMonitor() {
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handleKeyEvent(keyCode: event.keyCode)
            return event
        }
    }

    private func setupEventTap() {
        guard eventTap == nil else { return }

        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
                let monitor = Unmanaged<KeyboardMonitor>.fromOpaque(refcon).takeUnretainedValue()

                if type == .keyDown {
                    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
                    DispatchQueue.main.async {
                        monitor.handleKeyEvent(keyCode: keyCode)
                    }
                } else if type == .flagsChanged {
                    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
                    DispatchQueue.main.async {
                        monitor.handleModifierEvent(keyCode: keyCode)
                    }
                }

                return Unmanaged.passUnretained(event)
            },
            userInfo: observer
        ) else {
            return
        }

        eventTap = tap
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    public func handleKeyEvent(keyCode: UInt16) {
        let (keyType, keyName) = KeyType.from(keyCode: keyCode)
        self.lastPressedKeyName = keyName
        self.lastKeyType = keyType
        self.pressCount &+= 1

        if AppSettings.shared.isEnabled {
            SoundEngine.shared.playKey(type: keyType)
        }
    }

    public func handleModifierEvent(keyCode: UInt16) {
        // Trigger sound only on key press down of modifier (not release)
        let currentFlags = NSEvent.modifierFlags
        let isPressed = currentFlags.contains(.shift) || currentFlags.contains(.control) ||
                        currentFlags.contains(.option) || currentFlags.contains(.command)

        if isPressed && currentFlags != lastModifierFlags {
            let (_, keyName) = KeyType.from(keyCode: keyCode)
            self.lastPressedKeyName = keyName
            self.lastKeyType = .modifier
            self.pressCount &+= 1

            if AppSettings.shared.isEnabled {
                SoundEngine.shared.playKey(type: .modifier)
            }
        }
        lastModifierFlags = currentFlags
    }
}
