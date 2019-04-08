import Foundation
import RxSwift
import RxCocoa
import RxDataSources



class SubFilterVM : BaseVM {
    
    // MARK: - when init. Output to ViewController
    var filterEnum: FilterEnum = .select
    var outCloseSubFilterVC = PublishSubject<Void>()
    var outStartWait = PublishSubject<Void>()
    
    
    // MARK: - during user activies. Input from ViewController
    var inApply = PublishSubject<Void>()
    var inCleanUp = PublishSubject<Void>()
    
    var filterId = 0
    public weak var filterActionDelegate: FilterActionDelegate?
    
    init(filterId: Int = 0, filterActionDelegate: FilterActionDelegate?){
        super.init()
        self.filterId = filterId
        self.filterActionDelegate = filterActionDelegate
        self.filterEnum = filterActionDelegate?.getFilterEnum(filterId: filterId) ?? .select
        bindUserActivities()
    }
    
    deinit {
        print("SubFilter VM deinit")
        realloc()
    }
    
    func realloc(){
        outCloseSubFilterVC.onCompleted()
        inApply.onCompleted()
        inCleanUp.onCompleted()
        outStartWait.onCompleted()
    }
    
   
    private func bindUserActivities(){
        
        filterActionDelegate?.back()
            .filter({[.closeSubFilter].contains($0)})
            .take(1)
            .subscribe{[weak self] _ in
                self?.outCloseSubFilterVC.onCompleted()
            }
            .disposed(by: bag)
        
        inApply
            .subscribe(onNext: {[weak self] _ in // onNext need for unit-tests
                guard let `self` = self else {return}
                self.filterActionDelegate?.applyFromSubFilterEvent().onNext(self.filterId)
            })
            .disposed(by: bag)
        
        inCleanUp
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else {return}
                self.filterActionDelegate?.cleanupFromSubFilterEvent().onNext(self.filterId)
            })
            .disposed(by: bag)
    }
    
    public func isCheckmark(subFilterId: Int) -> Bool {
        return self.filterActionDelegate?.isSelectedSubFilter(subFilterId: subFilterId) ?? false
    }
    
}
