import UIKit
import RxSwift



// MARK: - CATEGORY APPLY DATA
extension DataService {
    
    
    func getApplyForItemsEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)> {
        return outApplyItemsResponse
    }
    
    func getApplyForFiltersEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, MinPrice, MaxPrice, ItemsTotal)> {
        return outApplyFiltersResponse
    }
    
    func getApplyByPriceEvent() -> PublishSubject<FilterIds> {
        return outApplyByPrices
    }
    
    
    internal func fireApplyForItems(_ filterIds: FilterIds, _ subFiltersIds: SubFilterIds, _ appliedSubFilters: Applied, _ selectedSubFilters: Selected, _ itemIds: ItemIds) {
        outApplyItemsResponse.onNext((filterIds, subFiltersIds, appliedSubFilters, selectedSubFilters, itemIds))
    }
    
    internal func fireApplyForFilters(_ filterIds: FilterIds, _ subFiltersIds: SubFilterIds, _ appliedSubFilters: Applied, _ selectedSubFilters: Selected, _ tipMinPrice: MinPrice, _ tipMaxPrice: MaxPrice, _ itemsTotal: ItemsTotal) {
        outApplyFiltersResponse.onNext((filterIds, subFiltersIds, appliedSubFilters, selectedSubFilters, tipMinPrice, tipMaxPrice, itemsTotal))
    }
    
    internal func fireApplyByPrices(_ filterIds: FilterIds) {
        outApplyByPrices.onNext(filterIds)
    }
    
    
    func reqApplyFromFilter(categoryId: CategoryId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
        
        self.applyLogic.doApplyFromFilter(appliedSubFilters, selectedSubFilters, rangePrice)
            .asObservable()
            .subscribe(onNext: {[weak self] res in
                let filterIds = res.0
                let subfilterIds = res.1
                let applied = res.2
                let selected = res.3
                let itemIds = res.4
                self?.fireApplyForItems(filterIds, subfilterIds, applied, selected, itemIds)
            })
            .disposed(by: bag)
    }



    func reqApplyFromSubFilter(categoryId: CategoryId, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
        
        applyLogic.doApplyFromSubFilters(filterId, appliedSubFilters, selectedSubFilters, rangePrice)
            .asObservable()
            .subscribe(onNext: {[weak self] res in
                let filterIds = res.0
                let subfilterIds = res.1
                let applied = res.2
                let selected = res.3
                let rangePrice = res.4
                let itemsTotal = res.5
                self?.fireApplyForFilters(filterIds,
                                          subfilterIds,
                                          applied,
                                          selected,
                                          rangePrice.tipMinPrice,
                                          rangePrice.tipMaxPrice,
                                          itemsTotal)
            })
            .disposed(by: bag)
    }


    func reqApplyByPrices(categoryId: CategoryId, rangePrice: RangePrice) {
        
        applyLogic.doApplyByPrices(categoryId, rangePrice)
            .asObservable()
            .subscribe(onNext: {[weak self] res in
                let filterIds: FilterIds = res
                self?.fireApplyByPrices(filterIds)
            })
            .disposed(by: bag)
    }


    func reqRemoveFilter(categoryId: CategoryId, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
        
        applyLogic.doRemoveFilter(filterId, appliedSubFilters, selectedSubFilters, rangePrice)
            .asObservable()
            .subscribe(onNext: {[weak self] res in
                let filterIds = res.0
                let subfilterIds = res.1
                let applied = res.2
                let selected = res.3
                let rangePrice = res.4
                let itemsTotal = res.5
                self?.fireApplyForFilters(filterIds,
                                          subfilterIds,
                                          applied,
                                          selected,
                                          rangePrice.tipMinPrice,
                                          rangePrice.tipMaxPrice,
                                          itemsTotal)
            })
            .disposed(by: bag)
    }
    

    func reqMidTotal(categoryId: CategoryId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
        
        applyLogic.doCalcMidTotal(appliedSubFilters, selectedSubFilters, rangePrice)
            .asObservable()
            .subscribe(onNext: {[weak self] count in
                self?.outTotals.onNext(count)
            })
            .disposed(by: bag)
    }
    
    func getMidTotal() -> PublishSubject<Int> {
        return outTotals
    }

}
