import UIKit

@objc public protocol PBaseAppDelegate: UIApplicationDelegate {
    var configs: PBaseApplicationConfigs { get }
}
