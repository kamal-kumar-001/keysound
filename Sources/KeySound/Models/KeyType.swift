import Foundation

public enum KeyType: String, CaseIterable, Codable {
    case standard
    case space
    case returnKey
    case backspace
    case modifier
    
    public static func from(keyCode: UInt16) -> (KeyType, String) {
        switch keyCode {
        case 49:
            return (.space, "Space")
        case 36, 76: // Return and Keypad Enter
            return (.returnKey, "Return")
        case 51, 117: // Backspace and Forward Delete
            return (.backspace, "Delete")
        case 54, 55:
            return (.modifier, "⌘ Cmd")
        case 56, 60:
            return (.modifier, "⇧ Shift")
        case 58, 61:
            return (.modifier, "⌥ Option")
        case 59, 62:
            return (.modifier, "⌃ Control")
        case 57:
            return (.modifier, "⇪ Caps")
        case 53:
            return (.modifier, "⎋ Esc")
        case 48:
            return (.standard, "Tab")
        case 0: return (.standard, "A")
        case 1: return (.standard, "S")
        case 2: return (.standard, "D")
        case 3: return (.standard, "F")
        case 4: return (.standard, "H")
        case 5: return (.standard, "G")
        case 6: return (.standard, "Z")
        case 7: return (.standard, "X")
        case 8: return (.standard, "C")
        case 9: return (.standard, "V")
        case 11: return (.standard, "B")
        case 12: return (.standard, "Q")
        case 13: return (.standard, "W")
        case 14: return (.standard, "E")
        case 15: return (.standard, "R")
        case 16: return (.standard, "Y")
        case 17: return (.standard, "T")
        case 31: return (.standard, "O")
        case 32: return (.standard, "U")
        case 34: return (.standard, "I")
        case 35: return (.standard, "P")
        case 37: return (.standard, "L")
        case 38: return (.standard, "J")
        case 40: return (.standard, "K")
        case 45: return (.standard, "N")
        case 46: return (.standard, "M")
        default:
            return (.standard, "Key")
        }
    }
}
