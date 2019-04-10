import Foundation
import RxSwift
import RxCocoa


enum CellLayoutEnum {
    case list, square, squares
}


struct CellLayout {
    var cellLayoutType: CellLayoutEnum
    var cellScale: CGSize
    var cellSpace: CGFloat
    var lineSpace: CGFloat
    var layoutImageName: String
}


class CatalogVM : BaseVM {
    
    // MARK: --------------properties --------------
    private var currCellLayout: CellLayoutEnum = .squares
    internal var categoryId: Int
    

    // Inputs from ViewController
    var inPressLayout:Variable<Void> = Variable<Void>(Void())
    var inPressFilter = PublishSubject<Void>()
    
    // Outputs to ViewController or Coord
    var outTitle = Variable<String>("")
    var outLayout = Variable<CellLayout?>(nil)
    var outShowFilters = PublishSubject<Int>()
    var outCloseVC = PublishSubject<Void>()
    var outReloadCatalogVC = BehaviorSubject<Bool>(value: false)
    var outFetchComplete = PublishSubject<[IndexPath]?>()
    var outFetchStart = PublishSubject<Int>() // added test
    var currEnteredFilterId = 0
    
    // Filters
    internal var filters: [Int:FilterModel] = [:]
    internal var subFilters: [Int:SubfilterModel] = [:]
    internal var subfiltersByFilter: [Int:[Int]] = [:]
    private var sectionSubFiltersByFilter: [Int:[SectionOfSubFilterModel]] = [:]
    private var catalog: [CatalogModel?] = []
    private var itemIds: [Int] = []
    internal var rangePrice = RangePrice.shared

    // Module State:
    internal var appliedSubFilters: Set<Int> = Set()
    internal var midAppliedSubFilters: Set<Int> = Set()
    internal var selectedSubFilters: Set<Int> = Set()
    internal var unapplying: Set<Int> = Set()
    
    
    // optimization: avoid network request
    private var fullCatalogItemIds: [Int] = []
    internal var canApplyFromSubfilter = false
    
    // prevent from zero-catalog
    internal var itemsTotal = 0
    
    // prefetching
    internal var inPrefetchEvent = PublishSubject<[CatalogModel?]>()
    internal var isPrefetchInProgress = false
    private var fetchLimit: Int = 100
    public var currentPage: Int
    public var totalPages: Int
    public var totalItems: Int
    
    // MARK: --------------unit test properties--------------
    public var unitTestSignalOperationComplete = BehaviorSubject<Int>(value: -1)
    public var utMsgId = 0
    
    // MARK: --------------FilterActionDelegate properties--------------
    internal var inApplyFromFilterEvent = PublishSubject<Void>()
    internal var inApplyFromSubFilterEvent = PublishSubject<FilterId>()
    internal var inApplyByPricesEvent = PublishSubject<Void>()
    internal var inRemoveFilterEvent = PublishSubject<FilterId>()
    internal var inSelectSubFilterEvent = PublishSubject<(Int, Bool)>()
    internal var inCleanUpFromFilterEvent = PublishSubject<Void>()
    internal var inCleanUpFromSubFilterEvent = PublishSubject<Int>()
    internal var inRefreshFromSubFilterEvent = PublishSubject<Void>()
    internal var inRefreshFromFilterEvent = PublishSubject<Void>()
    
    
    internal var outFiltersEvent = BehaviorSubject<[FilterModel?]>(value: [])
    internal var outSubFiltersEvent = BehaviorSubject<[SubfilterModel?]>(value: [])
    internal var outSectionSubFiltersEvent = BehaviorSubject<[SectionOfSubFilterModel]>(value: [])
    internal var outRequestComplete = PublishSubject<Int>()
    internal var outShowApplyViewEvent = BehaviorSubject<Bool>(value: false)
    internal var outShowPriceApplyViewEvent = PublishSubject<Bool>()
    internal var outRefreshedCellSelectionsEvent = PublishSubject<Set<Int>>()
    internal var outWaitEvent = BehaviorSubject<(FilterActionEnum, Bool, Int)>(value: (.noAction, false, 2))
    internal var outBackEvent = PublishSubject<FilterActionEnum>()
    internal var outMidTotal = PublishSubject<Int>()
    internal var outShowWarning = PublishSubject<Void>()
    internal var outReloadSubFilterVCEvent = PublishSubject<Void>()
    
    internal var operationQueues: [Int: OperationQueue] = [:]
    internal var defWaitDelay = 2
    
