import SwiftUI
import AVFoundation
import UserNotifications

/// Tela de permissões
/// Objetivo: Pedir câmera, microfone e notificações de forma clara
struct PermissionsView: View {
    
    @Binding var currentStep: OnboardingStep
    @StateObject private var permissionManager = PermissionManager()
    
    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: DesignTokens.Spacing.xl) {
                // Header
                VStack(spacing: DesignTokens.Spacing.sm) {
                    Text("Permissões")
                        .font(DesignTokens.Typography.title1)
                        .foregroundColor(DesignTokens.Colors.foreground)
                    
                    Text("Para funcionar, preciso acessar:")
                        .font(DesignTokens.Typography.caption)
                        .foregroundColor(DesignTokens.Colors.foregroundMuted)
                }
                .fadeIn(delay: 0.1)
                
                // Permissions list
                VStack(spacing: DesignTokens.Spacing.md) {
                    PermissionRow(
                        icon: "camera.fill",
                        title: "Câmera",
                        description: "Para acompanhar seu rosto",
                        status: permissionManager.cameraStatus,
                        isRequired: true
                    ) {
                        permissionManager.requestCamera()
                    }
                    .fadeIn(delay: 0.2)
                    
                    PermissionRow(
                        icon: "mic.fill",
                        title: "Microfone",
                        description: "Para ouvir sua voz",
                        status: permissionManager.microphoneStatus,
                        isRequired: true
                    ) {
                        permissionManager.requestMicrophone()
                    }
                    .fadeIn(delay: 0.3)
                    
                    PermissionRow(
                        icon: "bell.fill",
                        title: "Notificações",
                        description: "Para o ritual diário (opcional)",
                        status: permissionManager.notificationStatus,
                        isRequired: false
                    ) {
                        permissionManager.requestNotifications()
                    }
                    .fadeIn(delay: 0.4)
                }
                
                Spacer()
                
                // Continue button (habilitado apenas se câmera + mic aprovados)
                CelinyButton("Continuar", style: .primary) {
                    withAnimation(AnimationSystem.spring) {
                        currentStep = .calibration
                    }
                }
                .disabled(!permissionManager.canProceed)
                .opacity(permissionManager.canProceed ? 1.0 : 0.5)
                .fadeIn(delay: 0.6)
                .padding(.bottom, DesignTokens.Spacing.xl)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
        }
    }
}

// MARK: - Permission Row

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let status: PermissionStatus
    let isRequired: Bool
    let action: () -> Void
    
    var body: some View {
        CelinyCard(style: .elevated) {
            HStack(spacing: DesignTokens.Spacing.md) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
                    .frame(width: 40)
                
                // Text
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                    HStack {
                        Text(title)
                            .font(DesignTokens.Typography.bodyEmphasized)
                            .foregroundColor(DesignTokens.Colors.foreground)
                        
                        if isRequired {
                            Text("*")
                                .font(DesignTokens.Typography.caption)
                                .foregroundColor(DesignTokens.Colors.error)
                        }
                    }
                    
                    Text(description)
                        .font(DesignTokens.Typography.caption)
                        .foregroundColor(DesignTokens.Colors.foregroundMuted)
                }
                
                Spacer()
                
                // Status indicator / Button
                statusView
            }
        }
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch status {
        case .notDetermined:
            Button("Permitir") {
                HapticsEngine.shared.playConfirm()
                action()
            }
            .font(DesignTokens.Typography.captionEmphasized)
            .foregroundColor(DesignTokens.Colors.accentPrimary)
            
        case .authorized:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(DesignTokens.Colors.success)
            
        case .denied:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(DesignTokens.Colors.error)
        }
    }
    
    private var iconColor: Color {
        switch status {
        case .authorized:
            return DesignTokens.Colors.success
        case .denied:
            return DesignTokens.Colors.error
        case .notDetermined:
            return DesignTokens.Colors.accentPrimary
        }
    }
}

// MARK: - Permission Manager

class PermissionManager: ObservableObject {
    @Published var cameraStatus: PermissionStatus = .notDetermined
    @Published var microphoneStatus: PermissionStatus = .notDetermined
    @Published var notificationStatus: PermissionStatus = .notDetermined
    
    var canProceed: Bool {
        cameraStatus == .authorized && microphoneStatus == .authorized
    }
    
    init() {
        checkCurrentPermissions()
    }
    
    func checkCurrentPermissions() {
        // Camera
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraStatus = .authorized
        case .denied, .restricted:
            cameraStatus = .denied
        case .notDetermined:
            cameraStatus = .notDetermined
        @unknown default:
            cameraStatus = .notDetermined
        }
        
        // Microphone
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            microphoneStatus = .authorized
        case .denied, .restricted:
            microphoneStatus = .denied
        case .notDetermined:
            microphoneStatus = .notDetermined
        @unknown default:
            microphoneStatus = .notDetermined
        }
        
        // Notifications (simplified for now)
        notificationStatus = .notDetermined
    }
    
    func requestCamera() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.cameraStatus = .authorized
                    HapticsEngine.shared.playSuccess()
                } else {
                    self?.cameraStatus = .denied
                    HapticsEngine.shared.playError()
                }
            }
        }
    }
    
    func requestMicrophone() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.microphoneStatus = .authorized
                    HapticsEngine.shared.playSuccess()
                } else {
                    self?.microphoneStatus = .denied
                    HapticsEngine.shared.playError()
                }
            }
        }
    }
    
    func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                if granted {
                    self?.notificationStatus = .authorized
                    HapticsEngine.shared.playSuccess()
                } else {
                    self?.notificationStatus = .denied
                }
            }
        }
    }
}

enum PermissionStatus {
    case notDetermined
    case authorized
    case denied
}

// MARK: - Preview

struct PermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsView(currentStep: .constant(.permissions))
    }
}
