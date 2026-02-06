import SwiftUI

/// Tela principal - Celiny vivo e interativo
struct MainView: View {
    
    @StateObject private var faceTracker = FaceTracker()
    @State private var selectedTab: MainTab = .home
    
    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Face principal (sempre visível)
                FaceView(
                    size: 240,
                    expression: faceTracker.currentExpression,
                    isListening: faceTracker.isListening,
                    isSpeaking: faceTracker.isSpeaking
                )
                .scaleIn(delay: 0.2)
                .padding(.top, DesignTokens.Spacing.xxxl)
                
                // Status indicators (discretos)
                StatusIndicators(tracker: faceTracker)
                    .fadeIn(delay: 0.4)
                    .padding(.top, DesignTokens.Spacing.md)
                
                Spacer()
                
                // Bottom navigation
                BottomNav(selectedTab:$selectedTab)
                    .slideIn(from: .bottom, delay: 0.6)
            }
        }
        .onAppear {
            faceTracker.start()
        }
        .sheet(item: $selectedTab) { tab in
            destinationView(for: tab)
        }
    }
    
    @ViewBuilder
    private func destinationView(for tab: MainTab) -> some View {
        switch tab {
        case .home:
            EmptyView()
        case .conversation:
            ConversationPlaceholder()
        case .training:
            TrainingPlaceholder()
        case .memories:
            MemoriesPlaceholder()
        case .settings:
            SettingsPlaceholder()
        }
    }
}

// MARK: - Status Indicators

struct StatusIndicators: View {
    @ObservedObject var tracker: FaceTracker
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            if tracker.isListening {
                StatusBadge(icon: "mic.fill", label: "ouvindo")
                    .transition(.scaleAndFade)
            }
            
            if tracker.isSeeing {
                StatusBadge(icon: "eye.fill", label: "vendo")
                    .transition(.scaleAndFade)
            }
            
            if tracker.isLearning {
                StatusBadge(icon: "brain.head.profile", label: "aprendendo")
                    .transition(.scaleAndFade)
            }
        }
        .animation(AnimationSystem.smooth, value: tracker.isListening)
        .animation(AnimationSystem.smooth, value: tracker.isSeeing)
        .animation(AnimationSystem.smooth, value: tracker.isLearning)
    }
}

struct StatusBadge: View {
    let icon: String
    let label: String
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 12))
            
            Text(label)
                .font(DesignTokens.Typography.footnote)
        }
        .foregroundColor(DesignTokens.Colors.foregroundMuted)
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.xxs)
        .background(DesignTokens.Colors.backgroundElevated)
        .cornerRadius(DesignTokens.Radii.full)
    }
}

// MARK: - Bottom Navigation

struct BottomNav: View {
    @Binding var selectedTab: MainTab
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.lg) {
            NavButton(
                icon: "bubble.left.and.bubble.right.fill",
                label: "Conversar",
                isSelected: selectedTab == .conversation
            ) {
                selectedTab = .conversation
            }
            
            NavButton(
                icon: "figure.run",
                label: "Treinar",
                isSelected: selectedTab == .training
            ) {
                selectedTab = .training
            }
            
            NavButton(
                icon: "star.fill",
                label: "Memórias",
                isSelected: selectedTab == .memories
            ) {
                selectedTab = .memories
            }
            
            NavButton(
                icon: "gearshape.fill",
                label: "Config",
                isSelected: selectedTab == .settings
            ) {
                selectedTab = .settings
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(
            DesignTokens.Colors.backgroundElevated
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct NavButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticsEngine.shared.playSubtle()
            action()
        }) {
            VStack(spacing: DesignTokens.Spacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                
                Text(label)
                    .font(DesignTokens.Typography.footnote)
            }
            .foregroundColor(
                isSelected ? DesignTokens.Colors.accentPrimary : DesignTokens.Colors.foregroundMuted
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Face Tracker (Simulado por enquanto)

class FaceTracker: ObservableObject {
    @Published var currentExpression: FaceExpression = .neutral
    @Published var isListening = false
    @Published var isSpeaking = false
    @Published var isSeeing = true
    @Published var isLearning = false
    
    func start() {
        // Simula estados aleatórios para demonstração
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            self?.randomizeStates()
        }
    }
    
    private func randomizeStates() {
        withAnimation(AnimationSystem.smooth) {
            let expressions: [FaceExpression] = [.neutral, .happy, .thinking, .listening]
            currentExpression = expressions.randomElement() ?? .neutral
            
            isListening = Bool.random()
            isLearning = Bool.random()
        }
    }
}

// MARK: - Tab Enum

enum MainTab: String, Identifiable {
    case home
    case conversation
    case training
    case memories
    case settings
    
    var id: String { rawValue }
}

// MARK: - Placeholders (serão substituídas depois)

struct ConversationPlaceholder: View {
    var body: some View {
        ZStack {
            DesignTokens.Colors.background.ignoresSafeArea()
            Text("Conversa").foregroundColor(.white)
        }
    }
}

struct TrainingPlaceholder: View {
    var body: some View {
        ZStack {
            DesignTokens.Colors.background.ignoresSafeArea()
            Text("Treino").foregroundColor(.white)
        }
    }
}

struct MemoriesPlaceholder: View {
    var body: some View {
        ZStack {
            DesignTokens.Colors.background.ignoresSafeArea()
            Text("Memórias").foregroundColor(.white)
        }
    }
}

struct SettingsPlaceholder: View {
    var body: some View {
        ZStack {
            DesignTokens.Colors.background.ignoresSafeArea()
            Text("Configurações").foregroundColor(.white)
        }
    }
}

// MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
