import Foundation
import RxSwift
import RxCocoa
import Kingfisher

protocol FilterActionDelegate : class {
    func applyFromFilterEvent() -> PublishSubject<Void>
    func applyFromSubFilterEvent() -> PublishSubject<FilterId>
    func removeFilterEvent() -> PublishSubject<FilterId>
    func filtersEvent() -> BehaviorSubject<[FilterModel?]>
    func requestFilters(categoryId: CategoryId)
    func subFiltersEvent() -> BehaviorSubject<[SubfilterModel?]>
    func requestSubFilters(filterId: FilterId)
    func sectionSubFiltersEvent() -> BehaviorSubject<[SectionOfSubFilterModel]>
    func selectSubFilterEvent() -> PublishSubject<(SubFilterId, Bool)>
    func appliedTitle(filterId: FilterId) -> String
    func isSelectedSubFilter(subFilterId: SubFilterId) -> Bool
    func getTitle(filterId: FilterId) -> String
    func getFilterEnum(filterId: FilterId)->FilterEnum
    func cleanupFromFilterEvent() -> PublishSubject<Void>
    func cleanupFromSubFilterEvent() -> PublishSubject<FilterId>
    func requestComplete() -> PublishSubject<FilterId>
    func showApplyViewEvent() -> BehaviorSubject<Bool>
    func showPriceApplyViewEvent() -> PublishSubject<Bool>
    func refreshedCellSelectionsEvent()->PublishSubject<Set<Int>>
    func applyByPrices() -> PublishSubject<Void>
    func getRangePrice()-> (MinPrice, MaxPrice, MinPrice, MaxPrice)
    func setTipRangePrice(minPrice: MinPrice, maxPrice: MaxPrice)
    func setUserRangePrice(minPrice: MinPrice, maxPrice: MaxPrice)
    func wait() -> BehaviorSubject<(FilterActionEnum, Bool, Int)>
    func back() -> PublishSubject<FilterActionEnum>
    func getMidTotal() -> PublishSubject<Int>
    func calcMidTotal(tmpMinPrice: MinPrice, tmpMaxPrice: MaxPrice)
    func showApplyWarning() -> PublishSubject<Void>
    func reloadSubfilterVC() -> PublishSubject<Void>
    func refreshFromSubfilter()
    func refreshFromFilter()
    func prefetchItemAt(indexPaths: [IndexPath])
}



// MARK: -------------- implements FilterActionDelegate --------------
extension CatalogVM : FilterActionDelegate {
   
    convenience init(categoryId: CategoryId) {
        self.init(categoryId: categoryId, fetchLimit: 0,  totalPages: 0, totalItems: 0)
        
    }
    
    func requestFilters(categoryId: CategoryId) {
        if filters.count == 0 {
            wait().onNext((.enterFilter, true, defWaitDelay))
        }
        midAppliedSubFilters = appliedSubFilters // crytical! зависит работа applySubfilter
    }
    
