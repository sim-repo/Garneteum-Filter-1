import Foundation
import RxSwift
import RxDataSources
import SwiftyJSON

class FilterApplyLogic {
    
    private init(){}
    
    public static let shared = FilterApplyLogic()
    
    
    let controlActiveTasks = DispatchQueue(label: "", attributes: .concurrent)
    
    
    
    private var filters: Filters = Filters()
    private var subfiltersByFilter: SubfiltersByFilter = SubfiltersByFilter()
    private var sectionSubFiltersByFilter: SectionSubFiltersByFilter = SectionSubFiltersByFilter()
    private var subFilters: SubFilters = SubFilters()
    
    private var subfiltersByItem: SubfiltersByItem = SubfiltersByItem()
    private var itemsBySubfilter: ItemsBySubfilter = ItemsBySubfilter()
    private var itemsById: ItemsById = ItemsById()
    private var itemsByCatalog: ItemsByCatalog = ItemsByCatalog()
    
    private var priceByItemId: PriceByItemId = PriceByItemId()
    private var itemIds: ItemIds = []
    
    
    private var filters_HasSet = false
    private var subfilters_HasSet = false
    private var subfiltersByFilter_HasSet = false
    private var subfiltersByItem_HasSet = false
    private var itemsBySubfilter_HasSet = false
    private var priceByItemId_HasSet = false
    
    private var limitTry = Int(waitForSubfiltersApplySetInSec)
    
    
    public func getFilters() -> [FilterModel] {
        return filters.compactMap({$0.value})
    }
    
    public func getSubFilters() -> [SubfilterModel] {
        return subFilters.compactMap({$0.value})
    }
    
    public func getSubfByItem()-> SubfiltersByItem {
        return subfiltersByItem
    }
    
    public func addSubfByFilter(id: Int, arr: [Int]) {
        subfiltersByFilter[id] = arr
    }
    
    public func addSubF(id: Int, subFilter: SubfilterModel){
        subFilters[id] = subFilter
    }
    
    public func addFilter(id: Int, filter: FilterModel){
        filters[id] = filter
    }
    
    
    public func subfByItem(item: Int, subfilters: [Int]){
        subfiltersByItem[item] = subfilters
        subfilters.forEach{ id in
            if itemsBySubfilter[id] == nil {
                itemsBySubfilter[id] = []
                itemsBySubfilter[id]?.append(item)
            } else {
                itemsBySubfilter[id]?.append(item)
            }
        }
    }
    
    private func limitRangePrice(_ itemId: Int, _ rangePrice: RangePrice) {
        guard let price = priceByItemId[itemId] else { return }
        if rangePrice.tipMinPrice > price {
            rangePrice.tipMinPrice = price
        }
        if rangePrice.tipMaxPrice < price {
            rangePrice.tipMaxPrice = price
        }
    }
    
    
    private func checkPrice(_ itemId: Int, _ minPrice: MinPrice, _ maxPrice: MaxPrice) -> Bool{
        guard let price = priceByItemId[itemId] else { return false }
        if price >= minPrice && price <= maxPrice {
            return true
        }
        return false
    }
    
    
    private func getItemIds(by subFilterIds: [Int], _ rangePrice: RangePrice) -> Set<Int> {
        
        var res = Set<Int>()
        
        let itemIds = subFilterIds
            .compactMap({itemsBySubfilter[$0]})
            .flatMap{$0}
        
        itemIds.forEach({itemId in
            if rangePrice.userMinPrice > 0 || rangePrice.userMaxPrice > 0 {
                if checkPrice(itemId, rangePrice.userMinPrice, rangePrice.userMaxPrice) {
                    res.insert(itemId)
                }
            } else {
                res.insert(itemId)
            }
            limitRangePrice(itemId, rangePrice)
        })
        return res
    }
    
    
    
    private func getItemsIntersect(_ applyingByFilter: ApplyingByFilter, _ rangePrice: RangePrice, exceptFilterId: FilterId = 0) -> Set<Int> {
        var res = Set<Int>()
        var tmp = Set<Int>()
        
        for (filterId, subFilterIds) in applyingByFilter {
            if filterId != exceptFilterId || exceptFilterId == 0  {
                tmp = getItemIds(by: subFilterIds, rangePrice)
            }
            res = (res.count == 0) ? tmp : res.intersection(tmp)
        }
        return res
    }
    
    
    private func getItemsByPrice(_ rangePrice: RangePrice) -> Set<Int> {
        var res = Set<Int>()
        
        priceByItemId.forEach({element in
            let price = element.value
            if (price >= rangePrice.userMinPrice && price <= rangePrice.userMaxPrice) {
                res.insert(element.key)
            }
        })
        return res
    }
    
