import Foundation
import RxSwift

public protocol PBaseSharedViewModel {
    associatedtype SharedData
    typealias SharedDataListener = Optional<((SharedData?) -> Void)>
    
    func sendSharedDataWith(sendCode: AnyHashable, data: SharedData?)
    func getSharedDataFor(sendCode: AnyHashable, listener: SharedDataListener) -> Disposable
    func getSharedDataAlwaysFor(sendCode: AnyHashable, listener: SharedDataListener) -> Disposable
}
