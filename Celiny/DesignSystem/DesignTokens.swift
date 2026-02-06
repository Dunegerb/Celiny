import SwiftUI

/// Design tokens seguindo filosofia neurocientífica de UX
/// Paleta monocromática com viés frio imperceptível para conforto visual prolongado
struct DesignTokens {
    
    // MARK: - Colors (Quase-preto / Quase-branco com viés azulado frio)
    
    struct Colors {
        // Background: Quase-preto com 240° hue sutil, L* ~3.5
        static let background = Color(hex: "#0A0A0E")
        static let backgroundElevated = Color(hex: "#141419")
        static let backgroundOverlay = Color(hex: "#1A1A20")
        
        // Foreground: Quase-branco com viés frio
        static let foreground = Color(hex: "#F5F5FA")
        static let foregroundMuted = Color(hex: "#A8A8B8")
        static let foregroundSubtle = Color(hex: "#6B6B7A")
        
        // Accent: Único acento funcional, saturação contida
        static let accentPrimary = Color(hex: "#6B7AFF")
        static let accentSecondary = Color(hex: "#5A6AE8")
        static let accentTertiary = Color(hex: "#4A5AD0")
        
        // Semantic
        static let success = Color(hex: "#4CAF50")
        static let warning = Color(hex: "#FF9800")
        static let alert = Color(hex: "#FF9800")
        static let error = Color(hex: "#F44336")
        
        // Overlay
        static let scrim = Color.black.opacity(0.7)
        static let glassDark = Color.white.opacity(0.05)
        static let glassLight = Color.white.opacity(0.1)
    }
    
    // MARK: - Spacing (Escala harmônica 4pt)
    
    struct Spacing {
        static let xxxs: CGFloat = 2   // Detalhes micro
        static let xxs: CGFloat = 4    // Espaçamento mínimo
        static let xs: CGFloat = 8     // Padding interno pequeno
        static let sm: CGFloat = 12    // Espaçamento entre elementos próximos
        static let md: CGFloat = 16    // Espaçamento padrão
        static let lg: CGFloat = 24    // Separação de grupos
        static let xl: CGFloat = 32    // Separação de seções
        static let xxl: CGFloat = 48   // Margem grande
        static let xxxl: CGFloat = 64  // Hero spacing
    }
    
    // MARK: - Typography (SF Pro System)
    
    struct Typography {
        // Títulos
        static let title1 = Font.system(size: 34, weight: .semibold, design: .default)
        static let title2 = Font.system(size: 28, weight: .semibold, design: .default)
        static let title3 = Font.system(size: 22, weight: .medium, design: .default)
        
        // Corpo
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let bodyEmphasized = Font.system(size: 17, weight: .medium, design: .default)
        
        // Secundário
        static let caption = Font.system(size: 15, weight: .regular, design: .default)
        static let captionEmphasized = Font.system(size: 15, weight: .medium, design: .default)
        
        // Rótulos
        static let label = Font.system(size: 13, weight: .regular, design: .default)
        static let labelEmphasized = Font.system(size: 13, weight: .semibold, design: .default)
        
        // Micro
        static let footnote = Font.system(size: 11, weight: .regular, design: .default)
    }
    
    // MARK: - Radii (Bordas arredondadas)
    
    struct Radii {
        static let none: CGFloat = 0
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 9999  // Circular
    }
    
    // MARK: - Shadows (Sutis, apenas quando necessário)
    
    struct Shadows {
        static let sm = ShadowStyle(
            color: Color.black.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )
        
        static let md = ShadowStyle(
            color: Color.black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        
        static let lg = ShadowStyle(
            color: Color.black.opacity(0.2),
            radius: 16,
            x: 0,
            y: 8
        )
    }
    
    // MARK: - Motion (Durações e curvas)
    
    struct Motion {
        // Durações calibradas ao cérebro
        static let instant: Double = 0.1    // Feedback imediato
        static let quick: Double = 0.2      // Microinterações
        static let smooth: Double = 0.3     // Transições padrão
        static let deliberate: Double = 0.4 // Navegação
        static let slow: Double = 0.6       // Ênfase
        
        // Curvas de aceleração naturais (spring physics)
        static let spring = Animation.spring(response: 0.4, dampingFraction: 0.75)
        static let springBouncy = Animation.spring(response: 0.5, dampingFraction: 0.65)
        static let easeInOut = Animation.easeInOut(duration: smooth)
        static let easeOut = Animation.easeOut(duration: quick)
    }
    
    // MARK: - Touch Targets (Lei de Fitts)
    
    struct TouchTargets {
        static let minimum: CGFloat = 44    // iOS HIG minimum
        static let comfortable: CGFloat = 56  // Ideal para polegares
        static let large: CGFloat = 72      // Ações primárias
    }
}

// MARK: - Helper Extensions

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
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Modifiers para aplicar tokens

extension View {
    func shadowStyle(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