    private func groupApplying(_ applyingByFilter: inout ApplyingByFilter, _ applying: Set<Int>){
        applyingByFilter.removeAll()
        for id in applying {
            if let subFilter = subFilters[id] {
                let filterId = subFilter.filterId
                if applyingByFilter[filterId] == nil {
                    applyingByFilter[filterId] = []
                }
                applyingByFilter[filterId]?.append(id)
            }
        }
    }
    
    private func applyForTotal(appliedSubFilters: Applied,
                                selectedSubFilters: Selected,
                                rangePrice: RangePrice) -> Int{
        
        let selected = selectedSubFilters
        let applied = getApplied(applied: appliedSubFilters)
        let applying = selected.union(applied)
        
        var items: Set<Int>
        if (applying.count == 0) {
            items = getItemsByPrice(rangePrice)
        } else {
            var applyingByFilter = ApplyingByFilter()
            groupApplying(&applyingByFilter, applying)
            items = getItemsIntersect(applyingByFilter, rangePrice)
        }
        return items.count
        
    }
    
    private func applyFromFilter(_ appliedSubFilters: inout Applied,
                                 _ selectedSubFilters: inout Selected,
                                 _ enabledFilters: inout EnabledFilters,
                                 _ enabledSubfilters: inout EnabledSubfilters,
                                 _ itemsIds: inout [Int],
                                 _ rangePrice: RangePrice) {
        
        
        // block #1 >>
        let selected = selectedSubFilters
        let applied = getApplied(applied: appliedSubFilters)
        let applying = selected.union(applied)
        
        if applying.count == 0 && rangePrice.userMinPrice == 0 && rangePrice.userMaxPrice == 0 {
            return
        }
        // block #1 <<
        
        
        // block #2 >>
        var items: Set<Int>
        if (applying.count == 0) {
            items = getItemsByPrice(rangePrice)
        } else {
            var applyingByFilter = ApplyingByFilter()
            groupApplying(&applyingByFilter, applying)
            items = getItemsIntersect(applyingByFilter, rangePrice)
        }
        // block #2 <<
        
        
        for id in items {
            itemsIds.append(id)
        }
        
        let rem = getSubFilters(by: items)
        enableAllFilters(&enabledFilters, enable: false)
        enableAllSubFilters(&enabledSubfilters, enable: false)
        
        rem.forEach{ id in
            if enabledSubfilters[id] != nil {
                let subFilter = subFilters[id]
                enabledSubfilters[id] = true
                enableFilters(subFilter!.filterId, &enabledFilters)
            }
        }
        selectedSubFilters = Set(applying)
        appliedSubFilters = Set(applying)
    }
    
    
    
    private func getApplied(applied: Applied, exceptFilterId: FilterId = 0) -> Applied{
        if exceptFilterId == 0 {
            return applied
        }
        let res = applied.filter({subFilters[$0]?.filterId != exceptFilterId})
        return res
    }
    
    
    
