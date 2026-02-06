import SwiftUI

/// Rosto minimalista de Celiny
/// 2 círculos (olhos) + 1 cápsula arredondada (boca)
/// Capaz de piscar, sorrir, se surpreender, pensar, ouvir e falar
struct FaceView: View {
    
    @StateObject private var controller = FaceController()
    
    // Props para controle externo
    let size: CGFloat
    var expression: FaceExpression = .neutral
    var isListening: Bool = false
    var isSpeaking: Bool = false
    
    var body: some View {
        ZStack {
            // Eyes
            HStack(spacing: size * 0.15) {
                // Left eye
                Eye(
                    isBlinking: controller.isBlinking,
                    expression: expression,
                    size: size * 0.12
                )
                
                // Right eye
                Eye(
                    isBlinking: controller.isBlinking,
                    expression: expression,
                    size: size * 0.12
                )
            }
            .offset(y: -size * 0.1)
            
            // Mouth
            Mouth(
                expression: expression,
                isSpeaking: isSpeaking,
                width: size * 0.3,
                baseHeight: size * 0.06
            )
            .offset(y: size * 0.15)
        }
        .frame(width: size, height: size)
        .onAppear {
            controller.startBlinking()
        }
        .onChange(of: expression) { newExpression in
            controller.handleExpressionChange(newExpression)
        }
        .onChange(of: isListening) { listening in
            if listening {
                HapticsEngine.shared.playSubtle()
            }
        }
    }
}

// MARK: - Face Expression States

enum FaceExpression: Equatable {
    case neutral
    case happy
    case surprised
    case thinking
    case listening
    case speaking
    case sad
}

// MARK: - Eye Component

struct Eye: View {
    let isBlinking: Bool
    let expression: FaceExpression
    let size: CGFloat
    
    var body: some View {
        Capsule()
            .fill(DesignTokens.Colors.foreground)
            .frame(
                width: size,
                height: isBlinking ? size * 0.1 : eyeHeight
            )
            .scaleEffect(x: eyeWidth / size, y: 1.0)
            .animation(AnimationSystem.quick, value: isBlinking)
            .animation(AnimationSystem.springBouncy, value: expression)
    }
    
    private var eyeHeight: CGFloat {
        switch expression {
        case .neutral:
            return size
        case .happy:
            return size * 0.7  // Olhos se estreitam quando feliz
        case .surprised:
            return size * 1.3  // Olhos se alargam
        case .thinking:
            return size * 0.9
        case .listening:
            return size * 1.1
        case .speaking:
            return size
        case .sad:
            return size * 0.8
        }
    }
    
    private var eyeWidth: CGFloat {
        switch expression {
        case .surprised:
            return size * 1.2
        case .happy:
            return size * 0.9
        default:
            return size
        }
    }
}

// MARK: - Mouth Component

struct Mouth: View {
    let expression: FaceExpression
    let isSpeaking: Bool
    let width: CGFloat
    let baseHeight: CGFloat
    
    @State private var speakingPhase: CGFloat = 0
    
    var body: some View {
        Capsule()
            .fill(DesignTokens.Colors.foreground)
            .frame(
                width: mouthWidth,
                height: mouthHeight
            )
            .offset(y: mouthOffset)
            .animation(AnimationSystem.springBouncy, value: expression)
            .onChange(of: isSpeaking) { speaking in
                if speaking {
                    startSpeakingAnimation()
                } else {
                    speakingPhase = 0
                }
            }
    }
    
    private var mouthWidth: CGFloat {
        switch expression {
        case .neutral:
            return width
        case .happy:
            return width * 1.4  // Sorriso largo
        case .surprised:
            return width * 0.8  // Boca abre verticalmente
        case .thinking:
            return width * 0.7
        case .listening:
            return width * 0.9
        case .speaking:
            return width + (isSpeaking ? sin(speakingPhase) * width * 0.3 : 0)
        case .sad:
            return width * 1.2
        }
    }
    
    private var mouthHeight: CGFloat {
        let base = baseHeight
        switch expression {
        case .neutral:
            return base
        case .happy:
            return base * 0.8  // Boca fica mais fina no sorriso
        case .surprised:
            return base * 3.0  // Boca abre muito
        case .thinking:
            return base * 0.6
        case .listening:
            return base
        case .speaking:
            return base + (isSpeaking ? abs(cos(speakingPhase)) * base * 1.5 : 0)
        case .sad:
            return base * 0.7
        }
    }
    
    private var mouthOffset: CGFloat {
        switch expression {
        case .happy:
            return -baseHeight * 0.5  // Curva para cima
        case .sad:
            return baseHeight * 0.8  // Curva para baixo
        default:
            return 0
        }
    }
    
    private func startSpeakingAnimation() {
        withAnimation(
            Animation.linear(duration: 0.15)
                .repeatWhile({ isSpeaking })
        ) {
            speakingPhase += .pi * 2
        }
    }
}

// MARK: - Face Controller

class FaceController: ObservableObject {
    @Published var isBlinking = false
    
    private var blinkTimer: Timer?
    
    func startBlinking() {
        // Blink aleatório a cada 3-5 segundos
        scheduleNextBlink()
    }
    
    private func scheduleNextBlink() {
        let delay = Double.random(in: 3.0...5.0)
        blinkTimer?.invalidate()
        blinkTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.performBlink()
        }
    }
    
    private func performBlink() {
        withAnimation(AnimationSystem.quick) {
            isBlinking = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            withAnimation(AnimationSystem.quick) {
                self?.isBlinking = false
            }
            self?.scheduleNextBlink()
        }
    }
    
    func handleExpressionChange(_ expression: FaceExpression) {
        // Trigger haptic feedback for significant expression changes
        switch expression {
        case .happy:
            HapticsEngine.shared.playSuccess()
        case .surprised:
            HapticsEngine.shared.playAlert()
        default:
            break
        }
    }
    
    deinit {
        blinkTimer?.invalidate()
    }
}

// MARK: - Animation Helper Extension

extension Animation {
    func repeatWhile(_ condition: @escaping () -> Bool) -> Animation {
        return self.repeatForever(autoreverses: true)
    }
}

// MARK: - Preview

struct FaceView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: DesignTokens.Spacing.xl) {
                FaceView(size: 200, expression: .neutral)
                FaceView(size: 200, expression: .happy)
                FaceView(size: 200, expression: .surprised)
                FaceView(size: 200, expression: .thinking)
            }
        }
    }
}
