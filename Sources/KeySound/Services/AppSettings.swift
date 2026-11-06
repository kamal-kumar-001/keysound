import Foundation
import Combine

@MainActor
public final class AppSettings: ObservableObject {
    public static let shared = AppSettings()

    private enum Keys {
        static let isEnabled = "KeySound_isEnabled"
        static let volume = "KeySound_volume"
        static let selectedPack = "KeySound_selectedPack"
        static let pitchJitterEnabled = "KeySound_pitchJitterEnabled"
    }

    private let defaults = UserDefaults.standard

    @Published public var isEnabled: Bool {
        didSet { defaults.set(isEnabled, forKey: Keys.isEnabled) }
    }

    @Published public var volume: Double {
        didSet {
            defaults.set(volume, forKey: Keys.volume)
            SoundEngine.shared.currentVolume = Float(volume)
        }
    }

    @Published public var selectedPack: SoundPackID {
        didSet {
            defaults.set(selectedPack.rawValue, forKey: Keys.selectedPack)
            SoundEngine.shared.updateActivePack(selectedPack)
        }
    }

    @Published public var pitchJitterEnabled: Bool {
        didSet {
            defaults.set(pitchJitterEnabled, forKey: Keys.pitchJitterEnabled)
            SoundEngine.shared.isPitchJitterEnabled = pitchJitterEnabled
        }
    }

    private init() {
        if defaults.object(forKey: Keys.isEnabled) == nil {
            self.isEnabled = true
        } else {
            self.isEnabled = defaults.bool(forKey: Keys.isEnabled)
        }

        if defaults.object(forKey: Keys.volume) == nil {
            self.volume = 0.75
        } else {
            self.volume = defaults.double(forKey: Keys.volume)
        }

        if let savedPackRaw = defaults.string(forKey: Keys.selectedPack),
           let pack = SoundPackID(rawValue: savedPackRaw) {
            self.selectedPack = pack
        } else {
            self.selectedPack = .cherryBlue
        }

        if defaults.object(forKey: Keys.pitchJitterEnabled) == nil {
            self.pitchJitterEnabled = true
        } else {
            self.pitchJitterEnabled = defaults.bool(forKey: Keys.pitchJitterEnabled)
        }

        SoundEngine.shared.currentVolume = Float(self.volume)
        SoundEngine.shared.isPitchJitterEnabled = self.pitchJitterEnabled
        SoundEngine.shared.updateActivePack(self.selectedPack)
    }
}
