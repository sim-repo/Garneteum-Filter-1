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
        
        let completion: ((FilterIds, SubFilterIds, Applied, Selected, ItemIds) -> Void)? = { [weak self] filterIds, subfilterIds, applied, selected, itemIds in
            self?.fireApplyForItems(filterIds, subfilterIds, applied, selected, itemIds)
        }
        self.applyLogic.doApplyFromFilter(appliedSubFilters, selectedSubFilters, rangePrice, completion: completion)
        
    }


    
    func reqApplyFromSubFilter(categoryId: CategoryId, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
        
        let completion: ((FilterIds, SubFilterIds, Applied, Selected, RangePrice, ItemsTotal) -> Void)? = { [weak self] filterIds, subfilterIds, applied, selected, rangePrice, itemsTotal in
            self?.fireApplyForFilters(filterIds,
                                      subfilterIds,
                                      applied,
                                      selected,
                                      rangePrice.tipMinPrice,
                                      rangePrice.tipMaxPrice,
                                      itemsTotal)
        }
        
        applyLogic.doApplyFromSubFilters(filterId, appliedSubFilters, selectedSubFilters, rangePrice, completion: completion)
    }


    func reqApplyByPrices(categoryId: CategoryId, rangePrice: RangePrice) {
        let completion: (([Int?]) -> Void)? = { [weak self] filterIds in
            let filterIds: FilterIds = filterIds
            self?.fireApplyByPrices(filterIds)
        }
        applyLogic.doApplyByPrices(categoryId, rangePrice, completion: completion)
    }


    func reqRemoveFilter(categoryId: CategoryId, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
        
        let completion: ((FilterIds, SubFilterIds, Applied, Selected, RangePrice, ItemsTotal) -> Void)? = { [weak self] filterIds, subfilterIds, applied, selected, rangePrice, itemsTotal in
            self?.fireApplyForFilters(filterIds,
                                      subfilterIds,
                                      applied,
                                      selected,
                                      rangePrice.tipMinPrice,
                                      rangePrice.tipMaxPrice,
                                      itemsTotal)
        }
        
        applyLogic.doRemoveFilter(filterId, appliedSubFilters, selectedSubFilters, rangePrice, completion: completion)
    }
    

    func reqMidTotal(categoryId: CategoryId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
        
        let completion: ((Int) -> Void)? = { [weak self] count in
            self?.outTotals.onNext(count)
        }
        applyLogic.doCalcMidTotal(appliedSubFilters, selectedSubFilters, rangePrice, completion: completion)
    }
    
    func getMidTotal() -> PublishSubject<Int> {
        return outTotals
    }

}
