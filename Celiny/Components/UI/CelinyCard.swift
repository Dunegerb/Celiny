import SwiftUI

/// Card component com elevação sutil e glassmorphism opcional
struct CelinyCard<Content: View>: View {
    
    let content: Content
    let style: CardStyle
    
    init(style: CardStyle = .elevated, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(DesignTokens.Spacing.md)
            .background(backgroundColor)
            .cornerRadius(DesignTokens.Radii.lg)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radii.lg)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadowStyle(shadowStyle)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .elevated:
            return DesignTokens.Colors.backgroundElevated
        case .glass:
            return DesignTokens.Colors.glassLight
        case .flat:
            return DesignTokens.Colors.background
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .glass:
            return DesignTokens.Colors.glassLight
        case .flat:
            return DesignTokens.Colors.foregroundSubtle.opacity(0.2)
        default:
            return Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .glass, .flat:
            return 1
        default:
            return 0
        }
    }
    
    private var shadowStyle: ShadowStyle {
        switch style {
        case .elevated:
            return DesignTokens.Shadows.md
        default:
            return ShadowStyle(color: .clear, radius: 0, x: 0, y: 0)
        }
    }
    
    enum CardStyle {
        case elevated  // Fundo sólido com sombra
        case glass     // Glassmorphism
        case flat      // Sem elevação
    }
}

// MARK: - Tappable Card Variant

struct TappableCelinyCard<Content: View>: View {
    let content: Content
    let style: CelinyCard<Content>.CardStyle
    let action: () -> Void
    
    init(
        style: CelinyCard<Content>.CardStyle = .elevated,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: {
            HapticsEngine.shared.playSubtle()
            action()
        }) {
            CelinyCard(style: style) {
                content
            }
        }
        .buttonStyle(CardPressStyle())
    }
}

struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(AnimationSystem.quick, value: configuration.isPressed)
    }
}

// MARK: - Preview

struct CelinyCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: DesignTokens.Spacing.lg) {
                CelinyCard(style: .elevated) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text("Card Elevated")
                            .font(DesignTokens.Typography.title3)
                            .foregroundColor(DesignTokens.Colors.foreground)
                        
                        Text("Com sombra sutil")
                            .font(DesignTokens.Typography.caption)
                            .foregroundColor(DesignTokens.Colors.foregroundMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                CelinyCard(style: .glass) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text("Card Glass")
                            .font(DesignTokens.Typography.title3)
                            .foregroundColor(DesignTokens.Colors.foreground)
                        
                        Text("Glassmorphism")
                            .font(DesignTokens.Typography.caption)
                            .foregroundColor(DesignTokens.Colors.foregroundMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                TappableCelinyCard(style: .elevated, action: {
                    print("Card tapped")
                }) {
                    HStack {
                        FaceView(size: 60, expression: .happy)
                        
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                            Text("Memória")
                                .font(DesignTokens.Typography.bodyEmphasized)
                                .foregroundColor(DesignTokens.Colors.foreground)
                            
                            Text("Há 2 horas")
                                .font(DesignTokens.Typography.label)
                                .foregroundColor(DesignTokens.Colors.foregroundMuted)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(DesignTokens.Spacing.lg)
        }
    }
}