    private func applyFromSubFilter(_ filterId: FilterId,
                                    _ appliedSubFilters: inout Applied,
                                    _ selectedSubFilters: inout Selected,
                                    _ enabledFilters: inout EnabledFilters,
                                    _ enabledSubfilters: inout EnabledSubfilters,
                                    _ rangePrice: RangePrice,
                                    _ itemsTotal: inout ItemsTotal) {
        
        // block #1 >>
        var inFilter: Set<Int> = Set()
        if let ids = subfiltersByFilter[filterId] {
            inFilter = Set(ids)
        }
        let selected = selectedSubFilters.intersection(inFilter)
        let applied = getApplied(applied: appliedSubFilters)
        let applying = selected.union(applied)
        // block #1 <<
        
        
        // block #2 >>
        if applying.count == 0 && rangePrice.userMinPrice == 0 && rangePrice.userMaxPrice == 0 {
            resetFilters(&appliedSubFilters, &selectedSubFilters, &enabledFilters, &enabledSubfilters, 0, rangePrice)
            return
        }
        // block #2 <<
        
        // block #3 >>
        var items: Set<Int>
        if (applying.count == 0) {
            items = getItemsByPrice(rangePrice)
        } else {
            var applyingByFilter = ApplyingByFilter()
            groupApplying(&applyingByFilter, applying)
            items = getItemsIntersect(applyingByFilter, rangePrice)
        }
        // block #3 <<
        
        // block #4 >>
        itemsTotal = items.count
        if items.count == 0 {
            enableAllFilters(&enabledFilters, exceptFilterId: filterId, enable: false)
            enableAllSubFilters(except: filterId, &enabledSubfilters, enable: true)
            selectedSubFilters = Set(applying)
            appliedSubFilters = Set(applying)
            return
        }
        // block #4 <<
        
        // block #5 >>
        let rem = getSubFilters(by: items)
        
        enableAllFilters(&enabledFilters, exceptFilterId: filterId, enable: false)
        enableAllSubFilters(except: filterId, &enabledSubfilters, enable: false)
        
        rem.forEach{ id in
            if enabledSubfilters[id] != nil {
                let subFilter = subFilters[id]
                enabledSubfilters[id] = true
                enableFilters(subFilter!.filterId, &enabledFilters)
            }
        }
        selectedSubFilters = Set(applying)
        appliedSubFilters = Set(applying)
        // block #5 <<
    }
    
    
    private func removeFilter(_ appliedSubFilters: inout Applied,
                              _ selectedSubFilters: inout Selected,
                              _ filterId: FilterId,
                              _ enabledFilters: inout EnabledFilters,
                              _ enabledSubfilters: inout EnabledSubfilters,
                              _ rangePrice: RangePrice,
                              _ itemsTotal: inout ItemsTotal)  {
        
        
        removeApplied(appliedSubFilters: &appliedSubFilters, selectedSubFilters: &selectedSubFilters, filterId: filterId)
        
        applyAfterRemove(&appliedSubFilters,
                         &selectedSubFilters,
                         &enabledFilters,
                         &enabledSubfilters,
                         rangePrice,
                         &itemsTotal)
    }
    
    
    private func applyAfterRemove(_ appliedSubFilters: inout Applied,
                                  _ selectedSubFilters: inout Selected,
                                  _ enabledFilters: inout EnabledFilters,
                                  _ enabledSubfilters: inout EnabledSubfilters,
                                  _ rangePrice: RangePrice,
                                  _ itemsTotal: inout ItemsTotal ) {
        
        // block #1 >>
        let applying = getApplied(applied: appliedSubFilters)
        if applying.count == 0 && rangePrice.userMinPrice == 0 && rangePrice.userMaxPrice == 0 {
            resetFilters(&appliedSubFilters, &selectedSubFilters, &enabledFilters, &enabledSubfilters, 0, rangePrice)
            return
        }
        // block #1 <<
        
        
        // block #2 >>
        var items: Set<Int>
        var applyingByFilter = ApplyingByFilter()
        if (applying.count == 0) {
            items = getItemsByPrice(rangePrice)
            resetRangePrice(rangePrice)
        } else {
            groupApplying(&applyingByFilter, applying)
            items = getItemsIntersect(applyingByFilter, rangePrice)
        }
        // block #2 <<
        
        // block #3 >>
        if items.count == 0 {
            resetFilters(&appliedSubFilters, &selectedSubFilters, &enabledFilters, &enabledSubfilters, 0, rangePrice)
            return
        }
        
        var filterId = 0
        if applyingByFilter.count == 1 {
            filterId = applyingByFilter.first?.key ?? 0
        }
        // block #3 <<
        
        
        // block #4 >>
        itemsTotal = items.count
        let rem = getSubFilters(by: items)
        enableAllFilters(&enabledFilters, enable: false)
        enableAllSubFilters2(except: filterId, &enabledSubfilters, enable: false)
        
        rem.forEach{ id in
            if enabledSubfilters[id] != nil {
                let subFilter = subFilters[id]
                enabledSubfilters[id] = true
                enableFilters(subFilter!.filterId, &enabledFilters)
            }
        }
        selectedSubFilters = Set(applying)
        appliedSubFilters = Set(applying)
        // block #4 <<
    }
    
    
    
    
    private func applyBeforeEnter(_ appliedSubFilters: inout Applied,
                                  _ filterId: FilterId,
                                  _ enabledFilters: inout EnabledFilters,
                                  _ enabledSubfilters: inout EnabledSubfilters,
                                  _ countsItems: inout CountItems,
                                  _ rangePrice: RangePrice) {
        
        
        // block #1 >>
        let applying = getApplied(applied: appliedSubFilters, exceptFilterId: filterId)
        if applying.count == 0 && rangePrice.userMinPrice == 0 && rangePrice.userMaxPrice == 0 {
            fillItemsCount(by: filterId, &countsItems)
            enableAllSubFilters2(&enabledSubfilters, enable: true)
            return
        }
        // block #1 <<
        
        
        // block #2 >>
        var items: Set<Int>
        if (applying.count == 0) {
            items = getItemsByPrice(rangePrice)
        } else {
            var applyingByFilter = ApplyingByFilter()
            groupApplying(&applyingByFilter, applying)
            items = getItemsIntersect(applyingByFilter, rangePrice)
        }
        // block #2 <<
        
        // block #3 >>
        if items.count == 0 {
            fillItemsCount(by: filterId, &countsItems)
            resetFilters2(&appliedSubFilters, &enabledFilters, &enabledSubfilters, 0, rangePrice)
            return
        }
        // block #3 <<
        
        // block #4 >>
        let rem = getSubFilters(by: items, &countsItems)
        disableSubFilters(filterId: filterId, &enabledSubfilters)
        rem.forEach{ id in
            if enabledSubfilters[id] != nil {
                enabledSubfilters[id] = true
            }
        }
        // block #4 <<
    }
    
