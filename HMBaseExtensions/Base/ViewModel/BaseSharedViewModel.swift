import Foundation
import RxSwift
import RxCocoa

public class BaseSharedViewModel<T>: PBaseSharedViewModel {
    public typealias SharedData = T
    
    private var sharedDataSparseArray = [AnyHashable: BehaviorRelay<T?>]()
    private var bagOfSentSharedDataSparseArray = [AnyHashable: T?]()
    
    private func getBaseSharedDataFor(sendCode: AnyHashable) -> BehaviorRelay<T?> {
        guard let data = sharedDataSparseArray[sendCode] else {
            let item = BehaviorRelay<T?>(value: nil)
            sharedDataSparseArray[sendCode] = item
            return item
        }
        return data
    }
    
    private func sendBaseSharedDataFor(sendCode: AnyHashable, data: T?) {
        var mutableLiveData = sharedDataSparseArray[sendCode]
        if mutableLiveData == nil {
            sharedDataSparseArray[sendCode] = BehaviorRelay<T?>(value: nil)
        }
        
        mutableLiveData = sharedDataSparseArray[sendCode]
        if mutableLiveData != nil {
            mutableLiveData!.accept(data)
        }
    }
    
    
    public func sendSharedDataWith(sendCode: AnyHashable, data: T?) {
        bagOfSentSharedDataSparseArray.removeValue(forKey: sendCode)
        sendBaseSharedDataFor(sendCode: sendCode, data: data);
    }
    
    public func getSharedDataFor(sendCode: AnyHashable, listener: SharedDataListener) -> Disposable {
        return getBaseSharedDataFor(sendCode: sendCode).bind {[weak self] data in
            guard let weakSelf = self else { return }
            
            let sharedData = weakSelf.bagOfSentSharedDataSparseArray[sendCode]
            
            if sharedData == nil || data == nil {
                weakSelf.bagOfSentSharedDataSparseArray[sendCode] = data
                listener?(data)
            }
            
        }
    }
    
    public func getSharedDataAlwaysFor(sendCode: AnyHashable, listener: SharedDataListener) -> Disposable {
        return getBaseSharedDataFor(sendCode: sendCode).bind {[weak self] data in
            guard let weakSelf = self else { return }
            weakSelf.bagOfSentSharedDataSparseArray[sendCode] = data
            listener?(data)
        }
    }
}
