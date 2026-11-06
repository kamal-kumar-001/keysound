# KeySound for macOS

[![GitHub](https://img.shields.io/badge/GitHub-kamal--kumar--001%2Fkeysound-blue?logo=github)](https://github.com/kamal-kumar-001/keysound)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS%2012%2B-lightgrey?logo=apple)](https://github.com/kamal-kumar-001/keysound)

KeySound is a lightweight, subtle macOS menu bar application that plays satisfying keystroke sound effects with ultra-low latency as you type in any application. Featuring 15 built-in sound packs, custom audio import, an independent volume control separate from your Mac's system volume, organic pitch variation, and native Apple aesthetics.

Official Repository: [https://github.com/kamal-kumar-001/keysound](https://github.com/kamal-kumar-001/keysound)

## Features

- **15 Built-In Sound Packs**:
  1. **Cherry MX Blue**: Crisp tactile click and sharp mechanical snap.
  2. **Cherry MX Brown**: Subtle tactile bump with a balanced soft clack.
  3. **Cherry MX Red**: Smooth linear switch glide with cushioned bottom-out.
  4. **Holy Panda**: Heavy, deep resonant tactile "thock".
  5. **Alps Cream Vintage**: Vintage Apple Extended Keyboard (M0115) tactile clack.
  6. **Shotgun Pump Action**: Heavy metallic slide rack, shell feed, and 12-gauge blast crack + reload on Return.
  7. **Katana Blade Clash**: Sharp metal sword blade impact with harmonic steel ringing.
  8. **Vintage Typewriter**: Steel type bar striking platen with metallic clank and carriage return bell DING on Return.
  9. **Gaming Mouse Switch**: Crisp Omron microswitch tactile click.
  10. **Bubble Pop**: Satisfying liquid cavitation pop and droplet chirp.
  11. **Pure Water Droplet**: Acoustic crystalline droplet splash.
  12. **Retro 8-Bit Arcade**: Chiptune square-wave arcade blips and powerup arpeggio on Return.
  13. **Sci-Fi Laser Blaster**: Futuristic energy beam pew sound with pitch-drop envelope.
  14. **Cyberpunk Relay**: Clean holographic UI relay chirp.
  15. **Mechanical SLR Shutter**: Dual-curtain mechanical SLR focal plane shutter snap and mirror slap.
- **✨ Custom Sound Pack Creator (+ Add Sound)**: Import any audio file (`.wav`, `.mp3`, `.m4a`, `.aiff`, `.caf`) to create your own signature typing sounds, with optional spacebar and return key audio variations.
- **Dedicated Volume Control**: Control keysound volume independently from your Mac's master output volume (0% to 100%) with quick one-click mute.
- **Launch at Login Autostart**: Enable or disable automatic startup on Mac boot right from the menu bar popover.
- **Organic Pitch Variation**: Micro-jitter (±2%) per keystroke so typing sounds natural and authentic rather than robotic.
- **Key-Specific Acoustics**: Specialized acoustic profiles for Spacebar (deeper resonance), Return key (accentuated strike / bell / blast), Delete / Backspace, and Modifiers.
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
4. The banner will immediately dismiss itself with a smooth animation and key sounds will activate across all apps.

*(KeySound runs 100% locally on your machine with zero network access and never logs, transmits, or stores keystroke data).*

---

## Adding Custom Sounds

1. Click the KeySound icon in your macOS menu bar.
2. Click the **+ Add Sound** button in the sound packs header.
3. Enter a name (e.g., "Laser Cannon", "Cat Meow", "Vintage Switch").
4. Pick an icon.
5. Click **Choose Audio File...** to select your `.wav`, `.mp3`, or `.m4a` file.
6. (Optional) Expand **Key Variations** to pick distinct audio files for your Spacebar and Return keys.
7. Click **Save Sound Pack**. The pack is immediately saved to Application Support and activated!

---

## Building from Source

To build the native `.app` and `.dmg` from source:

```bash
./Scripts/build-app.sh
```

---

## License

Open source licensed under the [MIT License](LICENSE). Copyright © 2026 Kamal and KeySound Contributors.
