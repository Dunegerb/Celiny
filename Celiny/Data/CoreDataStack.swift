import Foundation
import CoreData

/// Core Data stack com persistência local thread-safe
class CoreDataStack {
    
    // MARK: - Singleton
    
    static let shared = CoreDataStack()
    
    // MARK: - Core Data Stack
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Celiny")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("❌ Core Data failed to load: \(error.localizedDescription). Attempting to recreate store...")
                
                // Tenta recuperar apagando o banco de dados (Nuclear option para evitar crash loop)
                try? container.persistentStoreCoordinator.destroyPersistentStore(at: description.url!, ofType: description.type, options: nil)
                
                container.loadPersistentStores { description, error in
                    if let error = error {
                        print("❌ Core Data RECOVERY failed: \(error.localizedDescription)")
                        // Em produção, não podemos dar fatalError. O app vai rodar sem persistência ou crashar mais tarde, mas tentamos evitar o crash imediato.
                    } else {
                        print("✅ Core Data recovered and loaded: \(description.url?.lastPathComponent ?? "unknown")")
                    }
                }
            } else {
                print("✅ Core Data loaded: \(description.url?.lastPathComponent ?? "unknown")")
            }
        }
        
        // Configurações de performance
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Background Context
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // MARK: - Save
    
    func saveContext() {
        let context = viewContext
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
            print("💾 Core Data saved")
        } catch {
            print("❌ Core Data save error: \(error)")
        }
    }
    
    func saveContext(_ context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        
        context.performAndWait {
            do {
                try context.save()
            } catch {
                print("❌ Background context save error: \(error)")
            }
        }
    }
    
    // MARK: - Delete All
    
    func deleteAllData() {
        let entities = persistentContainer.managedObjectModel.entities
        
        for entity in entities {
            guard let entityName = entity.name else { continue }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try viewContext.execute(deleteRequest)
                try viewContext.save()
                print("🗑️ Deleted all data from \(entityName)")
            } catch {
                print("❌ Failed to delete \(entityName): \(error)")
            }
        }
    }
}
