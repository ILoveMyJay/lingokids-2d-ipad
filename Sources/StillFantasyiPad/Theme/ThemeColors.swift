import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // Still Fantasy Dark Emerald Palette
    static let darkEmeraldBg = Color(hex: "#07130E")
    static let darkEmeraldSurface = Color(hex: "#0A1A14")
    static let darkEmeraldCard = Color(hex: "#0F241C")
    static let darkEmeraldBorder = Color(hex: "#1D4234")
    static let darkEmeraldBorderSubtle = Color(hex: "#153126")

    // Bioluminescent Accents
    static let biolumMint = Color(hex: "#34D399")
    static let biolumEmerald = Color(hex: "#10B981")
    static let biolumLime = Color(hex: "#4ADE80")

    // Warm Golden Highlights
    static let amberGold = Color(hex: "#F59E0B")
    static let goldLight = Color(hex: "#FBBF24")

    // Text & Muted Shades
    static let textLight = Color(hex: "#E2F7ED")
    static let textMuted = Color(hex: "#A3C2B4")
}
