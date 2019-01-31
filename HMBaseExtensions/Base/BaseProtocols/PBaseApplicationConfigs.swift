import Foundation

enum BaseAction: Hashable {
    case openErrorDialog
    case showNoInternet
}

protocol PBaseApplicationConfigs {
    /**
     * General error message , which show when can not find another error message for current error case , then show general message
     */
    var errorMessage: String? { get }
    
    /**
     * No internet error message
     */
    var noInternetMessage: String? { get }
}
