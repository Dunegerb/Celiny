import UIKit
import CoreHaptics

/// Engine de haptics texturizados com envelope completo (ataque, corpo, decaimento)
/// Sincronizado perfeitamente com animações visuais para feedback multicanal
class HapticsEngine {
    
    // Singleton para acesso global
    static let shared = HapticsEngine()
    
    private var engine: CHHapticEngine?
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {
        prepareHaptics()
    }
    
    // MARK: - Setup
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("⚠️ Device doesn't support haptics")
            return
        }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            // Reset engine when app moves to background
            engine?.resetHandler = { [weak self] in
                print("🔄 Haptics engine reset")
                do {
                    try self?.engine?.start()
                } catch {
                    print("❌ Failed to restart haptics: \(error)")
                }
            }
            
            // Prepare fallback generators
            impactGenerator.prepare()
            selectionGenerator.prepare()
            notificationGenerator.prepare()
            
        } catch {
            print("❌ Failed to create haptics engine: \(error)")
        }
    }
    
    // MARK: - Public API: Textured Haptics
    
    /// Haptic confirm - Ataque rápido, decaimento suave
    /// Usa: Botões primários, confirmações, ações bem-sucedidas
    func playConfirm() {
        if let pattern = createConfirmPattern() {
            playPattern(pattern)
        } else {
            // Fallback to impact generator
            impactGenerator.impactOccurred(intensity: 0.7)
        }
    }
    
    /// Haptic alert - Dois pulsos distintos
    /// Usa: Avisos importantes, necessidade de atenção
    func playAlert() {
        if let pattern = createAlertPattern() {
            playPattern(pattern)
        } else {
            notificationGenerator.notificationOccurred(.warning)
        }
    }
    
    /// Haptic success - Textura crescente
    /// Usa: Conclusão de tarefas, progressos alcançados
    func playSuccess() {
        if let pattern = createSuccessPattern() {
            playPattern(pattern)
        } else {
            notificationGenerator.notificationOccurred(.success)
        }
    }
    
    /// Haptic subtle - Single tap gentil
    /// Usa: Navegação, mudanças de estado suaves
    func playSubtle() {
        selectionGenerator.selectionChanged()
    }
    
    /// Haptic error - Vibração distintiva de falha
    /// Usa: Erros, ações bloqueadas
    func playError() {
        if let pattern = createErrorPattern() {
            playPattern(pattern)
        } else {
            notificationGenerator.notificationOccurred(.error)
        }
    }
    
    // MARK: - Pattern Creation
    
    private func createConfirmPattern() -> CHHapticPattern? {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )
        
        do {
            return try CHHapticPattern(events: [event], parameters: [])
        } catch {
            print("❌ Failed to create confirm pattern: \(error)")
            return nil
        }
    }
    
    private func createAlertPattern() -> CHHapticPattern? {
        // Dois pulsos com 100ms de intervalo
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
        
        let event1 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )
        
        let event2 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0.1
        )
        
        do {
            return try CHHapticPattern(events: [event1, event2], parameters: [])
        } catch {
            print("❌ Failed to create alert pattern: \(error)")
            return nil
        }
    }
    
    private func createSuccessPattern() -> CHHapticPattern? {
        // Textura crescente: 3 pulsos com intensidade crescente
        var events: [CHHapticEvent] = []
        
        for i in 0..<3 {
            let intensity = CHHapticEventParameter(
                parameterID: .hapticIntensity,
                value: Float(0.4 + (Double(i) * 0.2))
            )
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensity, sharpness],
                relativeTime: Double(i) * 0.08
            )
            events.append(event)
        }
        
        do {
            return try CHHapticPattern(events: events, parameters: [])
        } catch {
            print("❌ Failed to create success pattern: \(error)")
            return nil
        }
    }
    
    private func createErrorPattern() -> CHHapticPattern? {
        // Padrão distintivo: pulso forte seguido de dois fracos
        let strongIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let weakIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        
        let event1 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [strongIntensity, sharpness],
            relativeTime: 0
        )
        
        let event2 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [weakIntensity, sharpness],
            relativeTime: 0.1
        )
        
        let event3 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [weakIntensity, sharpness],
            relativeTime: 0.15
        )
        
        do {
            return try CHHapticPattern(events: [event1, event2, event3], parameters: [])
        } catch {
            print("❌ Failed to create error pattern: \(error)")
            return nil
        }
    }
    
    private func playPattern(_ pattern: CHHapticPattern) {
        guard let engine = engine else { return }
        
        do {
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("❌ Failed to play haptic pattern: \(error)")
        }
    }
}

// MARK: - SwiftUI Integration

extension View {
    /// Adiciona haptic confirm ao tap gesture
    func hapticConfirmOnTap(perform action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            HapticsEngine.shared.playConfirm()
            action()
        }
    }
    
    /// Adiciona haptic subtle ao tap gesture
    func hapticSubtleOnTap(perform action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            HapticsEngine.shared.playSubtle()
            action()
        }
    }
}
