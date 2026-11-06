import Foundation
import AVFoundation

public final class SoundEngine: NSObject {
    public static let shared = SoundEngine()

    private let voicePoolSize = 20
    private var voicePool: [AVAudioPlayer] = []
    private var currentVoiceIndex = 0
    private let engineQueue = DispatchQueue(label: "com.keysound.engine", qos: .userInteractive)

    private var activePackKey: String = SoundPackID.cherryBlue.rawValue
    private var cachedDataByPackAndKey: [String: Data] = [:]
    public var currentVolume: Float = 0.75
    public var isPitchJitterEnabled: Bool = true

    private override init() {
        super.init()
        preloadActivePack()
    }

    public func updateActivePack(key: String) {
        engineQueue.async { [weak self] in
            guard let self = self else { return }
            self.activePackKey = key
            self.preloadActivePack()
        }
    }

    public func updateActivePack(_ pack: SoundPackID) {
        updateActivePack(key: pack.rawValue)
    }

    private func preloadActivePack() {
        if !activePackKey.hasPrefix("custom_"), let pack = SoundPackID(rawValue: activePackKey) {
            for keyType in KeyType.allCases {
                let key = "\(pack.rawValue)_\(keyType.rawValue)"
                if cachedDataByPackAndKey[key] == nil {
                    let data = SoundSynthesizer.shared.soundData(for: pack, keyType: keyType)
                    cachedDataByPackAndKey[key] = data
                }
            }
        }
    }

    public func playKey(type: KeyType, packKeyOverride: String? = nil, volumeOverride: Double? = nil) {
        let packKey = packKeyOverride ?? activePackKey
        let vol = volumeOverride.map { Float($0) } ?? self.currentVolume
        let jitter = self.isPitchJitterEnabled

        if packKey.hasPrefix("custom_") {
            let customId = String(packKey.dropFirst(7))
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let data = CustomSoundStore.shared.audioData(for: customId, keyType: type) {
                    self.engineQueue.async {
                        self.playAudioData(data, volume: vol, pitchJitter: jitter)
                    }
                }
            }
            return
        }

        let pack = SoundPackID(rawValue: packKey) ?? .cherryBlue
        let synth = SoundSynthesizer.shared

        engineQueue.async { [weak self] in
            guard let self = self else { return }

            let key = "\(pack.rawValue)_\(type.rawValue)"
            let soundData: Data
            if let cached = self.cachedDataByPackAndKey[key] {
                soundData = cached
            } else {
                soundData = synth.soundData(for: pack, keyType: type)
                self.cachedDataByPackAndKey[key] = soundData
            }

            self.playAudioData(soundData, volume: vol, pitchJitter: jitter)
        }
    }

    public func preview(packKey: String) {
        playKey(type: .standard, packKeyOverride: packKey, volumeOverride: nil)
    }

    public func preview(pack: SoundPackID) {
        preview(packKey: pack.rawValue)
    }

    public func playAudioDataViaVoicePool(_ data: Data) {
        let vol = self.currentVolume
        let jitter = self.isPitchJitterEnabled
        engineQueue.async { [weak self] in
            self?.playAudioData(data, volume: vol, pitchJitter: jitter)
        }
    }

    private func playAudioData(_ data: Data, volume: Float, pitchJitter: Bool) {
        guard volume > 0.001 else { return }

        do {
            let player = try AVAudioPlayer(data: data)
            player.enableRate = true
            player.volume = max(0.0, min(1.0, volume))

            if pitchJitter {
                let jitter = Float.random(in: 0.98...1.02)
                player.rate = jitter
            } else {
                player.rate = 1.0
            }

            player.prepareToPlay()
            player.play()

            if self.voicePool.count < self.voicePoolSize {
                self.voicePool.append(player)
            } else {
                self.voicePool[self.currentVoiceIndex] = player
                self.currentVoiceIndex = (self.currentVoiceIndex + 1) % self.voicePoolSize
            }
        } catch {
            // Audio playback error handling
        }
    }
}