    private func applyByPrice(categoryId: CategoryId, enabledFilters: inout EnabledFilters, rangePrice: RangePrice) {
        let items = getItemsByPrice(rangePrice)
        let rem = getSubFilters(by: items)
        enableAllFilters(&enabledFilters, enable: false)
        rem.forEach({id in
            if let subfilter = subFilters[id] {
                enableFilters(subfilter.filterId, &enabledFilters)
            }
        })
    }
    
    
    private func enableFilters(_ filterId: CategoryId, _ enabledFilters: inout EnabledFilters){
        enabledFilters[filterId] = true
    }
    
    private func enableAllFilters(_ enabledFilters: inout EnabledFilters, exceptFilterId: Int = 0, enable: Bool ){
        for (key, _) in enabledFilters {
            enabledFilters[key] = enable
        }
        
        if exceptFilterId != 0 {
            enabledFilters[exceptFilterId] = true
        }
    }
    
    private func enableAllSubFilters(except filterId: CategoryId = 0, _ enabledSubFilters: inout EnabledSubfilters, enable: Bool){
        for (key, val) in subFilters {
            if val.filterId != filterId || filterId == 0 {
                enabledSubFilters[key] = enable
            }
        }
    }
    
    
    private func enableAllSubFilters2(except filterId: FilterId = 0, _ enabledFilters: inout EnabledSubfilters, enable: Bool){
        let ids1 = subFilters.filter({$0.value.filterId != filterId || filterId == 0 }).compactMap({$0.key})
        
        for id in ids1 {
            enabledFilters[id] = enable
        }
        
        if (filterId == 0) {
            return
        }
        
        let ids2 = subFilters.filter({$0.value.filterId == filterId}).compactMap({$0.key})
        for id in ids2 {
            enabledFilters[id] = !enable
        }
    }
    
    private func getSubFilters(by items: Set<Int> ) -> [Int] {
        let sub = items.compactMap{subfiltersByItem[$0]}
        return sub.flatMap{$0}
    }
    
    private func getSubFilters(by items: Set<Int>, _ countsItems: inout CountItems ) -> [Int] {
        let subfilters = items.compactMap{subfiltersByItem[$0]}.flatMap{$0}
        subfilters.forEach({id in
            if let cnt = countsItems[id] {
                countsItems[id] = cnt + 1
            } else {
                countsItems[id] = 1
            }
        })
        return subfilters
    }
    
    
    private func fillItemsCount(by filterId: FilterId, _ countsItems: inout CountItems){
        guard let subfilters = subfiltersByFilter[filterId] else { return }
        for subfID in subfilters {
            if let tmp = itemsBySubfilter[subfID] {
                countsItems[subfID] = tmp.count
            }
        }
    }
    
    
    private func removeApplied( appliedSubFilters: inout Applied,
                                selectedSubFilters: inout Selected,
                                filterId: Int = 0) {
        var removing = Set<Int>()
        if filterId == 0 {
            removing = appliedSubFilters
        } else {
            removing = appliedSubFilters.filter({subFilters[$0]?.filterId == filterId})
        }
        appliedSubFilters.subtract(removing)
        selectedSubFilters.subtract(removing)
    }
    
    
    private func resetFilters(  _ applied: inout Applied,
                                _ selected: inout Selected,
                                _ enabledFilters: inout EnabledFilters,
                                _ enabledSubfilters: inout EnabledSubfilters,
                                _ exceptFilterId: Int = 0,
                                _ rangePrice: RangePrice? = nil
        ){
        applied.removeAll()
        selected.removeAll()
        enableAllFilters(&enabledFilters, enable: true)
        enableAllSubFilters(except: exceptFilterId, &enabledSubfilters, enable: true)
        resetRangePrice(rangePrice)
    }
    
