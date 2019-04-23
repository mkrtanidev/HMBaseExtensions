import UIKit
import RxSwift
import NVActivityIndicatorView

private let swizzling: (UIViewController.Type, Selector, Selector) -> () = { viewController, oldSelector, newSelector in
    
    guard let old = class_getInstanceMethod(viewController, oldSelector),
        let new = class_getInstanceMethod(viewController, newSelector) else { return }
    
    let didAddMethod = class_addMethod(viewController, oldSelector, method_getImplementation(new), method_getTypeEncoding(new))
    if didAddMethod {
        class_replaceMethod(viewController, newSelector, method_getImplementation(old), method_getTypeEncoding(old))
    } else {
        method_exchangeImplementations(old, new)
    }
}

extension UIViewController {
    private struct AssociatedObjectKeys {
        static var viewModel = 0
        static var disposeBag = 1
        static var state = 2
        static var disposeBagForSharedData = 3
    }
    
    /// disposeBag for use in binding .dispose(by: disposeBag)
    public var disposeBag: DisposeBag {
        get {
            guard let disposeBag =  objc_getAssociatedObject(self, &AssociatedObjectKeys.disposeBag) as? DisposeBag else {
                let db = DisposeBag()
                objc_setAssociatedObject(self, &AssociatedObjectKeys.disposeBag, db, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return db
            }
            return disposeBag
        }
    }
    
    private var disposeBagForSharedData: DisposeBag {
        get {
            guard let disposeBag =  objc_getAssociatedObject(self, &AssociatedObjectKeys.disposeBagForSharedData) as? DisposeBag else {
                let db = DisposeBag()
                objc_setAssociatedObject(self, &AssociatedObjectKeys.disposeBagForSharedData, db, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return db
            }
            return disposeBag
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.disposeBagForSharedData, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public static var sharedViewModel = BaseSharedViewModel<Any>()
    
    /** override var and return false in all custom viewControllers which you want to not update view
     after language chang
     - Note: default value is true
     */
    @objc open var updateViewOnLanguageChange: Bool {
        return true
    }
    
    /** set loadingView to make individual loader for view controllers */
    public static var loadingVC: BaseLoadingVC = {
        let loadingVC = BaseLoadingVC()
        loadingVC.loadingView = NVActivityIndicatorView(
            frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0),
            type: NVActivityIndicatorType.lineScale,
            color: UIColor.blue,
            padding: 0.0)
        return loadingVC
    }()
    
    /**
     swizzle viewDidLoad() method for make some required steps, automaticly call bindings and subscribe on notification
     - Note: call in appDelegate
     */
    public class func initializeing() {
        // make sure this isn't a subclass
        guard self === UIViewController.self else { return }
        swizzling(self, #selector(self.viewDidLoad), #selector(self.proj_viewDidLoad))
        swizzling(self, #selector(self.viewWillAppear(_:)), #selector(self.proj_viewWillAppear(_:)))
        swizzling(self, #selector(self.viewWillDisappear(_:)), #selector(self.proj_viewWillDisappear(_:)))
    }
    
    // MARK: - Method Swizzling
    @objc func proj_viewDidLoad() {
        self.proj_viewDidLoad()
        
        let viewControllerName = NSStringFromClass(type(of: self))
        print("ViewDidLoad called on \(viewControllerName)")
        self.state = .viewLoaded
        #warning("init viewModel, do other staff relative to binding before call super.viewDidLoad()")
        bindViews()
        baseBinding()
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(onLanguageChange(_:)),
                         name: languageChangeNotification, object: nil)
    }
    
    @objc func proj_viewWillAppear(_ animated: Bool) {
        self.proj_viewWillAppear(animated)
        self.state = .viewAppeared
    }
    
    @objc func proj_viewWillDisappear(_ animated: Bool) {
        self.proj_viewWillDisappear(animated)
        self.state = .viewDisapeared
        self.disposeBagForSharedData.disposeAll()
    }
    
    
    /// override to do view bindings
    @objc open func bindViews() { }
    
    public func setNavigationPopGestureDelegateToNil() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    /// any additional steps after language change
    @objc open func onLanguageChange(_ note: Notification) {
        // any additioal steps every time when language changes
        let moduleName = NSStringFromClass(self.classForCoder)
        if updateViewOnLanguageChange,
            let bundleName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String,
            moduleName.contains(bundleName) {
            self.loadView()
            disposeBag.disposeAll()
            disposeBagForSharedData.disposeAll()
            baseBinding()
        }
    }
    
    private func baseBinding() {
        getViewModel(as: BaseViewModel.self).getAction(BaseAction.openErrorDialog, argumentClass: Error.self)
            .subscribe(onNext: { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.showError($0)
            })
            .disposed(by: disposeBag)
        getViewModel(as: BaseViewModel.self).getAction(BaseAction.showNoInternet, argumentClass: String.self)
            .subscribe(onNext: {
                UIAlertController.showWith(message: $0)
            })
            .disposed(by: disposeBag)
        getViewModel(as: BaseViewModel.self).showLoading
            .subscribe(onNext: {[weak self] in
                guard let `self` = self else { return }
                if $0 {
                    self.addChildViewController(UIViewController.loadingVC, to: self.view)
                } else {
                    for child in self.children {
                        if child is BaseLoadingVC {
                            child.willMove(toParent: nil)
                            child.view.removeFromSuperview()
                            child.removeFromParent()
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    /** error handling mehtod
     - Parameter error: error to be handled
     - Note: override in any viewController, to do error handling manualy, by default show dialog with error message
     */
    open func showError(_ error: Error) {
        print(#file, #line)
        UIAlertController.showError(error)
    }
    
    
    /**
     - Note:
     you must write an appropriate argument as the corresponding class
     as otherwise it will turn out class cast exception later
     
     - Parameter clazz: Class of ViewModel which you want to get
     
     - Returns: viewModel of your ViwController
     */
    open func getViewModel<T: BaseViewModel>(as clazz: T.Type) -> T {
        guard let vm = objc_getAssociatedObject(self, &AssociatedObjectKeys.viewModel) as? T
            else {
                let vm = T()
                objc_setAssociatedObject(self, &AssociatedObjectKeys.viewModel, vm, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return vm
        }
        return vm
    }
    
    /**
     for cases if we need to set viewModel out of our viewController
     - Parameter vm: viewMOdel of viewController
     */
    open func setViewModel(_ vm: BaseViewModel) {
        objc_setAssociatedObject(self, &AssociatedObjectKeys.viewModel, vm, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// for easy set navigation title
    /// - Parameter title: the title of navigation item
    open func setNavigationTitle(_ navigationTitle: String?) {
        navigationItem.title = navigationTitle
    }
    
    /// send data from viewController to another
    /// - Parameter sendCode: SendCode for identificate data
    /// - Parameter data: data that must be send
    open func sendSharedDataWith(sendCode: AnyHashable, data: Any?) {
        UIViewController.sharedViewModel.sendSharedDataWith(sendCode: sendCode, data: data)
    }
    
    /** get data for sendcode immidiatly after send (called sendSharedDataWith(sendcode:, data:) ) can call anywhere
     - Parameter sendCode: SendCode for identificate data
     - Parameter class: class for cast sended data
     - Parameter listener: optional block to handle data
     */
    open func getSharedDataImmidiatlyFor<T>(sendCode: AnyHashable, class: T.Type, listener: Optional<((T?) -> Void)>) {
        UIViewController.sharedViewModel.getSharedDataFor(sendCode: sendCode) { data in
            listener?(data as? T)
            }.disposed(by: disposeBag)
    }
    
    /** get data for sendcode immidiatly every time, after viewWillAppear, call in viewWillAppear
     - Parameter sendCode: SendCode for identificate data
     - Parameter class: class for cast sended data
     - Parameter listener: optional block to handle data
     */
    open func getSharedDataAlwaysFor<T>(sendCode: AnyHashable, class: T.Type, listener: Optional<((T?) -> Void)>) {
        UIViewController.sharedViewModel.getSharedDataAlwaysFor(sendCode: sendCode) { data in
            listener?(data as? T)
            }.disposed(by: disposeBagForSharedData)
    }
    
    /** get data for sendcode immidiatly after viewWillAppear, call in viewWillAppear
     - Parameter sendCode: SendCode for identificate data
     - Parameter class: class for cast sended data
     - Parameter listener: optional block to handle data
     */
    open func getSharedDataOnActiveFor<T>(sendCode: AnyHashable, class: T.Type, listener: Optional<((T?) -> Void)>) {
        UIViewController.sharedViewModel.getSharedDataFor(sendCode: sendCode) { data in
            listener?(data as? T)
            }.disposed(by: disposeBagForSharedData)
    }
    
    
    /// UIVIewController Lyfecycle States
    public enum State {
        case initialized
        case viewLoaded
        case viewAppeared
        case viewDisapeared
        case destroyed
    }
    
    /// current state of self
    var state: State {
        get {
            guard let state =  objc_getAssociatedObject(self, &AssociatedObjectKeys.disposeBag) as? State else {
                let st = State.initialized
                objc_setAssociatedObject(self, &AssociatedObjectKeys.disposeBag, st, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return st
            }
            return state
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.state, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
