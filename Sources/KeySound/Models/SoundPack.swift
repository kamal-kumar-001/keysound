import Foundation

public enum SoundPackID: String, CaseIterable, Identifiable, Codable {
    case cherryBlue = "cherry_blue"
    case cherryBrown = "cherry_brown"
    case cherryRed = "cherry_red"
    case holyPanda = "holy_panda"
    case shotgun = "shotgun"
    case typewriter = "typewriter"
    case bubble = "bubble"
    case arcade8Bit = "arcade_8bit"
    case sciFiMech = "scifi_mech"
    case cameraShutter = "camera_shutter"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .cherryBlue: return "Cherry MX Blue"
        case .cherryBrown: return "Cherry MX Brown"
        case .cherryRed: return "Cherry MX Red"
        case .holyPanda: return "Holy Panda Thock"
        case .shotgun: return "Shotgun Action"
        case .typewriter: return "Vintage Typewriter"
        case .bubble: return "Bubble Pop"
        case .arcade8Bit: return "Retro 8-Bit"
        case .sciFiMech: return "Sci-Fi Cyber Relay"
        case .cameraShutter: return "Camera Shutter"
        }
    }

    public var subtitle: String {
        switch self {
        case .cherryBlue: return "Crisp tactile click & snap"
        case .cherryBrown: return "Balanced tactile gentle bump"
        case .cherryRed: return "Smooth linear soft bottom-out"
        case .holyPanda: return "Deep resonant mechanical thock"
        case .shotgun: return "Metallic pump slide & strike"
        case .typewriter: return "Steel hammer & carriage ding"
        case .bubble: return "Satisfying liquid drops"
        case .arcade8Bit: return "Chiptune arcade blips"
        case .sciFiMech: return "Futuristic UI relay chirp"
        case .cameraShutter: return "Mechanical SLR dual shutter"
        }
    }

    public var category: String {
        switch self {
        case .cherryBlue, .cherryBrown, .cherryRed, .holyPanda:
            return "Mechanical"
        case .typewriter:
            return "Vintage"
        case .shotgun:
            return "Tactical"
        case .bubble:
            return "Playful"
        case .arcade8Bit, .sciFiMech:
            return "Digital"
        case .cameraShutter:
            return "Acoustic"
        }
    }

    public var iconName: String {
        switch self {
        case .cherryBlue: return "keyboard"
        case .cherryBrown: return "square.grid.2x2"
        case .cherryRed: return "rectangle.fill"
        case .holyPanda: return "cube.fill"
        case .shotgun: return "bolt.shield.fill"
        case .typewriter: return "character.textbox"
        case .bubble: return "drop.fill"
        case .arcade8Bit: return "gamecontroller.fill"
        case .sciFiMech: return "cpu.fill"
        case .cameraShutter: return "camera.fill"
        }
    }
}