    private func resetFilters2( _ applied: inout Applied,
                                _ enabledFilters: inout EnabledFilters,
                                _ enabledSubfilters: inout EnabledSubfilters,
                                _ exceptFilterId: Int = 0,
                                _ rangePrice: RangePrice? = nil
        ){
        applied.removeAll()
        enableAllFilters(&enabledFilters, enable: true)
        enableAllSubFilters(except: exceptFilterId, &enabledSubfilters, enable: true)
        resetRangePrice(rangePrice)
    }
    
    private func resetRangePrice(_ rangePrice: RangePrice?) {
        guard let rp = rangePrice else { return }
        rp.tipMinPrice = rp.initialMinPrice
        rp.tipMaxPrice = rp.initialMaxPrice
    }
    
    
    private func disableSubFilters(filterId: FilterId, _ enabledSubfilters: inout EnabledSubfilters){
        for (key, val) in subFilters {
            if val.filterId == filterId {
                enabledSubfilters[key] = false
            }
        }
    }
    
    
    private func getEnabledSubFilters(ids: [Int]) -> [SubfilterModel?] {
        let res = ids
            .compactMap({subFilters[$0]})
            .filter({$0.enabled == true})
        return res
    }
    
    private func getEnabledFilters()->[FilterModel?] {
        return filters
            .compactMap({$0.value})
            .filter({$0.enabled == true})
            .sorted(by: {$0.id < $1.id })
    }
    
    
    private func getEnabledFiltersIds(_ enabledFilters: inout EnabledFilters)->[Int?] {
        return enabledFilters
            .filter({$0.value == true })
            .compactMap({$0.key})
            .sorted(by: {$0 < $1 })
    }
    
    
    private func getEnabledSubFiltersIds(_ enabledSubfilters: inout EnabledSubfilters)->[Int?] {
        return enabledSubfilters
            .filter({$0.value == true })
            .compactMap({$0.key})
            .sorted(by: {$0 < $1 })
    }
    
    private func fillEnabledFilters(_ enabledFilters: inout EnabledFilters){
        for filter in filters {
            enabledFilters[filter.key] = true
        }
    }
    
    private func fillEnabledSubFilters(_ enabledSubfilters: inout EnabledSubfilters){
        
        for subf in subFilters  {
            enabledSubfilters[subf.key] = true
        }
    }
    
    
    private func checkSubFilterApply() -> Bool {
        if filters_HasSet == false ||
           subfilters_HasSet == false ||
           subfiltersByItem_HasSet == false ||
           itemsBySubfilter_HasSet == false ||
           priceByItemId_HasSet == false {
            return false
        }
        return true
    }
    
    
    private func timer4SubFilterApply()  -> Bool {
        var tryNo = 1
        var ready = false
        
        while ready == false && tryNo <= limitTry {
            ready = checkSubFilterApply()
            if ready {
                return true
            }
            sleep(1)
            tryNo += 1
        }
        return false
    }
    
    
    private func checkEnterSubFilter() -> Bool {
        if filters_HasSet == false ||
            subfilters_HasSet == false ||
            subfiltersByItem_HasSet == false ||
            itemsBySubfilter_HasSet == false ||
            priceByItemId_HasSet == false {
            return false
        }
        return true
    }
    
    
    private func timer4SubFilterEnter() -> Bool {
        var tryNo = 1
        var ready = false
        while ready == false && tryNo <= limitTry {
            print("timer: \(tryNo)")
            ready = checkEnterSubFilter()
            if ready {
                return true
            }
            sleep(1)
            tryNo += 1
        }
        return false
    }
}



protocol FilterApplyLogicProtocol {
    
    
    func doLoadSubFilters(_ filterId: FilterId, _ appliedSubFilters: Set<Int>?, _ rangePrice: RangePrice?, completion: ((FilterId, SubFilterIds, Applied, CountItems) -> Void)?)
    
    func doLoadFilters() -> Observable<([FilterModel], [SubfilterModel])>
    
    func doCalcMidTotal(_ appliedSubFilters: Set<Int>,  _ selectedSubFilters: Set<Int>, _ rangePrice: RangePrice, completion: ((Int) -> Void)?)
    
