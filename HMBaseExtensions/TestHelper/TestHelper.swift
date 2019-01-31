import Foundation

public struct TestHelper {
    private static var is_Testing = 2
    static func isTesting() -> Bool {
        if is_Testing == 1 {
            return true
        } else if is_Testing == 0 {
            return false
        }
        if NSClassFromString("XCTest") != nil {
            is_Testing = 1
            return true
        } else {
            is_Testing = 0
            return false
        }
    }
}
