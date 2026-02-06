import SwiftUI

/// Botão seguindo filosofia de design neurocientífico
/// Feedback multicanal (visual + motion + haptic) sincronizado
struct CelinyButton: View {
    
    // Props
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    
    // State
    @State private var isPressed = false
    
    init(_ title: String, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticsEngine.shared.playConfirm()
            action()
        }) {
            Text(title)
                .font(DesignTokens.Typography.bodyEmphasized)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: DesignTokens.TouchTargets.comfortable)
                .background(backgroundColor)
                .cornerRadius(DesignTokens.Radii.md)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radii.md)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        }
        .buttonStyle(PressButtonStyle())
    }
    
    // MARK: - Computed Styles
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return DesignTokens.Colors.accentPrimary
        case .secondary:
            return DesignTokens.Colors.backgroundElevated
        case .ghost:
            return Color.clear
        case .destructive:
            return DesignTokens.Colors.error
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary, .destructive:
            return DesignTokens.Colors.background
        case .secondary, .ghost:
            return DesignTokens.Colors.foreground
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .ghost, .secondary:
            return DesignTokens.Colors.foregroundSubtle
        default:
            return Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .ghost, .secondary:
            return 1
        default:
            return 0
        }
    }
    
    enum ButtonStyle {
        case primary
        case secondary
        case ghost
        case destructive
    }
}

// MARK: - Press Button Style (física dePress)

struct PressButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(AnimationSystem.quick, value: configuration.isPressed)
    }
}

// MARK: - Icon Button Variant

struct CelinyIconButton: View {
    let icon: String  // SF Symbol name
    let style: CelinyButton.ButtonStyle
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticsEngine.shared.playSubtle()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: DesignTokens.TouchTargets.minimum, height: DesignTokens.TouchTargets.minimum)
                .background(backgroundColor)
                .cornerRadius(DesignTokens.Radii.md)
        }
        .buttonStyle(PressButtonStyle())
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return DesignTokens.Colors.accentPrimary
        case .secondary:
            return DesignTokens.Colors.backgroundElevated
        case .ghost:
            return Color.clear
        case .destructive:
            return DesignTokens.Colors.error.opacity(0.2)
        }
    }
    
    private var iconColor: Color {
        switch style {
        case .primary:
            return DesignTokens.Colors.background
        case .destructive:
            return DesignTokens.Colors.error
        default:
            return DesignTokens.Colors.foreground
        }
    }
}

// MARK: - Preview

struct CelinyButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: DesignTokens.Spacing.md) {
                CelinyButton("Começar", style: .primary) {}
                CelinyButton("Secundário", style: .secondary) {}
                CelinyButton("Ghost", style: .ghost) {}
                CelinyButton("Apagar tudo", style: .destructive) {}
                
                HStack {
                    CelinyIconButton(icon: "mic.fill", style: .primary) {}
                    CelinyIconButton(icon: "heart", style: .secondary) {}
                    CelinyIconButton(icon: "trash", style: .destructive) {}
                }
            }
            .padding(DesignTokens.Spacing.lg)
        }
    }
}
