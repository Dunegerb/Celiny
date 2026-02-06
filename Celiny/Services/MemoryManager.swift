import Foundation
import CoreData

/// Memory system com 3 camadas: Working, Episodic, Semantic
class MemoryManager: ObservableObject {
    
    // MARK: - Memory Layers
    
    enum MemoryLayer: String {
        case working    // Contexto imediato (últimos minutos)
        case episodic   // Experiências específicas (sessões)
        case semantic   // Conhecimento consolidado (padrões)
    }
    
    // MARK: - Published State
    
    @Published var workingMemories: [Memory] = []
    @Published var recentEpisodicMemories: [Memory] = []
    
    // MARK: - Core Data
    
    private let context: NSManagedObjectContext
    private let userProfile: UserProfile
    
    // MARK: - Configuration
    
    private let workingMemoryCapacity = 7  // Miller's Law: 7±2
    private let workingMemoryDuration: TimeInterval = 300 // 5 minutos
    private let importanceThreshold: Float = 0.7
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
        
        // Fetch or create user profile
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        request.fetchLimit = 1
        
        if let existingProfile = try? context.fetch(request).first {
            self.userProfile = existingProfile
        } else {
            let newProfile = UserProfile(context: context)
            newProfile.id = UUID()
            newProfile.createdAt = Date()
            self.userProfile = newProfile
            CoreDataStack.shared.saveContext()
        }
        
        loadWorkingMemories()
        print("✅ Memory Manager initialized")
    }
    
    // MARK: - Store Memory
    
    func store(_ content: String, importance: Float = 0.5, tags: [String] = []) {
        let memory = Memory(context: context)
        memory.id = UUID()
        memory.content = content
        memory.importance = importance
        memory.createdAt = Date()
        memory.lastAccessed = Date()
        memory.accessCount = Int32(0)
        memory.tags = tags
        memory.user = userProfile
        
        // Determinar camada baseado em importância
        if importance >= importanceThreshold {
            memory.memoryLayer = MemoryLayer.semantic.rawValue
            print("💎 Semantic memory stored: \(content.prefix(50))...")
        } else {
            memory.memoryLayer = MemoryLayer.working.rawValue
            print("🧠 Working memory stored: \(content.prefix(50))...")
        }
        
        CoreDataStack.shared.saveContext()
        loadWorkingMemories()
        
        // Limpar working memory se exceder capacidade
        cleanupWorkingMemory()
    }
    
    // MARK: - Retrieve Memory
    
    func retrieve(similarTo query: String, limit: Int = 5) -> [Memory] {
        // Por enquanto, busca simples por conteúdo
        // TODO: Implementar embedding similarity search
        
        let request: NSFetchRequest<Memory> = Memory.fetchRequest()
        request.predicate = NSPredicate(format: "content CONTAINS[cd] %@", query)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Memory.importance, ascending: false),
            NSSortDescriptor(keyPath: \Memory.lastAccessed, ascending: false)
        ]
        request.fetchLimit = limit
        
        do {
            let results = try context.fetch(request)
            
            // Update access count
            for memory in results {
                memory.accessCount += 1
                memory.lastAccessed = Date()
            }
            CoreDataStack.shared.saveContext()
            
            return results
        } catch {
            print("❌ Memory retrieval error: \(error)")
            return []
        }
    }
    
    func retrieveByLayer(_ layer: MemoryLayer, limit: Int = 10) -> [Memory] {
        let request: NSFetchRequest<Memory> = Memory.fetchRequest()
        request.predicate = NSPredicate(format: "memoryLayer == %@", layer.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Memory.createdAt, ascending: false)]
        request.fetchLimit = limit
        
        return (try? context.fetch(request)) ?? []
    }
    
    // MARK: - Consolidation
    
    func consolidateMemories() {
        // Promover working memories importantes para episodic/semantic
        let workingMems = retrieveByLayer(.working, limit: 100)
        
        for memory in workingMems {
            // Critério: alta importância + múltiplos acessos
            if memory.importance > importanceThreshold && memory.accessCount > 3 {
                memory.memoryLayer = MemoryLayer.semantic.rawValue
                print("⬆️ Memory promoted to semantic: \(memory.content?.prefix(50) ?? "")")
            } else if memory.accessCount > 1 {
                memory.memoryLayer = MemoryLayer.episodic.rawValue
            }
        }
        
        CoreDataStack.shared.saveContext()
    }
    
    // MARK: - Cleanup
    
    private func loadWorkingMemories() {
        workingMemories = retrieveByLayer(.working, limit: workingMemoryCapacity)
    }
    
    private func cleanupWorkingMemory() {
        let allWorking = retrieveByLayer(.working, limit: 100)
        
        // Remover working memories antigas
        let cutoffDate = Date().addingTimeInterval(-workingMemoryDuration)
        let oldMemories = allWorking.filter { memory in
            guard let created = memory.createdAt else { return false }
            return created < cutoffDate && memory.accessCount == 0
        }
        
        for memory in oldMemories {
            context.delete(memory)
            print("🗑️ Deleted old working memory: \(memory.content?.prefix(30) ?? "")")
        }
        
        // Se ainda exceder capacidade, remover menos importantes
        if allWorking.count > workingMemoryCapacity {
            let sorted = allWorking.sorted { ($0.importance, $0.accessCount) < ($1.importance, $1.accessCount) }
            let toRemove = sorted.prefix(allWorking.count - workingMemoryCapacity)
            
            for memory in toRemove {
                context.delete(memory)
            }
        }
        
        CoreDataStack.shared.saveContext()
        loadWorkingMemories()
    }
    
    // MARK: - Statistics
    
    func getMemoryStats() -> MemoryStats {
        let working = retrieveByLayer(.working).count
        let episodic = retrieveByLayer(.episodic, limit: 1000).count
        let semantic = retrieveByLayer(.semantic, limit: 1000).count
        
        return MemoryStats(
            workingCount: working,
            episodicCount: episodic,
            semanticCount: semantic
        )
    }
}

// MARK: - Supporting Types

struct MemoryStats {
    let workingCount: Int
    let episodicCount: Int
    let semanticCount: Int
    
    var total: Int {
        workingCount + episodicCount + semanticCount
    }
}
