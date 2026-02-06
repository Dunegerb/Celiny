import SwiftUI

/// Calibração rápida (<60s para sentir que está vivo)
/// Passos: 1) Rosto parado 2) Acompanha head 3) Imita sorriso 4) Reage a fala
struct CalibrationView: View {
    
    @Binding var currentStep: OnboardingStep
    @StateObject private var calibrationManager = CalibrationManager()
    
    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: DesignTokens.Spacing.xl) {
                // Progress dots
                CalibrationProgress(
                    currentStep: calibrationManager.currentCalibrationStep,
                    totalSteps: 4
                )
                .fadeIn()
                .padding(.top, DesignTokens.Spacing.xxl)
                
                Spacer()
                
                // Face (reage conforme calibração)
                FaceView(
                    size: 200,
                    expression: calibrationManager.faceExpression,
                    isSpeaking: calibrationManager.currentCalibrationStep == 4
                )
                .scaleIn(delay: 0.2)
                
                // Instruction text
                Text(calibrationManager.currentInstruction)
                    .font(DesignTokens.Typography.title3)
                    .foregroundColor(DesignTokens.Colors.foreground)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
                    .id(calibrationManager.currentCalibrationStep)  // Force re-render on step change
                
                Spacer()
                
                // Status indicator
                if calibrationManager.isProcessing {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: DesignTokens.Colors.accentPrimary))
                        
                        Text(calibrationManager.statusMessage)
                            .font(DesignTokens.Typography.caption)
                            .foregroundColor(DesignTokens.Colors.foregroundMuted)
                    }
                } else {
                    Text(calibrationManager.statusMessage)
                        .font(DesignTokens.Typography.caption)
                        .foregroundColor(DesignTokens.Colors.accentPrimary)
                }
                
                // Continue button (aparece apenas no final)
                if calibrationManager.isComplete {
                    CelinyButton("Pronto!", style: .primary) {
                        withAnimation(AnimationSystem.spring) {
                            currentStep = .complete
                        }
                    }
                    .scaleIn(delay: 0.3)
                    .padding(.bottom, DesignTokens.Spacing.xl)
                } else {
                    Color.clear
                        .frame(height: DesignTokens.TouchTargets.comfortable)
                        .padding(.bottom, DesignTokens.Spacing.xl)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
        }
        .onAppear {
            calibrationManager.startCalibration()
        }
    }
}

// MARK: - Calibration Progress Indicator

struct CalibrationProgress: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? DesignTokens.Colors.accentPrimary : DesignTokens.Colors.foregroundSubtle)
                    .frame(width: 8, height: 8)
                    .scaleEffect(step == currentStep ? 1.2 : 1.0)
                    .animation(AnimationSystem.spring, value: currentStep)
            }
        }
    }
}

// MARK: - Calibration Manager

class CalibrationManager: ObservableObject {
    @Published var currentCalibrationStep = 0
    @Published var faceExpression: FaceExpression = .neutral
    @Published var currentInstruction = ""
    @Published var statusMessage = ""
    @Published var isProcessing = false
    @Published var isComplete = false
    
    private let steps = [
        CalibrationStep(
            instruction: "Olhe para a câmera",
            status: "Iniciando câmera...",
            expression: .neutral,
            duration: 2.0
        ),
        CalibrationStep(
            instruction: "Vire levemente a cabeça",
            status: "Acompanhando você...",
            expression: .listening,
            duration: 3.0
        ),
        CalibrationStep(
            instruction: "Agora sorria",
            status: "Detectando sorriso...",
            expression: .happy,
            duration: 2.5
        ),
        CalibrationStep(
            instruction: "Diga algo",
            status: "Entendi!",
            expression: .speaking,
            duration: 3.0
        )
    ]
    
    func startCalibration() {
        performNextStep()
    }
    
    private func performNextStep() {
        guard currentCalibrationStep < steps.count else {
            completeCalibration()
            return
        }
        
        let step = steps[currentCalibrationStep]
        
        // Update UI
        withAnimation(AnimationSystem.smooth) {
            currentInstruction = step.instruction
            statusMessage = step.status
            isProcessing = true
        }
        
        // Simulate processing (em produção, seria ARKit real)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            withAnimation(AnimationSystem.springBouncy) {
                self?.faceExpression = step.expression
            }
            
            // Haptic feedback quando detecta ação
            HapticsEngine.shared.playSuccess()
            
            // Avançar automaticamente após duração
            DispatchQueue.main.asyncAfter(deadline: .now() + step.duration) { [weak self] in
                self?.advanceStep()
            }
        }
    }
    
    private func advanceStep() {
        currentCalibrationStep += 1
        
        if currentCalibrationStep < steps.count {
            performNextStep()
        } else {
            completeCalibration()
        }
    }
    
    private func completeCalibration() {
        withAnimation(AnimationSystem.smooth) {
            isProcessing = false
            currentInstruction = "Pronto, agora eu aprendo com você"
            statusMessage = "Calibração completa"
            faceExpression = .happy
            isComplete = true
        }
        
        HapticsEngine.shared.playSuccess()
    }
}

struct CalibrationStep {
    let instruction: String
    let status: String
    let expression: FaceExpression
    let duration: Double
}

// MARK: - Preview

struct CalibrationView_Previews: PreviewProvider {
    static var previews: some View {
        CalibrationView(currentStep: .constant(.calibration))
    }
}
