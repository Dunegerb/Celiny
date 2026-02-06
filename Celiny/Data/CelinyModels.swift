import Foundation
import CoreData

@objc(UserProfile)
public class UserProfile: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var preferences: NSObject? // Transformable
    
    @NSManaged public var sessions: NSSet?
    @NSManaged public var memories: NSSet?
}

extension UserProfile {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }
}

@objc(Session)
public class Session: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var startedAt: Date?
    @NSManaged public var endedAt: Date?
    @NSManaged public var duration: Double
    @NSManaged public var type: String?
    
    @NSManaged public var user: UserProfile?
    @NSManaged public var memories: NSSet?
    @NSManaged public var signals: NSSet?
}

extension Session {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }
}

@objc(Memory)
public class Memory: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var content: String?
    @NSManaged public var embedding: NSObject? // Transformable
    @NSManaged public var importance: Float
    @NSManaged public var accessCount: Int32
    @NSManaged public var lastAccessed: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var memoryLayer: String?
    @NSManaged public var tags: NSObject? // Transformable
    
    @NSManaged public var user: UserProfile?
    @NSManaged public var session: Session?
}

extension Memory {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Memory> {
        return NSFetchRequest<Memory>(entityName: "Memory")
    }
}

@objc(BehaviorSignal)
public class BehaviorSignal: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var timestamp: Date?
    @NSManaged public var signalType: String?
    @NSManaged public var value: Float
    @NSManaged public var metadata: NSObject? // Transformable
    
    @NSManaged public var session: Session?
}

extension BehaviorSignal {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BehaviorSignal> {
        return NSFetchRequest<BehaviorSignal>(entityName: "BehaviorSignal")
    }
}
