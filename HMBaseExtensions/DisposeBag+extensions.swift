import RxSwift

public extension DisposeBag {
    func disposeAll() {
        let mirror = Mirror(reflecting: self)
        for (_, value) in mirror.children {
            if let disposables = value as? [Disposable] {
                for disposable in disposables {
                    disposable.dispose()
                }
            }
        }
    }
}
