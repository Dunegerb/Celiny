import Foundation
import Combine

/// Central coordinator - integra todos os serviços e gerencia estado global
class CelinyBrain: ObservableObject {
    
    // MARK: - Services
    
    let faceTracking: FaceTrackingManager
    let audio: AudioManager
    let voice: VoiceManager
    let memory: MemoryManager
    let session: SessionManager
    
    // MARK: - Published State
    
    @Published var currentExpression: FaceExpression = .neutral
    @Published var isListening: Bool = false
    @Published var isSpeaking: Bool = false
    @Published var isSeeing: Bool = false
    @Published var isLearning: Bool = false
    @Published var attentionLevel: Float = 0.0
    
    // MARK: - Private State
    
    private var cancellables = Set<AnyCancellable>()
    private var userProfile: UserProfile?
    
    // MARK: - Initialization
    
    init() {
        self.faceTracking = FaceTrackingManager()
        self.audio = AudioManager()
        self.voice = VoiceManager()
        self.memory = MemoryManager()
        self.session = SessionManager()
        
        setupBindings()
        loadUserProfile()
        
        print("🧠 Celiny Brain initialized")
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Face tracking -> Expression
        faceTracking.$currentExpression
            .receive(on: DispatchQueue.main)
            .sink { [weak self] expression in
                self?.currentExpression = expression
                self?.sessionRecordExpression(expression)
            }
            .store(in: &cancellables)
        
        faceTracking.$isTracking
            .receive(on: DispatchQueue.main)
            .assign(to: &$isSeeing)
        
        // Audio -> Listening state
        audio.$isRecording
            .receive(on: DispatchQueue.main)
            .assign(to: &$isListening)
        
        audio.$isSpeaking
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSpeaking in
                if isSpeaking {
                    self?.isLearning = true
                    self?.sessionRecordSignal(.voiceAmplitude, value: self?.audio.amplitude ?? 0)
                } else {
                    self?.isLearning = false
                }
            }
            .store(in: &cancellables)
        
        // Voice -> Speaking state
        voice.$isSpeaking
            .receive(on: DispatchQueue.main)
            .assign(to: &$isSpeaking)
        
        // Audio callbacks
        audio.onSpeechDetected = { [weak self] in
            self?.handleSpeechDetected()
        }
        
        audio.onSilenceDetected = { [weak self] in
            self?.handleSilenceDetected()
        }
        
        // Voice callbacks
        voice.onSpeechStarted = { [weak self] in
            HapticsEngine.shared.playSubtle()
        }
        
        voice.onSpeechFinished = { [weak self] in
            HapticsEngine.shared.playConfirm()
        }
    }
    
    private func loadUserProfile() {
        let context = CoreDataStack.shared.viewContext
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        request.fetchLimit = 1
        
        if let profile = try? context.fetch(request).first {
            userProfile = profile
        } else {
            let newProfile = UserProfile(context: context)
            newProfile.id = UUID()
            newProfile.createdAt = Date()
            userProfile = newProfile
            CoreDataStack.shared.saveContext()
        }
    }
    
    // MARK: - Lifecycle
    
    func start() {
        guard let profile = userProfile else { return }
        
        // Start session
        session.startSession(type: .passive, user: profile)
        
        // Start services
        faceTracking.start()
        audio.startRecording()
        
        print("▶️ Celiny started")
    }
    
    func stop() {
        faceTracking.stop()
        audio.stopRecording()
        voice.stop()
        session.endSession()
        
        // Consolidar memórias
        memory.consolidateMemories()
        
        print("⏹️ Celiny stopped")
    }
    
    // MARK: - Conversation
    
    func speak(_ text: String, emotion: EmotionType = .neutral) {
        voice.speak(text, emotion: emotion)
        
        // Store in memory
        memory.store(
            "Eu disse: \(text)",
            importance: 0.6,
            tags: ["speech", "output"]
        )
    }
    
    func processUserInput(_ text: String) {
        // Store in memory
        memory.store(
            "Usuário disse: \(text)",
            importance: 0.7,
            tags: ["speech", "input", "user"]
        )
        
        // Retrieve context
        let context = memory.retrieve(similarTo: text, limit: 3)
        let contextText = context.map { $0.content ?? "" }.joined(separator: "\n")
        
        print("🧠 Context retrieved: \(contextText)")
        
        // TODO: Process with LLM
        // For now, simple response
        let response = generateResponse(to: text, context: contextText)
        speak(response, emotion: .neutral)
    }
    
    private func generateResponse(to input: String, context: String) -> String {
        // Placeholder simple response
        if input.lowercased().contains("olá") || input.lowercased().contains("oi") {
            return "Olá! Como posso ajudar?"
        } else if input.lowercased().contains("como você está") {
            return "Estou ótima! E você?"
        } else {
            return "Entendi. Continue me contando."
        }
    }
    
    // MARK: - Session Recording
    
    private func sessionRecordExpression(_ expression: FaceExpression) {
        let value: Float = {
            switch expression {
            case .neutral: return 0.5
            case .happy: return 1.0
            case .sad: return 0.2
            case .surprised: return 0.9
            case .thinking: return 0.6
            case .speaking: return 0.7
            case .listening: return 0.6
            }
        }()
        
        session.recordSignal(type: .expression, value: value, metadata: ["expression": expression.rawValue])
    }
    
    private func sessionRecordSignal(_ type: SignalType, value: Float) {
        session.recordSignal(type: type, value: value)
    }
    
    // MARK: - Event Handlers
    
    private func handleSpeechDetected() {
        print("🎤 Speech detected")
        currentExpression = .listening
    }
    
    private func handleSilenceDetected() {
        print("🤫 Silence detected")
        if !isSpeaking {
            currentExpression = .neutral
        }
    }
    
    // MARK: - Statistics
    
    func getStats() -> BrainStats {
        let memoryStats = memory.getMemoryStats()
        let totalTime = session.getTotalSessionTime()
        
        return BrainStats(
            totalMemories: memoryStats.total,
            workingMemories: memoryStats.workingCount,
            episodicMemories: memoryStats.episodicCount,
            semanticMemories: memoryStats.semanticCount,
            totalSessionTime: totalTime,
            averageSessionDuration: session.getAverageSessionDuration()
        )
    }
}

// MARK: - Supporting Types

struct BrainStats {
    let totalMemories: Int
    let workingMemories: Int
    let episodicMemories: Int
    let semanticMemories: Int
    let totalSessionTime: TimeInterval
    let averageSessionDuration: TimeInterval
}
