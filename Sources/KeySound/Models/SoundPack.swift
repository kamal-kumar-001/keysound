import Foundation

public enum SoundPackID: String, CaseIterable, Identifiable, Codable {
    case cherryBlue = "cherry_blue"
    case cherryBrown = "cherry_brown"
    case cherryRed = "cherry_red"
    case holyPanda = "holy_panda"
    case alpsCream = "alps_cream"
    case shotgun = "shotgun"
    case katanaSteel = "katana_steel"
    case typewriter = "typewriter"
    case mouseClick = "mouse_click"
    case bubble = "bubble"
    case waterDrop = "water_drop"
    case arcade8Bit = "arcade_8bit"
    case laserBlaster = "laser_blaster"
    case sciFiMech = "scifi_mech"
    case cameraShutter = "camera_shutter"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .cherryBlue: return "Cherry MX Blue"
        case .cherryBrown: return "Cherry MX Brown"
        case .cherryRed: return "Cherry MX Red"
        case .holyPanda: return "Holy Panda Thock"
        case .alpsCream: return "Alps Cream Vintage"
        case .shotgun: return "Shotgun Pump Action"
        case .katanaSteel: return "Katana Blade Clash"
        case .typewriter: return "Vintage Typewriter"
        case .mouseClick: return "Gaming Mouse Switch"
        case .bubble: return "Bubble Pop"
        case .waterDrop: return "Pure Water Droplet"
        case .arcade8Bit: return "Retro 8-Bit Arcade"
        case .laserBlaster: return "Sci-Fi Laser Blaster"
        case .sciFiMech: return "Cyberpunk Relay"
        case .cameraShutter: return "Mechanical SLR Shutter"
        }
    }

    public var subtitle: String {
        switch self {
        case .cherryBlue: return "Crisp tactile click & snap"
        case .cherryBrown: return "Balanced tactile gentle bump"
        case .cherryRed: return "Smooth linear soft bottom-out"
        case .holyPanda: return "Deep resonant mechanical thock"
        case .alpsCream: return "Vintage Apple keyboard clack"
        case .shotgun: return "Punchy metallic rack & blast"
        case .katanaSteel: return "Sharp metallic blade impact & ring"
        case .typewriter: return "Steel hammer & carriage ding"
        case .mouseClick: return "Crisp Omron microswitch click"
        case .bubble: return "Satisfying liquid cavitation pop"
        case .waterDrop: return "Acoustic crystalline water splash"
        case .arcade8Bit: return "Chiptune arcade blips & powerup"
        case .laserBlaster: return "Sci-Fi energy beam & pew sound"
        case .sciFiMech: return "Futuristic UI relay chirp"
        case .cameraShutter: return "Mechanical SLR dual shutter"
        }
    }

    public var category: String {
        switch self {
        case .cherryBlue, .cherryBrown, .cherryRed, .holyPanda, .alpsCream:
            return "Mechanical"
        case .shotgun, .katanaSteel:
            return "Tactical"
        case .typewriter:
            return "Vintage"
        case .bubble, .waterDrop:
            return "Playful"
        case .arcade8Bit, .laserBlaster, .sciFiMech:
            return "Digital"
        case .cameraShutter, .mouseClick:
            return "Acoustic"
        }
    }

    public var iconName: String {
        switch self {
        case .cherryBlue: return "keyboard"
        case .cherryBrown: return "square.grid.2x2"
        case .cherryRed: return "rectangle.fill"
        case .holyPanda: return "cube.fill"
        case .alpsCream: return "square.3.layers.3d.down.right.fill"
        case .shotgun: return "bolt.shield.fill"
        case .katanaSteel: return "shield.slash.fill"
        case .typewriter: return "character.textbox"
        case .mouseClick: return "computermouse.fill"
        case .bubble: return "drop.fill"
        case .waterDrop: return "drop.circle.fill"
        case .arcade8Bit: return "gamecontroller.fill"
        case .laserBlaster: return "bolt.horizontal.fill"
        case .sciFiMech: return "cpu.fill"
        case .cameraShutter: return "camera.fill"
        }
    }
}
