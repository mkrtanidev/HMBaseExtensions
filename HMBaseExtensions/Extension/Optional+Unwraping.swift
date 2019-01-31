import Foundation

public extension Optional {
    func isNil() -> Bool {
        return self == nil
    }
    
    func notNil() -> Bool {
        return !isNil()
    }
    
    func valueOr(_ default: Wrapped) -> Wrapped {
        return self ?? `default`
    }
}