    internal init(categoryId: Int, fetchLimit: Int, totalPages: Int, totalItems: Int){
        self.categoryId = categoryId
        if fetchLimit > 0 {
            self.fetchLimit = fetchLimit
        }
        self.totalItems = self.fetchLimit
        self.currentPage = -1
        self.totalPages = totalPages
        super.init()
        addOperation()
        wait().onNext((.prefetchCatalog, true, defWaitDelay))
        emitStartEvent()
        handlePrefetchEvent()
        handleDelegate()
        handleStartEvent()
        bindUserActivities()
        
        CatalogModel.localTitle(categoryId: categoryId)
            .bind(to: outTitle)
            .disposed(by: bag)
    }
    
    
    private func addOperation() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        operationQueues[0] = queue
    }
    
    public func realloc(){

        unitTestSignalOperationComplete.onCompleted()
        inPrefetchEvent.onCompleted()
        inPressFilter.onCompleted()
        outShowFilters.onCompleted()
        outCloseVC.onCompleted()
        outReloadCatalogVC.onCompleted()
        outFetchComplete.onCompleted()
        
        inApplyFromFilterEvent.onCompleted()
        inApplyFromSubFilterEvent.onCompleted()
        inApplyByPricesEvent.onCompleted()
        inRemoveFilterEvent.onCompleted()
        inSelectSubFilterEvent.onCompleted()
        inCleanUpFromFilterEvent.onCompleted()
        inCleanUpFromSubFilterEvent.onCompleted()
        
        outFiltersEvent.onCompleted()
        outSubFiltersEvent.onCompleted()
        outSectionSubFiltersEvent.onCompleted()
        outRequestComplete.onCompleted()
        outShowApplyViewEvent.onCompleted()
        outShowPriceApplyViewEvent.onCompleted()
        outRefreshedCellSelectionsEvent.onCompleted()
        outWaitEvent.onCompleted()
        outBackEvent.onCompleted()
        outMidTotal.onCompleted()
        outShowWarning.onCompleted()
        outReloadSubFilterVCEvent.onCompleted()
        getDataService().resetBehaviorSubjects()
    }
    
    
    deinit {
        print("Catalog VM deinit")
        realloc()
    }
    // MARK: -------------- Prefetching --------------
    
    
    internal func resetCurrentPage() {
        currentPage = -1
    }
    
    internal func resetFetch(){
        resetCurrentPage()
        itemIds = []
        totalPages = 0
        catalog = []
        self.outReloadCatalogVC.onNext(true)
    }
    
    
    internal func fetchAfterApplyFromFilter(itemIds: [Int]){
        self.setupFetch(itemIds: itemIds)
        self.emitPrefetchEvent()
        self.outReloadCatalogVC.onNext(true)
        
    }
    
    
    internal func setupFetch(itemIds: [Int], fetchLimit: Int = 0){
        
        self.itemIds = itemIds
        self.totalItems = itemIds.count
        if fetchLimit != 0 {
            self.fetchLimit = fetchLimit
        }
        resetCurrentPage()
        self.totalPages = self.totalItems/self.fetchLimit
        
        catalog = []
        self.outFetchStart.onNext(self.itemIds.count < self.fetchLimit ? self.itemIds.count : self.fetchLimit)// added test
    }

    
    private func emitStartEvent(){
        getDataService().screenHandle(dataTaskEnum: .willStartPrefetch, categoryId)
    }
   
    private func handleStartEvent(){
        getDataService().getCatalogTotalEvent()
            .observeOn(MainScheduler.asyncInstance)
            .filter({[weak self] res in
                     res.0 == self?.categoryId &&
                     res.1.count > 0})
            .subscribe(onNext: { [weak self] res in
                guard let `self` = self else { return }
                self.fullCatalogItemIds = res.1
                self.setupFetch(itemIds: res.1, fetchLimit: res.2)
                self.rangePrice.setupRangePrice(minPrice: res.3, maxPrice: res.4)
                print("handleStartEvent")
                self.emitPrefetchEvent()
            })
            .disposed(by: bag)
    }
    
    
    
    
    public func emitPrefetchEvent(){
        print("emitPrefetchEvent")
        guard isPrefetchInProgress == false else {return}
        guard itemIds.count > 0
            else {
                return
            }
        
        let nextPage = currentPage + 1
        isPrefetchInProgress = true
        let from =  nextPage * fetchLimit
        let to = min(itemIds.count, nextPage * fetchLimit + fetchLimit)
        
        guard from <= to-1
            else {
                    isPrefetchInProgress = false
                    return
                }
        currentPage += 1
        let nextItemIds = itemIds[from...to-1]
        getDataService().screenHandle(dataTaskEnum: .willPrefetch, categoryId, Set(nextItemIds))
    }
    
    
    private func handlePrefetchEvent(){
        inPrefetchEvent
        .observeOn(MainScheduler.asyncInstance)
        .subscribe(onNext: {[weak self] res in
            guard let `self` = self else {return}
            switch self.currentPage {
                case 0: self.catalog = res
                default: self.catalog.append(contentsOf: res)
            }
            let indexPathsToReload = self.calcIndexPathsToReload(from: res)
            self.outFetchComplete.onNext(indexPathsToReload)
            
            self.wait().onNext((.prefetchCatalog, false, self.defWaitDelay))
            
            self.isPrefetchInProgress = false
        })
        .disposed(by: bag)
    }
    
    private func calcIndexPathsToReload(from newCatalog: [CatalogModel?]) -> [IndexPath] {
        let startIndex = catalog.count - newCatalog.count
        let endIndex = startIndex + newCatalog.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    public func currItemsCount() -> Int {
        return catalog.count
    }
    
    public func catalog(at index: Int) -> CatalogModel? {
        if index >= 0 && index < catalog.count {
            return catalog[index]
        }
        return nil
    }
    
    
    
    // MARK: -------------- User Actions in Catalog VC --------------
    private func bindUserActivities(){
        inPressLayout
            .asObservable()
            .flatMap{[weak self]  _ -> Observable<CellLayout> in
                return self!.changeLayout()
            }
            .bind(to: outLayout)
            .disposed(by: bag)
        
        inPressFilter
            .asObservable()
            .subscribe(onNext: {[weak self] _ in
                if let `self` = self {
                    self.requestFilters(categoryId: self.categoryId)
                    self.outShowFilters.onNext(self.categoryId)
                }
            })
            .disposed(by: bag)
    }
    
    
    private func changeLayout()->Observable<CellLayout>{
        
        switch currCellLayout {
        case .list:
            currCellLayout = .square
            return Observable.of(CellLayout(cellLayoutType: .square, cellScale: CGSize(width: 0.95, height: 0.95), cellSpace: 0, lineSpace: 8, layoutImageName: "square"))
        case .square:
            currCellLayout = .squares
            return Observable.of(CellLayout(cellLayoutType: .squares, cellScale: CGSize(width: 0.5, height: 0.5), cellSpace: 2, lineSpace: 2, layoutImageName: "squares"))
        case .squares:
            currCellLayout = .list
            return Observable.of(CellLayout(cellLayoutType: .list, cellScale: CGSize(width: 0.90, height: 0.25), cellSpace: 0, lineSpace: 8, layoutImageName: "list"))
        }
    }
    
    
    // MARK: -------------- unit-test functions --------------
    public func utRefreshSubFilters(filterId: Int){
        subFiltersFromCache(filterId: filterId)
    }
    
    public func utEnterSubFilter(filterId: Int){
        requestSubFilters(filterId: filterId)
    }

    
    internal func subFiltersFromCache(filterId: Int){
        
        guard let filter = filters[filterId] else {return}
        
        switch filter.filterEnum {
        case .select:
            //var res = [SubfilterModel?]()
            var res = [SubfilterModel]()
            if let ids = self.subfiltersByFilter[filterId] {
                res = self.getEnabledSubFilters(ids: ids)
            }
            self.outSubFiltersEvent.onNext(res.sorted(by: {$0.id < $1.id}))
        case .section:
            fillSectionSubFilters()
            if let sections = sectionSubFiltersByFilter[filterId] {
                self.outSectionSubFiltersEvent.onNext(sections)
            }
        default:
            print("todo")
        }
        unitTestSignalOperationComplete.onNext(utMsgId)
    }
    
    internal func resetFilters(){
        cleanupAllFilters()
        itemIds = fullCatalogItemIds
        setupFetch(itemIds: fullCatalogItemIds)
        outReloadCatalogVC.onNext(true)
        print("resetFilters")
        emitPrefetchEvent()
        outFiltersEvent.onNext(self.getEnabledFilters())
        unitTestSignalOperationComplete.onNext(utMsgId)
    }
    
    internal func selectSubFilter(subFilterId: Int, selected: Bool) {
        
        if appliedSubFilters.contains(subFilterId) ||
            midAppliedSubFilters.contains(subFilterId) {
            
            if selected == false {
                unapplying.insert(subFilterId)
            } else {
                unapplying.remove(subFilterId)
            }
        }
        if selected {
            selectedSubFilters.insert(subFilterId)
        } else {
            selectedSubFilters.remove(subFilterId)
        }
        self.showApplyingView(subFilterId: subFilterId, isSelectNow: selected)
    }
    
    
    private func showApplyingView(subFilterId: Int, isSelectNow: Bool){
        
        guard let filterId = subFilters[subFilterId]?.filterId else {return}
        guard let arr = subfiltersByFilter[filterId] else {return}
        
        outShowApplyViewEvent.onNext(true)
        
        let subfilters = Set(arr)
        
        let selected = self.selectedSubFilters.intersection(subfilters)
        
        let notAppliedButSelected = selected.subtracting(midAppliedSubFilters)
        
        if notAppliedButSelected.count > 0 {
            canApplyFromSubfilter = true
            return
        }

        if isSelectNow && midAppliedSubFilters.contains(subFilterId) {
            canApplyFromSubfilter = false
            return
        }
        
       if isSelectNow == false && midAppliedSubFilters.contains(subFilterId) {
            canApplyFromSubfilter = true
            return
        }
        
        let unapl = unapplying.intersection(subfilters)
        if unapl.count > 0 {
             canApplyFromSubfilter = true
            return
        }
        
        if isSelectNow {
            canApplyFromSubfilter = true
            return
        }
        
        canApplyFromSubfilter = false
    }
    
    
    private func showPriceApplyView(){
        outShowPriceApplyViewEvent.onNext(true)
    }
    
    
    internal func cleanupFilterVC(){
       self.outFiltersEvent.onNext([])
    }
    
    
    internal func showCleanSubFilterVC(filterId : Int){
        self.outSubFiltersEvent.onNext([])
        self.outSectionSubFiltersEvent.onNext([])
        // signal-ready to show vc
        self.outRequestComplete.onNext(filterId)
    }
    

    internal func fillSectionSubFilters(){
        sectionSubFiltersByFilter.removeAll()
        
        var tmp = [String:[SubfilterModel]]()
        var tmp2 = [SectionOfSubFilterModel]()
        let sectionFilters = filters
                                .values
                                .filter({$0.filterEnum == .section})
        
        for filter in sectionFilters {
            tmp.removeAll()
            tmp2.removeAll()
            guard let ids = subfiltersByFilter[filter.id]  else { continue }
            
            
            for id in ids {
                guard let subf = subFilters[id],
                      subf.enabled == true
                      else { continue }
                
                if tmp[subf.sectionHeader] == nil {
                    tmp[subf.sectionHeader]  = []
                }
                tmp[subf.sectionHeader]?.append(subf)
            }
            for t in tmp {
                tmp2.append(SectionOfSubFilterModel(header: t.key, items: t.value))
            }
            sectionSubFiltersByFilter[filter.id] = tmp2
        }
    }
    
    
    //internal func getEnabledSubFilters(ids: [Int]) -> [SubfilterModel?] {
    internal func getEnabledSubFilters(ids: [Int]) -> [SubfilterModel] {
        let res = ids
            .compactMap({subFilters[$0]})
            .filter({$0.enabled == true})
        return res
    }
    
    
    internal func enableSubFilters(ids: [Int?], countBySubfilterId: [Int: Int] = [:]) {
        
        for subf in subFilters {
            subf.value.enabled = false
        }
        
        for id in ids {
            if let i = id,
            let subf = subFilters[i] {
                if let cnt = countBySubfilterId[i] {
                    subf.countItems = cnt
                }
                subf.enabled = true
            }
        }
    }
    
    
    internal func getEnabledFilters()->[FilterModel?] {
        return filters
            .compactMap({$0.value})
            .filter({$0.enabled == true})
            .sorted(by: {$0.id < $1.id })
    }
    
    internal func enableFilters(ids: [Int?]) {
        
        for subf in filters.filter({$0.value.filterEnum != FilterEnum.range}) {
            subf.value.enabled = false
        }
        
        for id in ids {
            if let i = id,
                let subf = filters[i] {
                subf.enabled = true
            }
        }
    }
    
    
    public func cleanupUnapplied(){
        unapplying = []
        midAppliedSubFilters = []
        selectedSubFilters = []
    }
    
    private func cleanupAllFilters(){
        for filter in filters {
            filter.value.enabled = true
        }
        for subf in subFilters {
            subf.value.enabled = true
        }
        unapplying = []
        midAppliedSubFilters = []
        appliedSubFilters = []
        selectedSubFilters = []
    }
}
