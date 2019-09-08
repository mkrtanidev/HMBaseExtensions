import Foundation
import RxSwift
import RxCocoa

open class BaseViewModel {
    private var observablesDict = [AnyHashable: ControlProperty<Any>]()
    private var reachibility = Reachability()
    /// indicate that viewModel is loading data and need to show loading view
    public var showLoading: BehaviorRelay = BehaviorRelay(value: false)
    
    /// Get action and subscribe in viewController
    /// - Parameter action: action to get observable
    public func getAction<T>(_ action: AnyHashable, argumentClass: T.Type) -> Observable<T?> {
        guard let data = observablesDict[action] else {
            objc_sync_enter(self)
            let empty = emptyControlProperty()
            observablesDict[action] = empty
            objc_sync_exit(self)
            return empty.map({ $0 as? T })
        }
        return data.map { $0 as? T }
    }
    
    private func emptyControlProperty() -> ControlProperty<Any> {
        let observable = PublishRelay<Any>()
        let observer = Binder<Any>(self) { _, value in
            observable.accept(value)
        }
        return ControlProperty(values: observable, valueSink: observer)
    }
    
    /// say viewController to do some action
    /// - Parameter action: action whish must emited
    /// - Parameter param: param which passed to observable
    public func doAction(_ action: AnyHashable, param: Any) {
        guard let data =  observablesDict[action] else {
            objc_sync_enter(self)
            let empty = emptyControlProperty()
            observablesDict[action] = empty
            empty.onNext(param)
            objc_sync_exit(self)
            return
        }
        data.onNext(param)
    }
    
    /// General error handling
    /// - Parameter error: error for handling
    open func handleError(_ error: Error) {
        
    }
    
    /// override and write retry logic here
    open func retry() {
        
    }
    
    required public init() {
//        reachibility?.whenUnreachable = {[weak self] _ in
//            self?.doAction(BaseAction.showNoInternet, param: Optional<Void>(nilLiteral: ()))
//        }
        reachibility?.whenReachable = {[weak self] _ in
            self?.retry()
        }
        do {
           try reachibility?.startNotifier()
        } catch {
            print(error)
        }
    }
    
    private func isOptional<T>(_ type: T) -> Bool {
        let typeName = String(describing: type)
        return typeName.hasPrefix("Optional") || typeName.hasPrefix("nil")
    }
}