    func doApplyFromFilter(_ appliedSubFilters: Set<Int>,  _ selectedSubFilters: Set<Int>, _ rangePrice: RangePrice, completion: ((FilterIds, SubFilterIds, Applied, Selected, ItemIds) -> Void)? )
    
    func doApplyFromSubFilters(_ filterId: Int, _ appliedSubFilters: Set<Int>, _ selectedSubFilters: Set<Int>, _ rangePrice: RangePrice, completion: ((FilterIds, SubFilterIds, Applied, Selected, RangePrice, ItemsTotal) -> Void)? )
    
    func doRemoveFilter(_ filterId: Int, _ appliedSubFilters: Set<Int>,  _ selectedSubFilters: Set<Int>, _ rangePrice: RangePrice, completion: ((FilterIds, SubFilterIds, Applied, Selected, RangePrice, ItemsTotal) -> Void)? )
    
    func doApplyByPrices(_ categoryId: Int, _ rangePrice: RangePrice, completion: (([Int?]) -> Void)? )
    
    func setup(filters_: [FilterModel]?,
               subFilters_: [SubfilterModel]?,
              // subfiltersByFilter: SubfiltersByFilter?,
               subfiltersByItem_: SubfiltersByItem?,
               itemsBySubfilter_: ItemsBySubfilter?,
               priceByItemId_: PriceByItemId?
    )
    
    func setupItemsAndSubfilters(subfiltersByItem: SubfiltersByItem)
    
    func dealloc()
}


extension FilterApplyLogic: FilterApplyLogicProtocol {
    
    
    
    func doCalcMidTotal(_ appliedSubFilters: Set<Int>,  _ selectedSubFilters: Set<Int>, _ rangePrice: RangePrice, completion: ((Int) -> Void)?) {
        
        controlActiveTasks.sync { [weak self] in
            guard let `self` = self
                else { return }
            
            let count = self.applyForTotal(appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters, rangePrice: rangePrice)
            completion?(count)
        }
    }
    
    
    func doApplyFromFilter(_ appliedSubFilters: Set<Int>,
                           _ selectedSubFilters: Set<Int>,
                           _ rangePrice: RangePrice,
                           completion: ((FilterIds, SubFilterIds, Applied, Selected, ItemIds) -> Void)?
                           ){
        
        controlActiveTasks.sync { [weak self] in
            
            guard let `self` = self
                else { return }
            
            var enabledFilters = EnabledFilters()
            var enabledSubfilters = EnabledSubfilters()
            var itemsIds: [Int] = []
            var applied = appliedSubFilters
            var selected = selectedSubFilters
            self.fillEnabledFilters(&enabledFilters)
            self.fillEnabledSubFilters(&enabledSubfilters)
        
        
            self.applyFromFilter(&applied,
                            &selected,
                            &enabledFilters,
                            &enabledSubfilters,
                            &itemsIds,
                            rangePrice)
        
            let filtersIds = self.getEnabledFiltersIds(&enabledFilters)
            let subFiltersIds = self.getEnabledSubFiltersIds(&enabledSubfilters)
            itemsIds.sort(by: {$0 < $1})
            completion?(filtersIds, subFiltersIds, applied, selected, itemsIds)
        }
    }
    
    
    
