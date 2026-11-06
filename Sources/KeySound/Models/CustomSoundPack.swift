import Foundation

public struct CustomSoundPack: Identifiable, Codable, Equatable {
    public let id: String
    public var name: String
    public var iconName: String
    public var standardFileName: String
    public var spaceFileName: String?
    public var returnFileName: String?
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        name: String,
        iconName: String = "waveform",
        standardFileName: String,
        spaceFileName: String? = nil,
        returnFileName: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.standardFileName = standardFileName
        self.spaceFileName = spaceFileName
        self.returnFileName = returnFileName
        self.createdAt = createdAt
    }
}
