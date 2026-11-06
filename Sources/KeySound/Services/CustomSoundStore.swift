import Foundation
import AppKit

@MainActor
public final class CustomSoundStore: ObservableObject {
    public static let shared = CustomSoundStore()

    @Published public private(set) var customPacks: [CustomSoundPack] = []

    private let fileManager = FileManager.default
    private var cachedData: [String: Data] = [:]

    private var baseDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("KeySound/CustomPacks", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private var indexURL: URL {
        baseDirectory.appendingPathComponent("custom_packs.json")
    }

    private init() {
        loadPacks()
    }

    public func loadPacks() {
        guard fileManager.fileExists(atPath: indexURL.path),
              let data = try? Data(contentsOf: indexURL),
              let decoded = try? JSONDecoder().decode([CustomSoundPack].self, from: data) else {
            self.customPacks = []
            return
        }
        self.customPacks = decoded
    }

    private func savePacks() {
        if let data = try? JSONEncoder().encode(customPacks) {
            try? data.write(to: indexURL, options: .atomic)
        }
    }

    public func importPack(
        name: String,
        icon: String,
        standardURL: URL,
        spaceURL: URL? = nil,
        returnURL: URL? = nil
    ) throws -> CustomSoundPack {
        let id = UUID().uuidString
        let packDir = baseDirectory.appendingPathComponent(id, isDirectory: true)
        try fileManager.createDirectory(at: packDir, withIntermediateDirectories: true)

        let standardExt = standardURL.pathExtension.isEmpty ? "wav" : standardURL.pathExtension
        let standardFileName = "standard.\(standardExt)"
        let targetStandardURL = packDir.appendingPathComponent(standardFileName)

        let stdData = try Data(contentsOf: standardURL)
        try stdData.write(to: targetStandardURL, options: .atomic)

        var spaceFileName: String? = nil
        if let spaceURL = spaceURL {
            let spaceExt = spaceURL.pathExtension.isEmpty ? "wav" : spaceURL.pathExtension
            let fileName = "space.\(spaceExt)"
            let targetURL = packDir.appendingPathComponent(fileName)
            let data = try Data(contentsOf: spaceURL)
            try data.write(to: targetURL, options: .atomic)
            spaceFileName = fileName
            cachedData["\(id)_space"] = data
        }

        var returnFileName: String? = nil
        if let returnURL = returnURL {
            let returnExt = returnURL.pathExtension.isEmpty ? "wav" : returnURL.pathExtension
            let fileName = "return.\(returnExt)"
            let targetURL = packDir.appendingPathComponent(fileName)
            let data = try Data(contentsOf: returnURL)
            try data.write(to: targetURL, options: .atomic)
            returnFileName = fileName
            cachedData["\(id)_returnKey"] = data
        }

        let newPack = CustomSoundPack(
            id: id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Custom Sound" : name,
            iconName: icon,
            standardFileName: standardFileName,
            spaceFileName: spaceFileName,
            returnFileName: returnFileName
        )

        customPacks.append(newPack)
        savePacks()

        cachedData["\(id)_standard"] = stdData
        return newPack
    }

    public func removePack(id: String) {
        let packDir = baseDirectory.appendingPathComponent(id, isDirectory: true)
        try? fileManager.removeItem(at: packDir)

        customPacks.removeAll { $0.id == id }
        savePacks()

        cachedData.removeValue(forKey: "\(id)_standard")
        cachedData.removeValue(forKey: "\(id)_space")
        cachedData.removeValue(forKey: "\(id)_returnKey")
        cachedData.removeValue(forKey: "\(id)_backspace")
        cachedData.removeValue(forKey: "\(id)_modifier")
    }

    public func audioData(for packId: String, keyType: KeyType) -> Data? {
        let cacheKey = "\(packId)_\(keyType.rawValue)"
        if let cached = cachedData[cacheKey] {
            return cached
        }

        guard let pack = customPacks.first(where: { $0.id == packId }) else { return nil }
        let packDir = baseDirectory.appendingPathComponent(packId, isDirectory: true)

        let targetFileName: String
        switch keyType {
        case .space:
            targetFileName = pack.spaceFileName ?? pack.standardFileName
        case .returnKey:
            targetFileName = pack.returnFileName ?? pack.standardFileName
        default:
            targetFileName = pack.standardFileName
        }

        let fileURL = packDir.appendingPathComponent(targetFileName)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }

        cachedData[cacheKey] = data
        return data
    }
}
