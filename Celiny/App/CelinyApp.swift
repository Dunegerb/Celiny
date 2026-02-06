import SwiftUI

@main
struct CelinyApp: App {
    
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)  // Force dark mode sempre
        }
    }
}

// MARK: - Root View (gerencia onboarding vs main app)

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @State private var onboardingStep: OnboardingStep = .welcome
    
    var body: some View {
        ZStack {
            if appState.hasCompletedOnboarding {
                MainView()
                    .transition(.opacity)
            } else {
                OnboardingFlow(
                    currentStep: $onboardingStep,
                    onComplete: {
                        withAnimation(AnimationSystem.deliberate) {
                            appState.completeOnboarding()
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(AnimationSystem.deliberate, value: appState.hasCompletedOnboarding)
    }
}

// MARK: - Onboarding Flow

struct OnboardingFlow: View {
    @Binding var currentStep: OnboardingStep
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            switch currentStep {
            case .welcome:
                WelcomeView(currentStep: $currentStep)
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
            case .permissions:
                PermissionsView(currentStep: $currentStep)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
            case .calibration:
                CalibrationView(currentStep: $currentStep)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                
            case .complete:
                CompletionView(onDismiss: onComplete)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(AnimationSystem.deliberate, value: currentStep)
    }
}

// MARK: - Completion View

struct CompletionView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: DesignTokens.Spacing.xxl) {
                Spacer()
                
                FaceView(size: 200, expression: .happy)
                    .pulse(duration: 1.5, scale: 1.08)
                    .scaleIn(delay: 0.2)
                
                VStack(spacing: DesignTokens.Spacing.sm) {
                    Text("Estou pronta!")
                        .font(DesignTokens.Typography.title1)
                        .foregroundColor(DesignTokens.Colors.foreground)
                        .fadeIn(delay: 0.4)
                    
                    Text("Vamos começar a aprender juntos")
                        .font(DesignTokens.Typography.caption)
                        .foregroundColor(DesignTokens.Colors.foregroundMuted)
                        .fadeIn(delay: 0.6)
                }
                
                Spacer()
                
                CelinyButton("Vamos lá!", style: .primary) {
                    onDismiss()
                }
                .scaleIn(delay: 0.8)
                .padding(.bottom, DesignTokens.Spacing.xl)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
        }
        .onAppear {
            HapticsEngine.shared.playSuccess()
        }
    }
}

// MARK: - App State

class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
}
