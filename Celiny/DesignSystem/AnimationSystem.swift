import SwiftUI

/// Sistema de animação com física natural
/// Cada animação tem causa visível e propósito semântico
struct AnimationSystem {
    
    // MARK: - Core Animations
    
    /// Spring natural - Para transições orgânicas
    static let spring = Animation.spring(
        response: 0.4,
        dampingFraction: 0.75,
        blendDuration: 0
    )
    
    /// Spring bouncy - Para interações lúdicas (boca, olhos)
    static let springBouncy = Animation.spring(
        response: 0.5,
        dampingFraction: 0.65,
        blendDuration: 0
    )
    
    /// Smooth - Transições padrão
    static let smooth = Animation.easeInOut(duration: DesignTokens.Motion.smooth)
    
    /// Quick - Microinterações
    static let quick = Animation.easeOut(duration: DesignTokens.Motion.quick)
    
    /// Instant - Feedback imediato
    static let instant = Animation.easeOut(duration: DesignTokens.Motion.instant)
    
    /// Deliberate - Navegação entre telas
    static let deliberate = Animation.easeInOut(duration: DesignTokens.Motion.deliberate)
    
    // MARK: - Entrance Animations
    
    /// Fade in - Aparecimento suave
    static func fadeIn(delay: Double = 0) -> Animation {
        Animation.easeOut(duration: DesignTokens.Motion.smooth)
            .delay(delay)
    }
    
    /// Scale in - Crescimento orgânico
    static func scaleIn(delay: Double = 0) -> Animation {
        Animation.spring(response: 0.5, dampingFraction: 0.7)
            .delay(delay)
    }
    
    /// Slide in - Entrada com direção
    static func slideIn(delay: Double = 0) -> Animation {
        Animation.spring(response: 0.45, dampingFraction: 0.75)
            .delay(delay)
    }
    
    // MARK: - Exit Animations
    
    /// Fade out - Desaparecimento suave
    static func fadeOut(delay: Double = 0) -> Animation {
        Animation.easeIn(duration: DesignTokens.Motion.quick)
            .delay(delay)
    }
    
    /// Scale out - Encolhimento
    static func scaleOut(delay: Double = 0) -> Animation {
        Animation.easeIn(duration: DesignTokens.Motion.quick)
            .delay(delay)
    }
}

// MARK: - View Modifiers

struct FadeInModifier: ViewModifier {
    let delay: Double
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(AnimationSystem.fadeIn(delay: delay)) {
                    opacity = 1
                }
            }
    }
}

struct ScaleInModifier: ViewModifier {
    let delay: Double
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(AnimationSystem.scaleIn(delay: delay)) {
                    scale = 1.0
                    opacity = 1
                }
            }
    }
}

struct SlideInModifier: ViewModifier {
    let delay: Double
    let edge: Edge
    @State private var offset: CGFloat = 50
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: edge == .leading ? -offset : (edge == .trailing ? offset : 0),
                y: edge == .top ? -offset : (edge == .bottom ? offset : 0)
            )
            .opacity(opacity)
            .onAppear {
                withAnimation(AnimationSystem.slideIn(delay: delay)) {
                    offset = 0
                    opacity = 1
                }
            }
    }
}

struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    let duration: Double
    let scale: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? scale : 1.0)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    DesignTokens.Colors.glassLight,
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .rotationEffect(.degrees(30))
                        .offset(x: -geometry.size.width + phase)
                }
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 2.0)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = UIScreen.main.bounds.width * 2
                }
            }
            .clipped()
    }
}

// MARK: - Button Press Animation

struct ButtonPressModifier: ViewModifier {
    @Binding var isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isPressed ? 0.8 : 1.0)
            .animation(AnimationSystem.quick, value: isPressed)
    }
}

// MARK: - Extension for Easy Access

extension View {
    func fadeIn(delay: Double = 0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }
    
    func scaleIn(delay: Double = 0) -> some View {
        modifier(ScaleInModifier(delay: delay))
    }
    
    func slideIn(from edge: Edge = .bottom, delay: Double = 0) -> some View {
        modifier(SlideInModifier(delay: delay, edge: edge))
    }
    
    func pulse(duration: Double = 1.0, scale: CGFloat = 1.05) -> some View {
        modifier(PulseModifier(duration: duration, scale: scale))
    }
    
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
    
    func buttonPress(isPressed: Binding<Bool>) -> some View {
        modifier(ButtonPressModifier(isPressed: isPressed))
    }
}

// MARK: - Transition Helpers

extension AnyTransition {
    static var scaleAndFade: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 0.9).combined(with: .opacity)
        )
    }
    
    static func slideAndFade(from edge: Edge) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: edge).combined(with: .opacity),
            removal: .opacity
        )
    }
}