    func doApplyFromSubFilters(_ filterId: Int,
                               _ appliedSubFilters: Set<Int>,
                               _ selectedSubFilters: Set<Int>,
                               _ rangePrice: RangePrice,
                               completion: ((FilterIds, SubFilterIds, Applied, Selected, RangePrice, ItemsTotal) -> Void)? )  {
        
        
        guard self.timer4SubFilterApply()
            else {
                return
        }
        
        controlActiveTasks.sync { [weak self] in
            
            guard let `self` = self
                else { return }
            
            
            var enabledFilters = EnabledFilters()
            var enabledSubfilters = EnabledSubfilters()
            var applied = appliedSubFilters
            var selected = selectedSubFilters
            self.fillEnabledFilters(&enabledFilters)
            self.fillEnabledSubFilters(&enabledSubfilters)
            
            rangePrice.tipMinPrice = 50000000
            rangePrice.tipMaxPrice = -1
            var itemsTotal = 0
            
            self.applyFromSubFilter(filterId,
                               &applied,
                               &selected,
                               &enabledFilters,
                               &enabledSubfilters,
                               rangePrice,
                               &itemsTotal
                               )
            
            
            let filtersIds = self.getEnabledFiltersIds(&enabledFilters)
            let subFiltersIds = self.getEnabledSubFiltersIds(&enabledSubfilters)
            completion?(filtersIds, subFiltersIds, applied, selected, rangePrice, itemsTotal)
        }
        
    }
    

    
    func doRemoveFilter(_ filterId: Int,
                        _ appliedSubFilters: Set<Int>,
                        _ selectedSubFilters: Set<Int>,
                        _ rangePrice: RangePrice,
                        completion: ((FilterIds, SubFilterIds, Applied, Selected, RangePrice, ItemsTotal) -> Void)? ) {
        
        controlActiveTasks.sync { [weak self] in
            
            guard let `self` = self
                else { return }
            
            var enabledFilters = EnabledFilters()
            var enabledSubfilters = EnabledSubfilters()
            var applied = appliedSubFilters
            var selected = selectedSubFilters
            self.fillEnabledFilters(&enabledFilters)
            self.fillEnabledSubFilters(&enabledSubfilters)
            
            rangePrice.tipMinPrice = 50000000
            rangePrice.tipMaxPrice = -1
            var itemsTotal = 0
 
            self.removeFilter(&applied,
                         &selected,
                         filterId,
                         &enabledFilters,
                         &enabledSubfilters,
                         rangePrice,
                         &itemsTotal)
            
            
            let filtersIds = self.getEnabledFiltersIds(&enabledFilters)
            let subFiltersIds = self.getEnabledSubFiltersIds(&enabledSubfilters)
            completion?(filtersIds, subFiltersIds, applied, selected, rangePrice, itemsTotal)
        }
    }
    
    