    func requestSubFilters(filterId: FilterId) {
        wait().onNext((.enterSubFilter, true, defWaitDelay))
        currEnteredFilterId = filterId
        showCleanSubFilterVC(filterId: filterId)
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let `self` = self else { return }
            getDataService().reqEnterSubFilter(filterId: filterId,
                                                  applied: self.midAppliedSubFilters,
                                                  rangePrice: self.rangePrice.getPricesWhenRequestSubFilters())
        }
    }
    
    func removeFilterEvent() -> PublishSubject<FilterId> {
        return inRemoveFilterEvent
    }
    
    func filtersEvent() -> BehaviorSubject<[FilterModel?]> {
        return outFiltersEvent
    }
    
    func subFiltersEvent() -> BehaviorSubject<[SubfilterModel?]> {
        return outSubFiltersEvent
    }
    
    func applyFromFilterEvent() -> PublishSubject<Void> {
        return inApplyFromFilterEvent
    }
    
    func applyFromSubFilterEvent() -> PublishSubject<FilterId> {
        return inApplyFromSubFilterEvent
    }
    
    func applyByPrices() -> PublishSubject<Void> {
        return inApplyByPricesEvent
    }
    
    func requestComplete() -> PublishSubject<FilterId> {
        return outRequestComplete
    }
    
    func sectionSubFiltersEvent() -> BehaviorSubject<[SectionOfSubFilterModel]> {
        return outSectionSubFiltersEvent
    }
    
    func selectSubFilterEvent() -> PublishSubject<(SubFilterId, Bool)> {
        return inSelectSubFilterEvent
    }
    
    func cleanupFromFilterEvent() -> PublishSubject<Void> {
        return inCleanUpFromFilterEvent
    }
    
    func cleanupFromSubFilterEvent() -> PublishSubject<FilterId> {
        return inCleanUpFromSubFilterEvent
    }
    
    func refreshFromSubfilter(){
        inRefreshFromSubFilterEvent.onNext(Void())
    }
    
    func refreshFromFilter(){
        inRefreshFromFilterEvent.onNext(Void())
    }
    
    func showApplyViewEvent() -> BehaviorSubject<Bool> {
        return outShowApplyViewEvent
    }
    
    func showPriceApplyViewEvent() -> PublishSubject<Bool> {
        return outShowPriceApplyViewEvent
    }
    
    func showApplyWarning() -> PublishSubject<Void> {
        return outShowWarning
    }
    
    func refreshedCellSelectionsEvent() -> PublishSubject<Set<Int>> {
        return outRefreshedCellSelectionsEvent
    }
    
    func wait() -> BehaviorSubject<(FilterActionEnum, Bool, Int)> {
        return outWaitEvent
    }
    
    func back() -> PublishSubject<FilterActionEnum> {
        return outBackEvent
    }
    
    func prefetchItemAt(indexPaths: [IndexPath]) {
        let models = indexPaths.compactMap({self.catalog(at: $0.row)})
        for model in models {
            if model.imageView == nil {
                model.imageView = UIImageView()
                model.imageView?.kf.setImage(with: URL(string: getCatalogImage(picName: "1010403_orange_0")),
                                             placeholder: nil,
                                             options: [],
                                             progressBlock: nil,
                                             completionHandler: nil)
            }
        }
    }
    
    
    func getRangePrice() -> (MinPrice, MaxPrice, MinPrice, MaxPrice) {
        return rangePrice.getRangePrice()
    }
    
    func setTipRangePrice(minPrice: MinPrice, maxPrice: MaxPrice) {
        rangePrice.setTipRangePrice(minPrice: minPrice, maxPrice: maxPrice)
    }
    
    func setUserRangePrice(minPrice: MinPrice, maxPrice: MaxPrice) {
        rangePrice.setUserRangePrice(minPrice: minPrice, maxPrice: maxPrice)
    }
    
    func getMidTotal() -> PublishSubject<Int> {
        return outMidTotal
    }
    
    func calcMidTotal(tmpMinPrice: MinPrice, tmpMaxPrice: MaxPrice) {
         let tmpRangePrice = RangePrice.shared.clone()
         tmpRangePrice.setUserRangePrice(minPrice: tmpMinPrice, maxPrice: tmpMaxPrice)
         let midApplying = self.midAppliedSubFilters.subtracting(self.unapplying)
         getDataService().reqMidTotal(categoryId: categoryId,
                                           appliedSubFilters: midApplying,
                                           selectedSubFilters: self.selectedSubFilters,
                                           rangePrice:  tmpRangePrice)
    }
    
    func reloadSubfilterVC() -> PublishSubject<Void> {
        return outReloadSubFilterVCEvent
    }
    
    func appliedTitle(filterId: FilterId) -> String {
        var res = ""
        let arr = midAppliedSubFilters
            .compactMap({subFilters[$0]})
            .filter({$0.filterId == filterId && $0.enabled == true})
        
        arr.forEach({ subf in
            res.append(subf.title + ",")
        })
        if res.count > 0 {
            res.removeLast()
        }
        return res
    }
    
    func isSelectedSubFilter(subFilterId: SubFilterId) -> Bool {
        var res = false
        res = selectedSubFilters.contains(subFilterId) || midAppliedSubFilters.contains(subFilterId) //appliedSubFilters.contains(subFilterId)
        return res
    }
    
    func getTitle(filterId: FilterId) -> String {
        guard
            let filter = filters[filterId]
            else { return ""}
        
        return filter.title
    }
    
    func getFilterEnum(filterId: FilterId) -> FilterEnum {
        guard
            let filter = filters[filterId]
            else { return .select}
        
        return filter.filterEnum
    }
    
    
 
    internal func handleDelegate(){
        
        applyFromFilterEvent()
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                guard self.itemsTotal > 0
                    else {
                        self.showApplyWarning().onNext(Void())
                        return
                    }


                // check if new applying exists
                let united = self.midAppliedSubFilters.subtracting(self.unapplying).union(self.selectedSubFilters)
                guard united.subtracting(self.appliedSubFilters).count > 0 ||
                      self.appliedSubFilters.subtracting(united).count > 0 ||
                      self.rangePrice.isUserChangedPriceFilter()
                else {
                    self.back().onNext(.closeFilter)
                    return
                }


                let midApplying = self.midAppliedSubFilters.subtracting(self.unapplying)
                if midApplying.count == 0 &&
                   self.selectedSubFilters.count == 0 &&
                   self.rangePrice.isUserChangedPriceFilter() == false {
                        self.resetFilters()
                        self.back().onNext(.closeFilter)
                        return
                }

                self.resetFetch() // added
                self.unapplying.removeAll()
                self.wait().onNext((.applyFilter, true, self.defWaitDelay))
                self.back().onNext(.closeFilter)

                DispatchQueue.global(qos: .background).async {
                    getDataService().reqApplyFromFilter(categoryId: self.categoryId,
                                                            appliedSubFilters: midApplying,
                                                            selectedSubFilters: self.selectedSubFilters,
                                                            rangePrice: self.rangePrice.getPricesWhenApplyFilter())
                }
            })
            .disposed(by: bag)


        applyFromSubFilterEvent()
            .subscribe(onNext: {[weak self] filterId in
                guard let `self` = self else { return }

                guard self.canApplyFromSubfilter == true
                    else {
                        self.back().onNext(.closeSubFilter)
                        self.unitTestSignalOperationComplete.onNext(self.utMsgId)
                        return
                    }
                self.back().onNext(.closeSubFilter)
                self.canApplyFromSubfilter = false
                let midApplying = self.midAppliedSubFilters.subtracting(self.unapplying)
                self.wait().onNext((.applySubFilter, true, self.defWaitDelay))
                self.unapplying.removeAll()
                self.cleanupFilterVC()
                DispatchQueue.global(qos: .background).async {
                    getDataService().reqApplyFromSubFilter(categoryId: self.categoryId,
                                                                  filterId: filterId,
                                                                  appliedSubFilters: midApplying,
                                                                  selectedSubFilters: self.selectedSubFilters,
                                                                  rangePrice: self.rangePrice.getPricesWhenApplySubFilter())
                }
            })
            .disposed(by: bag)


        applyByPrices()
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                DispatchQueue.global(qos: .background).async {
                    getDataService().reqApplyByPrices(categoryId: self.categoryId,
                                                    rangePrice: self.rangePrice.getPricesWhenApplyByPrices())
                }
            })
            .disposed(by: bag)


        removeFilterEvent()
            .subscribe(onNext: {[weak self] filterId in
                if let `self` = self {
                    self.wait().onNext((.removeFilter, true, self.defWaitDelay))
                    let midApplying = self.midAppliedSubFilters
                    self.unapplying.removeAll()
                    getDataService().reqRemoveFilter(categoryId: self.categoryId,
                                                   filterId: filterId,
                                                   appliedSubFilters: midApplying,
                                                   selectedSubFilters: self.selectedSubFilters,
                                                   rangePrice: self.rangePrice.getPricesWhenRemoveFilter()
                                                   )
                }
            })
            .disposed(by: bag)


        selectSubFilterEvent()
            .subscribe(onNext: {[weak self] (subFilterId, selected) in
                self?.selectSubFilter(subFilterId: subFilterId, selected: selected)
            })
            .disposed(by: bag)


        cleanupFromFilterEvent()
            .subscribe(onNext: {[weak self] _ in
                if let `self` = self {
                    self.resetFilters()
                    self.unitTestSignalOperationComplete.onNext(self.utMsgId)
                }
            })
            .disposed(by: bag)


        cleanupFromSubFilterEvent()
            .subscribe(onNext: {[weak self] filterId in
                guard let `self` = self else { return }

                self.back().onNext(.closeFilter)

                guard let ids = self.subfiltersByFilter[filterId] else { return }

                let res = Set(ids).intersection(self.selectedSubFilters)

                self.outRefreshedCellSelectionsEvent.onNext(res)

                for id in ids {
                    self.selectSubFilter(subFilterId: id, selected: false)
                }
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)


        getDataService().getNetError()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] err in
                guard let `self` = self else { return }
                switch err {
                    case .prefetch_ServerRetError:
                            self.isPrefetchInProgress = false
                            self.wait().onNext((.prefetchCatalog, false, self.defWaitDelay))
                    return
                    case .catalogStart_ServerRetError: break
                    case .prefetch_ServerRetEmpty: break
                    case .catalogStart_ServerRetEmpty: break
                    case .categoryApply_ServerRetError: break
                    case .categoryApply_ServerRetEmpty: break
                    case .categoryFilters_ServerRetError: break
                    case .categoryFilters_ServerRetEmpty: break
                    case .crossFilters_ServerRetError: break
                    case .crossFilters_ServerRetEmpty: break
                    case .uid_ServerRetError: break
                    case .uid_ServerRetEmpty: break
                    case .specificError:
                        break
                }
            })
            .disposed(by: bag)

        getDataService().getMidNetError()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] err, trying in
                guard let `self` = self else { return }
                switch err {
                case .prefetch_ServerRetError:
                    print("trying \(trying)")
                    if trying == 0 {
                        self.wait().onNext((.prefetchCatalog, true, 0))
                    }
                    return
                case .catalogStart_ServerRetError: break
                case .prefetch_ServerRetEmpty: break
                case .catalogStart_ServerRetEmpty: break
                case .categoryApply_ServerRetError: break
                case .categoryApply_ServerRetEmpty: break
                case .categoryFilters_ServerRetError: break
                case .categoryFilters_ServerRetEmpty: break
                case .crossFilters_ServerRetError: break
                case .crossFilters_ServerRetEmpty: break
                case .uid_ServerRetError: break
                case .uid_ServerRetEmpty: break
                case .specificError:
                    break
                }
            })
            .disposed(by: bag)



        getDataService().getEnterSubFilterEvent()
            .observeOn(MainScheduler.asyncInstance)
            .filter({$0.1.count > 0})
            .subscribe(onNext: {[weak self] res in
                guard let `self` = self else { return }
                let filterId = res.0
                let filterIds = res.1
                let countBySubfilterId = res.3
                self.enableSubFilters(ids: filterIds, countBySubfilterId: countBySubfilterId)
                self.midAppliedSubFilters = res.2
                self.subFiltersFromCache(filterId: filterId)
                if self.subfiltersByFilter[filterId]?.count ?? 0 > 0 {
                    self.wait().onNext((.enterSubFilter, false, 0))
                }
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)


        getDataService().getApplyForItemsEvent()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] _filters in
                guard let `self` = self else { return }
                self.enableFilters(ids: _filters.0)
                self.enableSubFilters(ids: _filters.1)

                self.appliedSubFilters = _filters.2
                self.midAppliedSubFilters = _filters.2 // last added!!!
                self.selectedSubFilters = _filters.3
                self.outFiltersEvent.onNext(self.getEnabledFilters())
                print("HLL:::")
                self.fetchAfterApplyFromFilter(itemIds: _filters.4)
                self.wait().onNext((.applyFilter, false, 0))

                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)


        getDataService().getApplyForFiltersEvent()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] _filters in
                guard let `self` = self else { return }
                self.enableFilters(ids: _filters.0)
                self.enableSubFilters(ids: _filters.1)
                self.midAppliedSubFilters = _filters.2
                self.selectedSubFilters.removeAll()
                self.setTipRangePrice(minPrice: _filters.4, maxPrice: _filters.5)

                self.itemsTotal = _filters.6
                self.outMidTotal.onNext(self.itemsTotal)

                let filters = self.getEnabledFilters()
                self.outFiltersEvent.onNext(filters)
                self.wait().onNext((.applySubFilter, false, 0))

                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)


        getDataService().getApplyByPriceEvent()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] _filters in
                guard let `self` = self else { return }
                self.enableFilters(ids: _filters)
                let filters = self.getEnabledFilters()
                self.outFiltersEvent.onNext(filters)
            })
            .disposed(by: bag)


        getDataService().getPrefetchEvent()
            .subscribe(onNext: {[weak self] res in
                guard let `self` = self else { return }
                self.inPrefetchEvent.onNext(res)
            })
            .disposed(by: bag)


        getDataService().getFilters()
            .filter({$0.count > 0})
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] res in
                guard let `self` = self else { return }

                guard res.count > 0 else { return }
                let filters = res
                filters.forEach { [weak self] filter in
                    self?.filters[filter.id] = filter
                }

               // self.filters = Dictionary(uniqueKeysWithValues: filters.compactMap({$0}).map{ ($0.id, $0) })
                self.outFiltersEvent.onNext(self.getEnabledFilters())
                self.wait().onNext((.enterFilter, false, 0))
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)


        getDataService().getCrossFilters()
            .filter({$0.count > 0})
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] res in
                guard let `self` = self else { return }

                guard res.count > 0 else { return }
                let filters = res
                filters.forEach { [weak self] filter in
                    self?.filters[filter.id] = filter
                }

                // self.filters = Dictionary(uniqueKeysWithValues: filters.compactMap({$0}).map{ ($0.id, $0) })
                self.outFiltersEvent.onNext(self.getEnabledFilters())
                self.wait().onNext((.enterFilter, false, 0))
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)


        getDataService().getCrossSubfilters()
            .filter({$0.count > 0})
            .subscribe(onNext: { [weak self] res in
                self?.fillSubfiltersTask(subFilters: res)
            })
            .disposed(by: bag)

        getDataService().getCategorySubfilters()
            .filter({$0.count > 0})
            .subscribe(onNext: { [weak self] res in
                self?.fillSubfiltersTask(subFilters: res)
            })
            .disposed(by: bag)


        getDataService().getMidTotal()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] count in
                self?.itemsTotal = count
                self?.outMidTotal.onNext(count)
            })
            .disposed(by: bag)



        inRefreshFromSubFilterEvent
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] _ in
                DispatchQueue.global(qos: .background).async {[weak self] in
                    guard let `self` = self else { return }
                    getDataService().reqEnterSubFilter(filterId: self.currEnteredFilterId,
                                                           applied: self.midAppliedSubFilters,
                                                           rangePrice: self.rangePrice.getPricesWhenRequestSubFilters())
                }
            })
            .disposed(by: bag)


        inRefreshFromFilterEvent
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] _ in
                DispatchQueue.global(qos: .background).async {[weak self] in
                    guard let `self` = self else { return }
                    getDataService().screenHandle(dataTaskEnum: .willCatalogShow, self.categoryId)
                }
            })
            .disposed(by: bag)

    }
    
    func fillSubfiltersTask(subFilters: [SubfilterModel]){
        
        let completion = { [weak self] in
            subFilters.forEach{ subf in
                if self?.subfiltersByFilter[subf.filterId] == nil {
                    self?.subfiltersByFilter[subf.filterId] = []
                }
                if self?.subfiltersByFilter[subf.filterId]?.contains(subf.id) == false  {
                    self?.subfiltersByFilter[subf.filterId]?.append(subf.id)
                    self?.subFilters[subf.id] = subf
                }
            }
        }
        operationQueues[0]!.addOperation {
            completion()
        }
    }
    
}
