import UIKit

protocol LoadingView {
    func startAnimate()
    func endAnimate()
}

extension UIActivityIndicatorView: LoadingView {
    func startAnimate() {
        self.startAnimating()
    }
    
    func endAnimate() {
        self.stopAnimating()
    }
}

open class BaseLoadingVC: UIViewController {
    override public var updateViewOnLanguageChange: Bool {
        return false
    }
    var loadingView: LoadingView!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.alpha = 0.7
        if loadingView == nil {
            loadingView = UIActivityIndicatorView(style: .gray)
        }
        (loadingView as! UIView).translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(loadingView as! UIView)
        NSLayoutConstraint.activate([NSLayoutConstraint(item: (loadingView as! UIView),
                                                        attribute: .centerX,
                                                        relatedBy: .equal,
                                                        toItem: self.view,
                                                        attribute: .centerX,
                                                        multiplier: 1.0,
                                                        constant: 0.0),
                                     NSLayoutConstraint(item: (loadingView as! UIView),
                                                        attribute: .centerY,
                                                        relatedBy: .equal,
                                                        toItem: self.view,
                                                        attribute: .centerY,
                                                        multiplier: 1.0,
                                                        constant: 0.0)])
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingView.startAnimate()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadingView.endAnimate()
    }

}
