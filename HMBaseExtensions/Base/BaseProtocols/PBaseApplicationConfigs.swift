import Foundation

public enum BaseAction: Hashable {
    case openErrorDialog
    case showNoInternet
}

@objc public protocol PBaseApplicationConfigs {
    /**
     * General error message , which show when can not find another error message for current error case , then show general message
     */
    var errorMessage: String? { get }
    
    /**
     * No internet error message
     */
    var noInternetMessage: String? { get }
    
    /**
     * General error title , which show on alert
     */
    var errorTitle: String? { get }
    
    /**
     * General error ok button title, which show on alert
     */
    var okTitle: String { get }
    
    /**
     * General error cancel title, which show on alert
     */
    var cancelTitle: String { get }
}
