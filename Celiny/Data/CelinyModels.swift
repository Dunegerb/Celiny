import Foundation
import CoreData

// MARK: - UserProfile

@objc(UserProfile)
public class UserProfile: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var preferences: NSObject? // Transformable
    @NSManaged public var sessions: NSSet?
    @NSManaged public var memories: NSSet?
}

extension UserProfile {
    @objc(addSessionsObject:)
    @NSManaged public func addToSessions(_ value: Session)

    @objc(removeSessionsObject:)
    @NSManaged public func removeFromSessions(_ value: Session)

    @objc(addSessions:)
    @NSManaged public func addToSessions(_ values: NSSet)

    @objc(removeSessions:)
    @NSManaged public func removeFromSessions(_ values: NSSet)

    @objc(addMemoriesObject:)
    @NSManaged public func addToMemories(_ value: Memory)

    @objc(removeMemoriesObject:)
    @NSManaged public func removeFromMemories(_ value: Memory)

    @objc(addMemories:)
    @NSManaged public func addToMemories(_ values: NSSet)

    @objc(removeMemories:)
    @NSManaged public func removeFromMemories(_ values: NSSet)
}

extension UserProfile: Identifiable {}

// MARK: - Session

@objc(Session)
public class Session: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }

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
    @objc(addMemoriesObject:)
    @NSManaged public func addToMemories(_ value: Memory)

    @objc(removeMemoriesObject:)
    @NSManaged public func removeFromMemories(_ value: Memory)

    @objc(addMemories:)
    @NSManaged public func addToMemories(_ values: NSSet)

    @objc(removeMemories:)
    @NSManaged public func removeFromMemories(_ values: NSSet)

    @objc(addSignalsObject:)
    @NSManaged public func addToSignals(_ value: BehaviorSignal)

    @objc(removeSignalsObject:)
    @NSManaged public func removeFromSignals(_ value: BehaviorSignal)

    @objc(addSignals:)
    @NSManaged public func addToSignals(_ values: NSSet)

    @objc(removeSignals:)
    @NSManaged public func removeFromSignals(_ values: NSSet)
}

extension Session: Identifiable {}

// MARK: - Memory

@objc(Memory)
public class Memory: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Memory> {
        return NSFetchRequest<Memory>(entityName: "Memory")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var content: String?
    @NSManaged public var embedding: NSObject? // Transformable
    @NSManaged public var importance: Float
    @NSManaged public var accessCount: Int32
    @NSManaged public var lastAccessed: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var memoryLayer: String?
    @NSManaged public var tags: [String]? // Transformable to [String]
    @NSManaged public var user: UserProfile?
    @NSManaged public var session: Session?
}

extension Memory: Identifiable {}

// MARK: - BehaviorSignal

@objc(BehaviorSignal)
public class BehaviorSignal: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BehaviorSignal> {
        return NSFetchRequest<BehaviorSignal>(entityName: "BehaviorSignal")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var timestamp: Date?
    @NSManaged public var signalType: String?
    @NSManaged public var value: Float
    @NSManaged public var metadata: NSObject? // Transformable Dictionary
    @NSManaged public var session: Session?
}

extension BehaviorSignal: Identifiable {}
