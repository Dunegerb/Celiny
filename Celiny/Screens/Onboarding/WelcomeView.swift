import SwiftUI

/// Primeira tela - Boas-vindas
/// Objetivo: Apresentação minimalista com CTA claro
struct WelcomeView: View {
    
    @Binding var currentStep: OnboardingStep
    @State private var showPrivacy = false
    
    var body: some View {
        ZStack {
            // Background
            DesignTokens.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: DesignTokens.Spacing.xxl) {
                Spacer()
                
                // Face preview (animado)
                FaceView(size: 180, expression: .happy)
                    .scaleIn(delay: 0.2)
                
                // Frase única
                Text("Vamos treinar juntos")
                    .font(DesignTokens.Typography.title1)
                    .foregroundColor(DesignTokens.Colors.foreground)
                    .multilineTextAlignment(.center)
                    .fadeIn(delay: 0.4)
                
                Text("Eu aprendo e evoluo com você,\ncompletamente privado e local")
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(DesignTokens.Colors.foregroundMuted)
                    .multilineTextAlignment(.center)
                    .fadeIn(delay: 0.6)
                
                Spacer()
                
                // CTAs
                VStack(spacing: DesignTokens.Spacing.md) {
                    CelinyButton("Começar", style: .primary) {
                        withAnimation(AnimationSystem.spring) {
                            currentStep = .permissions
                        }
                    }
                    .fadeIn(delay: 0.8)
                    
                    Button("Privacidade") {
                        HapticsEngine.shared.playSubtle()
                        showPrivacy = true
                    }
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(DesignTokens.Colors.foregroundSubtle)
                    .fadeIn(delay: 1.0)
                }
                .padding(.bottom, DesignTokens.Spacing.xl)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacySheet()
        }
    }
}

// MARK: - Privacy Sheet

struct PrivacySheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignTokens.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                        PrivacyPoint(
                            icon: "lock.shield.fill",
                            title: "100% Local",
                            description: "Todo processamento acontece no seu dispositivo. Zero servidores, zero cloud."
                        )
                        
                        PrivacyPoint(
                            icon: "eye.slash.fill",
                            title: "Sem Vídeo",
                            description: "ARKit captura apenas sinais de movimento, não grava imagens ou vídeo."
                        )
                        
                        PrivacyPoint(
                            icon: "externaldrive.fill",
                            title: "Seus Dados",
                            description: "Memórias ficam apenas no seu iPhone. Você pode apagar tudo a qualquer momento."
                        )
                        
                        PrivacyPoint(
                            icon: "chart.line.downtrend.xyaxis",
                            title: "Zero Analytics",
                            description: "Nenhuma telemetria, nenhum tracking. Eu não sei quem você é."
                        )
                    }
                    .padding(DesignTokens.Spacing.lg)
                }
            }
            .navigationTitle("Privacidade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        HapticsEngine.shared.playSubtle()
                        dismiss()
                    }
                    .foregroundColor(DesignTokens.Colors.accentPrimary)
                }
            }
        }
    }
}

struct PrivacyPoint: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(DesignTokens.Colors.accentPrimary)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(title)
                    .font(DesignTokens.Typography.bodyEmphasized)
                    .foregroundColor(DesignTokens.Colors.foreground)
                
                Text(description)
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(DesignTokens.Colors.foregroundMuted)
            }
        }
    }
}

// MARK: - Onboarding Step Enum

enum OnboardingStep {
    case welcome
    case permissions
    case calibration
    case complete
}

// MARK: - Preview

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(currentStep: .constant(.welcome))
    }
}
