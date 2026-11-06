import Foundation
import AVFoundation

public final class SoundSynthesizer {
    public static let shared = SoundSynthesizer()

    private let sampleRate: Double = 44100.0
    private var cache: [String: Data] = [:]
    private let cacheQueue = DispatchQueue(label: "com.keysound.synthcache")

    private init() {}

    public func soundData(for pack: SoundPackID, keyType: KeyType) -> Data {
        let cacheKey = "\(pack.rawValue)_\(keyType.rawValue)"
        if let cached = cacheQueue.sync(execute: { cache[cacheKey] }) {
            return cached
        }

        let samples = generateSamples(for: pack, keyType: keyType)
        let wavData = createWAV(from: samples, sampleRate: Int(sampleRate))
        cacheQueue.sync {
            cache[cacheKey] = wavData
        }
        return wavData
    }

    // Pre-warms the cache for all packs in the background
    public func preloadAll() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            for pack in SoundPackID.allCases {
                for keyType in KeyType.allCases {
                    _ = self.soundData(for: pack, keyType: keyType)
                }
            }
        }
    }

    private func generateSamples(for pack: SoundPackID, keyType: KeyType) -> [Float] {
        switch pack {
        case .cherryBlue:
            return synthCherryBlue(keyType: keyType)
        case .cherryBrown:
            return synthCherryBrown(keyType: keyType)
        case .cherryRed:
            return synthCherryRed(keyType: keyType)
        case .holyPanda:
            return synthHolyPanda(keyType: keyType)
        case .shotgun:
            return synthShotgun(keyType: keyType)
        case .typewriter:
            return synthTypewriter(keyType: keyType)
        case .bubble:
            return synthBubble(keyType: keyType)
        case .arcade8Bit:
            return synthArcade8Bit(keyType: keyType)
        case .sciFiMech:
            return synthSciFi(keyType: keyType)
        case .cameraShutter:
            return synthCameraShutter(keyType: keyType)
        }
    }

    // MARK: - Synthesis Algorithms

    // 1. Cherry MX Blue (Clicky)
    private func synthCherryBlue(keyType: KeyType) -> [Float] {
        let duration: Double = (keyType == .space) ? 0.075 : (keyType == .returnKey ? 0.08 : 0.055)
        let totalSamples = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: totalSamples)

        let clickFreq: Double = 3100.0
        let bodyFreq: Double = (keyType == .space) ? 220.0 : ((keyType == .returnKey) ? 380.0 : 680.0)
        let bottomFreq: Double = (keyType == .space) ? 110.0 : 160.0

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate

            // Sharp click transient
            let clickEnv = exp(-t * 900.0)
            let click = sin(2.0 * .pi * clickFreq * t) * clickEnv * 0.75

            // Body clack
            let bodyEnv = exp(-t * 110.0)
            let body = sin(2.0 * .pi * bodyFreq * t) * bodyEnv * 0.55

            // Bottom thump
            let bottomEnv = exp(-t * 70.0)
            let bottom = sin(2.0 * .pi * bottomFreq * t) * bottomEnv * (keyType == .space ? 0.6 : 0.35)

            // Noise burst
            let noiseEnv = exp(-t * 1200.0)
            let noise = Float.random(in: -0.2...0.2) * Float(noiseEnv)

            let sample = Float(click + body + bottom) + noise
            samples[i] = max(-1.0, min(1.0, sample * 0.9))
        }
        return samples
    }

    // 2. Cherry MX Brown (Tactile)
    private func synthCherryBrown(keyType: KeyType) -> [Float] {
        let duration: Double = (keyType == .space) ? 0.07 : 0.05
        let totalSamples = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: totalSamples)

        let bumpFreq: Double = 1200.0
        let bodyFreq: Double = (keyType == .space) ? 200.0 : 480.0

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate
            let bumpEnv = exp(-t * 500.0)
            let bump = sin(2.0 * .pi * bumpFreq * t) * bumpEnv * 0.4

            let bodyEnv = exp(-t * 90.0)
            let body = sin(2.0 * .pi * bodyFreq * t) * bodyEnv * 0.65

            let noiseEnv = exp(-t * 800.0)
            let noise = Float.random(in: -0.15...0.15) * Float(noiseEnv)

            let sample = Float(bump + body) + noise
            samples[i] = max(-1.0, min(1.0, sample * 0.85))
        }
        return samples
    }

    // 3. Cherry MX Red (Linear)
    private func synthCherryRed(keyType: KeyType) -> [Float] {
        let duration: Double = (keyType == .space) ? 0.065 : 0.045
        let totalSamples = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: totalSamples)

        let bodyFreq: Double = (keyType == .space) ? 160.0 : 340.0
        let springFreq: Double = 980.0

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate
            let bodyEnv = exp(-t * 80.0)
            let body = sin(2.0 * .pi * bodyFreq * t) * bodyEnv * 0.8

            let springEnv = exp(-t * 160.0)
            let spring = sin(2.0 * .pi * springFreq * t) * springEnv * 0.2

            let noiseEnv = exp(-t * 600.0)
            let noise = Float.random(in: -0.08...0.08) * Float(noiseEnv)

            let sample = Float(body + spring) + noise
            samples[i] = max(-1.0, min(1.0, sample * 0.8))
        }
        return samples
    }

    // 4. Holy Panda (Deep Thock)
    private func synthHolyPanda(keyType: KeyType) -> [Float] {
        let duration: Double = (keyType == .space) ? 0.09 : 0.065
        let totalSamples = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: totalSamples)

        let thockFreq: Double = (keyType == .space) ? 140.0 : 220.0
        let slapFreq: Double = 750.0

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate
            let thockEnv = exp(-t * 55.0)
            let thock = sin(2.0 * .pi * thockFreq * t) * thockEnv * 0.85

            let slapEnv = exp(-t * 300.0)
            let slap = sin(2.0 * .pi * slapFreq * t) * slapEnv * 0.45

            let noiseEnv = exp(-t * 900.0)
            let noise = Float.random(in: -0.18...0.18) * Float(noiseEnv)

            let sample = Float(thock + slap) + noise
            samples[i] = max(-1.0, min(1.0, sample * 0.9))
        }
        return samples
    }

    // 5. Shotgun Action
    private func synthShotgun(keyType: KeyType) -> [Float] {
        let isReturn = (keyType == .returnKey)
        let duration: Double = isReturn ? 0.16 : 0.085
        let totalSamples = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: totalSamples)

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate

            // First metallic rack / slide
            let rackT = t
            let rackEnv = exp(-rackT * 280.0)
            let metalRack = (sin(2.0 * .pi * 2400.0 * rackT) + sin(2.0 * .pi * 3800.0 * rackT) * 0.5) * rackEnv * 0.65

            // Heavy mechanical lock / impact
            let impactT = max(0.0, t - 0.012)
            let impactEnv = exp(-impactT * 60.0)
            let impact = sin(2.0 * .pi * 110.0 * impactT) * impactEnv * 0.8

            // Metallic trigger cock / snap
            let snapT = max(0.0, t - 0.02)
            let snapEnv = exp(-snapT * 400.0)
            let snap = sin(2.0 * .pi * 4200.0 * snapT) * snapEnv * 0.5

            var sample = Float(metalRack + impact + snap)

            // Second pump rack for Return key
            if isReturn && t > 0.07 {
                let t2 = t - 0.07
                let pumpEnv = exp(-t2 * 120.0)
                let pump = sin(2.0 * .pi * 160.0 * t2) * pumpEnv * 0.7
                let pumpMetal = sin(2.0 * .pi * 2800.0 * t2) * exp(-t2 * 350.0) * 0.5
                sample += Float(pump + pumpMetal)
            }

            samples[i] = max(-1.0, min(1.0, sample * 0.85))
        }
        return samples
    }

    // 6. Vintage Typewriter
    private func synthTypewriter(keyType: KeyType) -> [Float] {
        let isReturn = (keyType == .returnKey)
        let duration: Double = isReturn ? 0.28 : 0.065
        let totalSamples = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: totalSamples)

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate

            // Steel bar strike
            let strikeEnv = exp(-t * 260.0)
            let strike = (sin(2.0 * .pi * 1920.0 * t) + sin(2.0 * .pi * 3400.0 * t) * 0.6) * strikeEnv * 0.65

            // Platen clunk
            let platenEnv = exp(-t * 70.0)
            let platen = sin(2.0 * .pi * 420.0 * t) * platenEnv * 0.55

            var sample = Float(strike + platen)

            // Carriage return bell DING for Return key!
            if isReturn {
                let bellEnv = exp(-t * 12.0) // Slow bell ring
                let bell = sin(2.0 * .pi * 2793.0 * t) * bellEnv * 0.65 // High bell note (F7)
                let bellHarmonic = sin(2.0 * .pi * 5586.0 * t) * exp(-t * 20.0) * 0.25
                sample += Float(bell + bellHarmonic)
            }

            samples[i] = max(-1.0, min(1.0, sample * 0.85))
        }
        return samples
    }

    // 7. Bubble Pop
    private func synthBubble(keyType: KeyType) -> [Float] {
        let duration: Double = 0.05
        let totalSamples = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: totalSamples)

        let startFreq: Double = (keyType == .space) ? 280.0 : 450.0
        let endFreq: Double = (keyType == .space) ? 800.0 : 1500.0

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate
            let progress = min(1.0, t / (duration * 0.7))
            let currentFreq = startFreq + (endFreq - startFreq) * (progress * progress)
            let env = sin(.pi * min(1.0, t / duration)) * exp(-t * 75.0)

            let sample = sin(2.0 * .pi * currentFreq * t) * env
            samples[i] = Float(sample * 0.95)
        }
        return samples
    }

    // 8. Retro 8-Bit
    private func synthArcade8Bit(keyType: KeyType) -> [Float] {
        let duration: Double = (keyType == .returnKey) ? 0.12 : 0.04
        let totalSamples = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: totalSamples)

        let baseFreq: Double = (keyType == .space) ? 220.0 : ((keyType == .returnKey) ? 660.0 : 440.0)

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate
            var f = baseFreq
            if keyType == .returnKey {
                // Arpeggio
                if t > 0.08 { f *= 1.5 }
                else if t > 0.04 { f *= 1.25 }
            } else {
                f = baseFreq + (1.0 - (t / duration)) * 300.0
            }

            let phase = f * t
            let square = (phase.truncatingRemainder(dividingBy: 1.0) < 0.5) ? 0.6 : -0.6
            let env = 1.0 - (t / duration)

            samples[i] = Float(square * env * 0.75)
        }
        return samples
    }

    // 9. Sci-Fi Cyber Relay
    private func synthSciFi(keyType: KeyType) -> [Float] {
        let duration: Double = 0.045
        let totalSamples = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: totalSamples)

        let f1: Double = (keyType == .space) ? 800.0 : 1600.0
        let f2: Double = (keyType == .space) ? 1600.0 : 3200.0

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate
            let env = exp(-t * 110.0)
            let beep = (sin(2.0 * .pi * f1 * t) * 0.5 + sin(2.0 * .pi * f2 * t) * 0.3) * env
            samples[i] = Float(beep * 0.85)
        }
        return samples
    }

    // 10. Camera Shutter
    private func synthCameraShutter(keyType: KeyType) -> [Float] {
        let duration: Double = 0.085
        let totalSamples = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: totalSamples)

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate

            // First curtain snap
            let snap1Env = exp(-t * 350.0)
            let snap1 = sin(2.0 * .pi * 2300.0 * t) * snap1Env * 0.7

            // Mirror slap and second curtain snap after 18ms
            var slap: Double = 0
            if t > 0.018 {
                let t2 = t - 0.018
                let slapEnv = exp(-t2 * 140.0)
                slap = (sin(2.0 * .pi * 180.0 * t2) * 0.6 + sin(2.0 * .pi * 1800.0 * t2) * 0.4) * slapEnv
            }

            let noiseEnv = exp(-t * 500.0)
            let noise = Float.random(in: -0.1...0.1) * Float(noiseEnv)

            let sample = Float(snap1 + slap) + noise
            samples[i] = max(-1.0, min(1.0, sample * 0.9))
        }
        return samples
    }

    // MARK: - WAV Encoder

    private func createWAV(from floatSamples: [Float], sampleRate: Int) -> Data {
        var data = Data()
        let numChannels: UInt16 = 2
        let bitsPerSample: UInt16 = 16
        let byteRate = UInt32(sampleRate * Int(numChannels) * Int(bitsPerSample / 8))
        let blockAlign = UInt16(numChannels * (bitsPerSample / 8))
        let subchunk2Size = UInt32(floatSamples.count * Int(numChannels) * Int(bitsPerSample / 8))
        let chunkSize = 36 + subchunk2Size

        // RIFF header
        data.append(contentsOf: [0x52, 0x49, 0x46, 0x46]) // "RIFF"
        data.append(contentsOf: withUnsafeBytes(of: chunkSize.littleEndian) { Array($0) })
        data.append(contentsOf: [0x57, 0x41, 0x56, 0x45]) // "WAVE"

        // "fmt " chunk
        data.append(contentsOf: [0x66, 0x6D, 0x74, 0x20]) // "fmt "
        let subchunk1Size: UInt32 = 16
        data.append(contentsOf: withUnsafeBytes(of: subchunk1Size.littleEndian) { Array($0) })
        let audioFormat: UInt16 = 1 // PCM
        data.append(contentsOf: withUnsafeBytes(of: audioFormat.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: numChannels.littleEndian) { Array($0) })
        let sampleRateU32 = UInt32(sampleRate)
        data.append(contentsOf: withUnsafeBytes(of: sampleRateU32.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: byteRate.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: blockAlign.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: bitsPerSample.littleEndian) { Array($0) })

        // "data" chunk
        data.append(contentsOf: [0x64, 0x61, 0x74, 0x61]) // "data"
        data.append(contentsOf: withUnsafeBytes(of: subchunk2Size.littleEndian) { Array($0) })

        // 16-bit PCM Stereo samples (L and R duplicate)
        for sample in floatSamples {
            let clamped = max(-1.0, min(1.0, sample))
            let int16Sample = Int16(clamped * 32767.0).littleEndian
            withUnsafeBytes(of: int16Sample) { bytes in
                // Left channel
                data.append(contentsOf: bytes)
                // Right channel
                data.append(contentsOf: bytes)
            }
        }

        return data
    }
}
