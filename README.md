# KeySound for macOS

KeySound is a lightweight, subtle macOS menu bar application that plays satisfying keystroke sound effects with ultra-low latency as you type in any application. Featuring 10 distinct sound packs (mechanical switches, shotgun action, vintage typewriter, bubble pops, 8-bit chiptune, etc.), an independent volume control separate from your Mac's system volume, organic pitch variation, and native Apple aesthetics.

## Features

- **10 Curated Sound Packs**:
  1. **Cherry MX Blue**: Crisp tactile click and sharp mechanical snap.
  2. **Cherry MX Brown**: Subtle tactile bump with a balanced soft clack.
  3. **Cherry MX Red**: Smooth linear switch glide with cushioned bottom-out.
  4. **Holy Panda**: Heavy, deep resonant tactile "thock".
  5. **Shotgun Action**: Punchy metallic pump slide, trigger lock, and double-pump cock on Return.
  6. **Vintage Typewriter**: Steel type bar striking platen with metallic clank and carriage return bell DING on Return.
  7. **Bubble Pop**: Satisfying liquid pop and bubbly cavitation chirp.
  8. **Retro 8-Bit**: Chiptune square-wave arcade blips and powerup arpeggio on Return.
  9. **Sci-Fi Cyber Relay**: Futuristic UI relay chirp and holographic switch tone.
  10. **Camera Shutter**: Dual-curtain mechanical SLR focal plane shutter snap and mirror slap.
- **Dedicated Volume Control**: Control keysound volume independently from your Mac's master output volume (0% to 100%) with quick one-click mute.
- **Organic Pitch Variation**: Subtle pitch micro-jitter (±2%) per keystroke so typing sounds natural and authentic rather than robotic.
- **Key-Specific Acoustics**: Specialized acoustic profiles for Spacebar (deeper resonance), Return key (accentuated strike / bell), Delete / Backspace, and Modifiers.
- **Ultra-Low Latency (< 5ms)**: 20-voice concurrent audio pool designed for fast typists (100+ WPM) without audio clipping or latency.
- **Interactive Typing Tester**: Test your chosen sound pack directly inside the popover with live keystroke feedback.
- **Subtle Native Mac Design**: Designed to blend seamlessly into macOS with `NSVisualEffectView` popover vibrancy, SF Symbols, and full Dark / Light mode support.
- **Global Shortcut**: Press `Cmd + Option + K` anytime to instantly toggle KeySound on/off.

---

## Installation via DMG

1. Download or locate [`KeySound.dmg`](KeySound.dmg).
2. Double-click `KeySound.dmg` to open it.
3. Drag **KeySound** to your **Applications** folder.
4. Launch KeySound from `/Applications` or Spotlight.
5. The keyboard icon will appear in your macOS menu bar.

> [!NOTE]
> The first launch may display a gatekeeper confirmation since the binary is self-built. Open Finder, right-click `KeySound.app` and choose **Open**, or visit **System Settings > Privacy & Security** and click **Open Anyway**.

---

## Accessibility Permission

Global key detection across macOS applications utilizes macOS Accessibility APIs (`CGEventTap`):

1. Click the KeySound icon in your menu bar.
2. If permissions are needed, click the **Grant** button on the banner, or open **System Settings > Privacy & Security > Accessibility**.
3. Enable the toggle for **KeySound**.

*(KeySound runs 100% locally on your machine with zero network access and never logs, transmits, or stores keystroke data).*

---

## Building from Source

To build the native `.app` and `.dmg` from source:

```bash
./Scripts/build-app.sh
```

The script compiles the Swift sources using Command Line Tools or Xcode, packages `KeySound.app`, generates the high-resolution `.icns`, and produces `KeySound.dmg`.

---

## Architecture

- **`SoundSynthesizer.swift`**: Procedural mathematical physical modeling producing 44.1kHz 16-bit stereo PCM audio in memory.
- **`SoundEngine.swift`**: Voice-pooled `AVAudioPlayer` low-latency playback manager with independent gain and rate jitter.
- **`KeyboardMonitor.swift`**: Global `CGEventTap` and local `NSEvent` key monitoring with keycode mapping.
- **`KeySoundPopover.swift`**: SwiftUI menu bar interface with real-time audio controls and filterable sound pack selector.
