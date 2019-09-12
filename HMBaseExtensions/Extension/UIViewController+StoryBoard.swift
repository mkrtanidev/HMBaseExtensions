import UIKit

public extension UIViewController {
    /**
     * @deprecated This method is deprecated starting in version x.x
     * @note Please use @code instantiateViewControllerForStoryBoardId:type: @endcode instead.
     */
    static func instantiateViewControllerForStoryBoardId<T>(_ name: String) -> T {
        let type = T.self
        let className = String(describing: type)
        let bundle = Bundle(for: type as! AnyClass)
        let storyBoard = UIStoryboard(name: name, bundle: bundle)
        return storyBoard.instantiateViewController(withIdentifier: className) as! T
    }
    
    static func instantiateViewControllerForStoryBoardId<T>(_ name: String, type: T.Type) -> T {
        let className = String(describing: type)
        let bundle = Bundle(for: type as! AnyClass)
        let storyBoard = UIStoryboard(name: name, bundle: bundle)
        return storyBoard.instantiateViewController(withIdentifier: className) as! T
    }
}
