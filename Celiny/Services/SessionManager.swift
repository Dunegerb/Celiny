import Foundation
import CoreData

/// Session tracking e analytics comportamental
class SessionManager: ObservableObject {
    
    // MARK: - Session Types
    
    enum SessionType: String {
        case conversation = "conversation"
        case training = "training"
        case calibration = "calibration"
        case passive = "passive"
    }
    
    // MARK: - Published State
    
    @Published var currentSession: Session?
    @Published var isSessionActive: Bool = false
    
    // MARK: - Core Data
    
    private let context: NSManagedObjectContext
    private var sessionStartTime: Date?
    
    // MARK: - Behavior Tracking
    
    private var behaviorSignals: [BehaviorSignal] = []
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
        print("✅ Session Manager initialized")
    }
    
    // MARK: - Session Control
    
    func startSession(type: SessionType, user: UserProfile) {
        guard currentSession == nil else {
            print("⚠️ Session already active")
            return
        }
        
        let session = Session(context: context)
        session.id = UUID()
        session.startedAt = Date()
        session.type = type.rawValue
        session.user = user
        
        currentSession = session
        sessionStartTime = Date()
        isSessionActive = true
        
        CoreDataStack.shared.saveContext()
        
        print("▶️ Session started: \(type.rawValue)")
    }
    
    func endSession() {
        guard let session = currentSession else {
            print("⚠️ No active session to end")
            return
        }
        
        let endTime = Date()
        session.endedAt = endTime
        
        if let startTime = sessionStartTime {
            session.duration = endTime.timeIntervalSince(startTime)
        }
        
        // Salvar sinais comportamentais
        for signal in behaviorSignals {
            signal.session = session
        }
        
        CoreDataStack.shared.saveContext()
        
        print("⏹️ Session ended - Duration: \(session.duration)s, Signals: \(behaviorSignals.count)")
        
        currentSession = nil
        sessionStartTime = nil
        isSessionActive = false
        behaviorSignals.removeAll()
    }
    
    // MARK: - Behavior Signals
    
    func recordSignal(type: SignalType, value: Float, metadata: [String: Any]? = nil) {
        guard currentSession != nil else { return }
        
        let signal = BehaviorSignal(context: context)
        signal.id = UUID()
        signal.timestamp = Date()
        signal.signalType = type.rawValue
        signal.value = value
        
        if let metadata = metadata {
            signal.metadata = metadata
        }
        
        behaviorSignals.append(signal)
        
        // Salvar a cada 10 sinais para evitar perda de dados
        if behaviorSignals.count % 10 == 0 {
            CoreDataStack.shared.saveContext()
        }
    }
    
    // MARK: - Analytics
    
    func getSessionHistory(limit: Int = 10) -> [Session] {
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Session.startedAt, ascending: false)]
        request.fetchLimit = limit
        
        return (try? context.fetch(request)) ?? []
    }
    
    func getTotalSessionTime() -> TimeInterval {
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        let sessions = (try? context.fetch(request)) ?? []
        
        return sessions.reduce(0) { $0 + $1.duration }
    }
    
    func getAverageSessionDuration() -> TimeInterval {
        let sessions = getSessionHistory(limit: 100)
        guard !sessions.isEmpty else { return 0 }
        
        let total = sessions.reduce(0) { $0 + $1.duration }
        return total / Double(sessions.count)
    }
    
    func getSignalStatistics(for type: SignalType) -> SignalStatistics {
        guard let session = currentSession else {
            return SignalStatistics(count: 0, average: 0, min: 0, max: 0)
        }
        
        let signals = behaviorSignals.filter { $0.signalType == type.rawValue }
        guard !signals.isEmpty else {
            return SignalStatistics(count: 0, average: 0, min: 0, max: 0)
        }
        
        let values = signals.map { $0.value }
        let sum = values.reduce(0, +)
        let avg = sum / Float(values.count)
        let min = values.min() ?? 0
        let max = values.max() ?? 0
        
        return SignalStatistics(
            count: values.count,
            average: avg,
            min: min,
            max: max
        )
    }
}

// MARK: - Supporting Types

enum SignalType: String {
    case headPose = "head_pose"
    case expression = "expression"
    case voiceAmplitude = "voice_amplitude"
    case attention = "attention"
    case engagement = "engagement"
}

struct SignalStatistics {
    let count: Int
    let average: Float
    let min: Float
    let max: Float
}
