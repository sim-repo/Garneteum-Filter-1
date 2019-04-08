import Foundation
import RxSwift
import RxCocoa


class FilterVM : BaseVM {
    
    // MARK: - during user activies. Input from ViewController
    public var inSelectFilter = PublishSubject<FilterId>()
    public var inApply = PublishSubject<Void>()
    public var inCleanUp = PublishSubject<Void>()
    public var priceInApply = PublishSubject<Void>()
    public var inRemoveFilter = PublishSubject<FilterId>()
    private var tmpMinPrice: MinPrice = 0
    private var tmpMaxPrice: MaxPrice = 0
    
    // MARK: - Outputs to ViewController or Coord
    public var outShowSubFilters = PublishSubject<Int>()
    public var outCloseFilterVC = PublishSubject<Void>()
    
    
    var categoryId : Int
    
    public weak var filterActionDelegate: FilterActionDelegate?
    
    init(categoryId: Int = 0, filterActionDelegate: FilterActionDelegate?){
        self.categoryId = categoryId
        self.filterActionDelegate = filterActionDelegate
        super.init()

        bindSelection()
        bindUserActivities()
    }
    
    deinit {
        print("Filter VM deinit")
        realloc()
    }
    
    func realloc(){
        inSelectFilter.onCompleted()
        inApply.onCompleted()
        inCleanUp.onCompleted()
        priceInApply.onCompleted()
        inRemoveFilter.onCompleted()
        outShowSubFilters.onCompleted()
        outCloseFilterVC.onCompleted()
    }

    
    public func appliedTitles(filterId: Int)->String {
        return self.filterActionDelegate?.appliedTitle(filterId: filterId) ?? ""
    }
    
    public func rangePriceChangedNow(minPrice: CGFloat, maxPrice: CGFloat) {
        tmpMinPrice = minPrice
        tmpMaxPrice = maxPrice
    }
    
    public func rangePriceTouchEnd(){
        self.filterActionDelegate?.calcMidTotal(tmpMinPrice: tmpMinPrice, tmpMaxPrice: tmpMaxPrice)
    }
    
    private func bindSelection(){
        inSelectFilter
            .subscribe(
                onNext: {[weak self] filterId in
                    self?.filterActionDelegate?.requestSubFilters(filterId: filterId)
                    self?.filterActionDelegate?.showPriceApplyViewEvent().onNext(false)
                }
            )
            .disposed(by: bag)
        
        filterActionDelegate?.requestComplete()
            .bind { filterId in
                self.outShowSubFilters.onNext(filterId)
            }
            .disposed(by: bag)
    }
    
    private func bindUserActivities(){
        
        filterActionDelegate?.back()
            .filter({[.closeFilter].contains($0)})
            .take(1)
            .subscribe{[weak self] _ in
                self?.outCloseFilterVC.onCompleted()
            }
            .disposed(by: bag)
        
        
        inApply
            .subscribe(onNext: {[weak self] _ in   // onNext need for unit-tests
                self?.filterActionDelegate?.applyFromFilterEvent().onNext(Void())
            })
            .disposed(by: bag)
        
        
        inCleanUp
            .subscribe(onNext: {[weak self] _ in
                self?.filterActionDelegate?.cleanupFromFilterEvent().onNext(Void())
            })
            .disposed(by: bag)
        
        inRemoveFilter
            .subscribe(onNext: {[weak self] filterId in
                if let `self` = self {
                    self.filterActionDelegate?
                        .removeFilterEvent()
                        .onNext(filterId)
                }
            })
            .disposed(by: bag)
        
        priceInApply
            .subscribe(onNext: {[weak self] _ in   // onNext need for unit-tests
                guard let `self` = self else {return}
                self.filterActionDelegate?.setUserRangePrice(minPrice: self.tmpMinPrice, maxPrice: self.tmpMaxPrice)
                self.filterActionDelegate?.showPriceApplyViewEvent().onNext(false)
                self.filterActionDelegate?.applyByPrices().onNext(Void())
            })
            .disposed(by: bag)
    }
}
