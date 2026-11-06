import Foundation
import AVFoundation

public final class SoundEngine: NSObject {
    public static let shared = SoundEngine()

    private let voicePoolSize = 20
    private var voicePool: [AVAudioPlayer] = []
    private var currentVoiceIndex = 0
    private let engineQueue = DispatchQueue(label: "com.keysound.engine", qos: .userInteractive)

    private var activePack: SoundPackID = .cherryBlue
    private var cachedDataByPackAndKey: [String: Data] = [:]
    public var currentVolume: Float = 0.75
    public var isPitchJitterEnabled: Bool = true

    private override init() {
        super.init()
        preloadActivePack()
    }

    public func updateActivePack(_ pack: SoundPackID) {
        engineQueue.async { [weak self] in
            guard let self = self else { return }
            self.activePack = pack
            self.preloadActivePack()
        }
    }

    private func preloadActivePack() {
        for keyType in KeyType.allCases {
            let key = "\(activePack.rawValue)_\(keyType.rawValue)"
            if cachedDataByPackAndKey[key] == nil {
                let data = SoundSynthesizer.shared.soundData(for: activePack, keyType: keyType)
                cachedDataByPackAndKey[key] = data
            }
        }
    }

    public func playKey(type: KeyType, packOverride: SoundPackID? = nil, volumeOverride: Double? = nil) {
        let pack = packOverride ?? activePack
        let synth = SoundSynthesizer.shared
        let vol = volumeOverride.map { Float($0) } ?? self.currentVolume
        let jitter = self.isPitchJitterEnabled

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

    public func preview(pack: SoundPackID) {
        playKey(type: .standard, packOverride: pack, volumeOverride: nil)
    }

    private func playAudioData(_ data: Data, volume: Float, pitchJitter: Bool) {
        guard volume > 0.001 else { return }

        do {
            let player = try AVAudioPlayer(data: data)
            player.enableRate = true
            player.volume = max(0.0, min(1.0, volume))

            if pitchJitter {
                // Subtle random variation (98% to 102%) makes mechanical typing organic
                let jitter = Float.random(in: 0.98...1.02)
                player.rate = jitter
            } else {
                player.rate = 1.0
            }

            player.prepareToPlay()
            player.play()

            // Keep reference in round-robin pool so ARC doesn't deallocate before finished playing
            if self.voicePool.count < self.voicePoolSize {
                self.voicePool.append(player)
            } else {
                self.voicePool[self.currentVoiceIndex] = player
                self.currentVoiceIndex = (self.currentVoiceIndex + 1) % self.voicePoolSize
            }
        } catch {
            // Audio player error handling
        }
    }
}
