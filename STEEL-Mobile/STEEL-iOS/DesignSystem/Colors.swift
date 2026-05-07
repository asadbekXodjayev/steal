import SwiftUI

// MARK: - Design System Colors
// Military Dark Theme - Matching Web App Aesthetic

extension Color {
    // MARK: - Core Backgrounds
    static let background = Color(hex: "050505")
    static let backgroundSecondary = Color(hex: "0A0A0A")
    static let foreground = Color(hex: "E5E5E5")
    
    // MARK: - Cards
    static let card = Color(hex: "0A0A0A")
    static let cardForeground = Color(hex: "E5E5E5")
    static let cardBorder = Color(hex: "1A1A1A")
    
    // MARK: - Primary (Blood Red)
    static let primary = Color(hex: "8B0000")
    static let primaryHover = Color(hex: "9F1239")
    static let primaryActive = Color(hex: "B91C1C")
    
    // MARK: - Secondary (Forged Steel Orange)
    static let secondary = Color(hex: "C2410C")
    static let secondaryHover = Color(hex: "EA580C")
    static let secondaryActive = Color(hex: "F97316")
    
    // MARK: - Muted
    static let muted = Color(hex: "1A1A1A")
    static let mutedForeground = Color(hex: "A1A1AA")
    
    // MARK: - Tactical (Military Green)
    static let tactical = Color(hex: "166534")
    static let tacticalHover = Color(hex: "15803D")
    
    // MARK: - Ink (Text hierarchy)
    static let inkHigh = Color(hex: "E5E5E5")
    static let inkMid = Color(hex: "C9C9C9")
    static let inkLow = Color(hex: "A1A1AA")
    static let inkDim = Color(hex: "737373")
    
    // MARK: - Surfaces
    static let surface0 = Color(hex: "050505")
    static let surface1 = Color(hex: "0A0A0A")
    static let surface2 = Color(hex: "111111")
    static let surface3 = Color(hex: "171717")
    static let surface4 = Color(hex: "1F1F1F")
}

// MARK: - Color Initializer
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
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography
struct Typography {
    // Headlines
    static let headlineLarge = TextStyle(size: 32, weight: .bold, tracking: 4)
    static let headlineMedium = TextStyle(size: 28, weight: .bold, tracking: 2)
    static let headlineSmall = TextStyle(size: 24, weight: .bold, tracking: 1)
    
    // Titles
    static let titleLarge = TextStyle(size: 22, weight: .semibold, tracking: 1)
    static let titleMedium = TextStyle(size: 16, weight: .semibold, tracking: 0.5)
    static let titleSmall = TextStyle(size: 14, weight: .semibold, tracking: 0.1)
    
    // Body
    static let bodyLarge = TextStyle(size: 16, weight: .regular, tracking: 0.5)
    static let bodyMedium = TextStyle(size: 14, weight: .regular, tracking: 0.25)
    static let bodySmall = TextStyle(size: 12, weight: .regular, tracking: 0.4)
    
    // Labels
    static let labelLarge = TextStyle(size: 14, weight: .medium, tracking: 0.1)
    static let labelMedium = TextStyle(size: 12, weight: .medium, tracking: 0.5)
    static let labelSmall = TextStyle(size: 11, weight: .medium, tracking: 1)
    
    // Display (Branding)
    static let displayLarge = TextStyle(size: 48, weight: .bold, tracking: 4)
    static let displayMedium = TextStyle(size: 36, weight: .bold, tracking: 4)
    static let displaySmall = TextStyle(size: 28, weight: .bold, tracking: 4)
}

struct TextStyle {
    let size: CGFloat
    let weight: Font.Weight
    let tracking: CGFloat
    
    func font() -> Font {
        Font.system(size: size, weight: weight, design: .default)
    }
}