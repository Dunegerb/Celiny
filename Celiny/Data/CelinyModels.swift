import Foundation
import CoreData

// Typealiases para compatibilidade com o resto do código
// O Xcode irá gerar as classes CDUserProfile, CDSession, etc. automaticamente.

public typealias UserProfile = CDUserProfile
public typealias Session = CDSession
public typealias Memory = CDMemory
public typealias BehaviorSignal = CDBehaviorSignal

// Extensões para facilitar o uso se necessário
extension CDUserProfile {
    public static var entityName: String { "UserProfile" }
}

extension CDSession {
    public static var entityName: String { "Session" }
}

extension CDMemory {
    public static var entityName: String { "Memory" }
}

extension CDBehaviorSignal {
    public static var entityName: String { "BehaviorSignal" }
}