    func doLoadSubFilters(_ filterId: Int = 0, _ appliedSubFilters: Set<Int>?, _ rangePrice: RangePrice?, completion: ((FilterId, SubFilterIds, Applied, CountItems) -> Void)?)  {
        
            
        guard let rangePrice_ = rangePrice,
              var applied = appliedSubFilters
            else { return}
        
        guard self.timer4SubFilterEnter()
            else { return }
       
        controlActiveTasks.sync { [weak self] in
            guard let `self` = self
                else { return }
            
            var enabledFilters = EnabledFilters()
            var enabledSubfilters = EnabledSubfilters()
            var countsItems = CountItems()
            self.fillEnabledFilters(&enabledFilters)
            self.fillEnabledSubFilters(&enabledSubfilters)
            
            
            self.applyBeforeEnter(&applied,
                             filterId,
                             &enabledFilters,
                             &enabledSubfilters,
                             &countsItems,
                             rangePrice_)
            
            let subFiltersIds = self.getEnabledSubFiltersIds(&enabledSubfilters)
            completion?(filterId, subFiltersIds, applied, countsItems)
        }
    }
    
    
    func doLoadFilters() -> Observable<([FilterModel], [SubfilterModel])> {
        return Observable.empty()
        //return Observable.just((TestData.loadFilters(), TestData.loadSubFilters(filterId: 0)))
    }
    
    

    
    func doApplyByPrices(_ categoryId: Int, _ rangePrice: RangePrice, completion: (([Int?]) -> Void)? ) {
        
        controlActiveTasks.sync { [weak self] in
            guard let `self` = self
                else { return }
            
            var enabledSubfilters = EnabledSubfilters()
            self.fillEnabledFilters(&enabledSubfilters)
            
            self.applyByPrice(categoryId: categoryId, enabledFilters: &enabledSubfilters, rangePrice: rangePrice)
            
            let subFiltersIds = self.getEnabledSubFiltersIds(&enabledSubfilters)
            completion?(subFiltersIds)
        }
    }
    
    
    
    
    func setup(filters_: [FilterModel]? = nil,
               subFilters_: [SubfilterModel]? = nil,
              // subfiltersByFilter: SubfiltersByFilter? = nil,
               subfiltersByItem_: SubfiltersByItem? = nil,
               itemsBySubfilter_: ItemsBySubfilter? = nil,
               priceByItemId_: PriceByItemId? = nil
        ){
        
        controlActiveTasks.async(flags: .barrier) { [weak self] in
            
            guard let `self` = self
                else { return }
            
            if let a = filters_ {
                print("----------- Apply :::: Filters:")
                a.forEach({f in
                   self.filters[f.id] = f
                   print("\(self.filters[f.id]?.title)")
                })
                print("----------- Filters count: \(self.filters.count)")
                print(" ")
                print(" ")
                print(" ")
                self.filters_HasSet = true
            }
            
            if let b = subFilters_ {
                print("----------- Apply :::: Subfilters:")
                b.forEach({s in
                    self.subFilters[s.id] = s
                  //  print("\(self.subFilters[s.id]?.title)")
                    if self.subfiltersByFilter[s.filterId] == nil {
                        self.subfiltersByFilter[s.filterId] = []
                    }
                    self.subfiltersByFilter[s.filterId]?.append(s.id)
                })
                print("----------- Subfilters count: \(self.subFilters.count)    SubfiltersByFilter count: \(self.subfiltersByFilter.count)")
                print(" ")
                print(" ")
                print(" ")
                 self.subfilters_HasSet = true
            }
            
            
            if let d = subfiltersByItem_ {
                print("----------- Apply :::: SubfiltersByItem:")
                self.subfiltersByItem = d
                print("----------- SubfiltersByItem: \(self.subfiltersByItem.count)")
                print(" ")
                print(" ")
                print(" ")
                 self.subfiltersByItem_HasSet = true
            }
            
            if let e = itemsBySubfilter_ {
                print("----------- Apply :::: ItemsBySubfilter:")
                self.itemsBySubfilter = e
                print("----------- ItemsBySubfilter count: \(self.itemsBySubfilter.count)")
                print(" ")
                print(" ")
                print(" ")
                 self.itemsBySubfilter_HasSet = true
            }
            
            if let f = priceByItemId_ {
                print("----------- Apply :::: PriceByItemId:")
                self.priceByItemId = f
                print("----------- PriceByItemId  count: \(self.priceByItemId.count)")
                print(" ")
                print(" ")
                print(" ")
                 self.priceByItemId_HasSet = true
            }
        }
    }
    
    
    func setupItemsAndSubfilters(subfiltersByItem: SubfiltersByItem) {
        
        controlActiveTasks.async(flags: .barrier) { [weak self] in
            
            guard let `self` = self
                else { return }
            
            print("----------- Apply :::: SubfiltersByItem:")
            self.subfiltersByItem = subfiltersByItem
            print("----------- SubfiltersByItem: \(self.subfiltersByItem.count)")
            print(" ")
            print(" ")
            print(" ")
            
            var tmpItemsBySubfilter = ItemsBySubfilter()
            for (itemId, subfilterIds) in subfiltersByItem {
                for subfilterId in subfilterIds {
                    if tmpItemsBySubfilter[subfilterId] == nil {
                        tmpItemsBySubfilter[subfilterId] = []
                    }
                    tmpItemsBySubfilter[subfilterId]?.append(itemId)
                }
            }
            
            self.itemsBySubfilter = tmpItemsBySubfilter
            
            print("----------- Apply :::: ItemsBySubfilter:")
            print("----------- ItemsBySubfilter count: \(self.itemsBySubfilter.count)")
            print(" ")
            print(" ")
            print(" ")
            
            
            self.subfiltersByItem_HasSet = true
            self.itemsBySubfilter_HasSet = true
        }
    }
    
    
    
    
    func dealloc(){
        
        controlActiveTasks.async(flags: .barrier) {[weak self] in
            
            guard let `self` = self
                else { return }
            
            let filterKeys = self.filters.filter({$0.value.cross == false}).compactMap({$0.key})
            
            filterKeys.forEach({key in
                self.filters.removeValue(forKey: key)
                self.subfiltersByFilter.removeValue(forKey: key)
                self.sectionSubFiltersByFilter.removeValue(forKey: key)
                let subfilterKeys = self.subFilters.filter({$0.value.filterId == key}).compactMap({$0.key})
                subfilterKeys.forEach{subfilterKey in
                    self.subFilters.removeValue(forKey: subfilterKey)
                }
            })
            

            self.filters_HasSet = false
            self.subfilters_HasSet = false
            self.subfiltersByItem_HasSet = false
            self.itemsBySubfilter_HasSet = false
            self.priceByItemId_HasSet = false
            
            
            self.subfiltersByItem.removeAll()
            self.itemsBySubfilter.removeAll()
            self.priceByItemId.removeAll()
            self.itemsById.removeAll()
            self.itemsByCatalog.removeAll()
            self.itemIds.removeAll()
            print("----------- Apply :::: After dealloc: ")
            print("----------- filters : \(self.filters.count)")
            print("----------- subfilters : \(self.subFilters.count)")
            print("----------- subfiltersByFilter : \(self.subfiltersByFilter.count)")
            print(" ")
            print(" ")
            print(" ")
        }
    }
    
}

