import UIKit
import RxSwift
import CoreData


protocol DataFacadeProtocol {
    
    func screenHandle(dataTaskEnum: DataTasksEnum, _ categoryId: CategoryId, _ itemsIds: Set<Int>)
    func screenHandle(dataTaskEnum: DataTasksEnum, _ categoryId: CategoryId)
    func screenHandle(dataTaskEnum: DataTasksEnum)
    
    func getFilters() -> BehaviorSubject<[FilterModel]>
    func getCrossFilters() -> ReplaySubject<[FilterModel]>
    func getCrossSubfilters() -> ReplaySubject<[SubfilterModel]>
    func getCategorySubfilters() -> BehaviorSubject<[SubfilterModel]>
    
    func getApplyForItemsEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)>
    func getApplyForFiltersEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, MinPrice, MaxPrice, ItemsTotal)>
    func getApplyByPriceEvent() -> PublishSubject<FilterIds>
    

    func reqEnterSubFilter(filterId: FilterId, applied: Applied, rangePrice: RangePrice)
    func getEnterSubFilterEvent() -> PublishSubject<(FilterId, SubFilterIds, Applied, CountItems)>
    
    func reqApplyFromFilter(categoryId: CategoryId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    func reqApplyFromSubFilter(categoryId: CategoryId, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    func reqApplyByPrices(categoryId: CategoryId, rangePrice: RangePrice)
    func reqRemoveFilter(categoryId: CategoryId, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    
    func getMidTotal() -> PublishSubject<Int>
    func reqMidTotal(categoryId: CategoryId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    
    func getCatalogTotalEvent() -> BehaviorSubject<(CategoryId, ItemIds, Int, MinPrice, MaxPrice)>
    func getPrefetchEvent() -> PublishSubject<[CatalogModel]>
    func getNetError() -> PublishSubject<NetError>
    
    func resetBehaviorSubjects()
}



class DataService: DataFacadeProtocol {
   
    internal init(){
        setupOperationQueue()
    }
    
    public static var shared = DataService()
    
    internal var operationQueues: [Int: OperationQueue] = [:]
   
    internal var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    internal var subfilters: [SubfilterModel] = []
    
    let applyLogic: FilterApplyLogic = FilterApplyLogic.shared
    
    internal var outFilters = BehaviorSubject<[FilterModel]>(value: [])
    internal var outCrossFilters = ReplaySubject<[FilterModel]>.create(bufferSize: 2)
    internal var outCrossSubfilters = ReplaySubject<[SubfilterModel]>.create(bufferSize: 2)
    internal var outCategorySubfilters = BehaviorSubject<[SubfilterModel]>(value: [])
    internal var outEnterSubFilter = PublishSubject<(FilterId, SubFilterIds, Applied, CountItems)>()
    internal var outApplyItemsResponse = PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)>()
    internal var outApplyFiltersResponse = PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, MinPrice, MaxPrice, ItemsTotal)>()
    internal var outApplyByPrices = PublishSubject<FilterIds>()
    internal var outTotals = PublishSubject<Int>()
    internal var outPrefetch = PublishSubject<[CatalogModel]>()
    internal var outCatalogTotal = BehaviorSubject<(CategoryId, ItemIds, Int, MinPrice, MaxPrice)>(value: (0,[],20, 0, 0))
    internal var outNetError = PublishSubject<NetError>()
    internal let networkService = getNetworkService()
    
    
    
    
    func screenHandle(dataTaskEnum: DataTasksEnum) {
        
        switch dataTaskEnum {
            case .didStartApplication:
                operationQueues[DataTasksEnum.didStartApplication.rawValue]?.addOperation { [weak self] in
                    self?.loadNewUIDs()
                }
                break
            default:
                print("screenHandle: no handlers found for value '\(dataTaskEnum)'")
        }
    }
    
    
    
    func screenHandle(dataTaskEnum: DataTasksEnum, _ categoryId: CategoryId) {
        
        switch dataTaskEnum {
            case .willCatalogShow:
                operationQueues[DataTasksEnum.willCatalogShow.rawValue]?.addOperation { [weak self] in
                    self?.doEmitCategoryAllFilters(categoryId)
                }
                break
            
            case .willStartPrefetch:
                operationQueues[DataTasksEnum.willStartPrefetch.rawValue]?.addOperation { [weak self] in
                    self?.doEmitCatalogStart(categoryId)
                }
                break
            
            default:
                print("screenHandle: no handlers found for value '\(dataTaskEnum)'")
        }
    }
    
    
    
    func screenHandle(dataTaskEnum: DataTasksEnum, _ categoryId: CategoryId, _ itemsIds: Set<Int>) {
        
        switch dataTaskEnum {
            case .willPrefetch:
                operationQueues[DataTasksEnum.willPrefetch.rawValue]?.addOperation { [weak self] in
                    self?.doEmitPrefetch(categoryId: categoryId, itemIds: itemsIds)
                }
                break
            
            default:
                print("screenHandle: no handlers found for value '\(dataTaskEnum)'")
        }
    }
    
    
    
    private func setupOperationQueue(){
        addOperation(dataTasksEnum: .didStartApplication)
        addOperation(dataTasksEnum: .willCatalogShow)
        addOperation(dataTasksEnum: .willStartPrefetch)
        addOperation(dataTasksEnum: .willPrefetch)
    }
    
    
    
    private func addOperation(dataTasksEnum: DataTasksEnum) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        operationQueues[dataTasksEnum.rawValue] = queue
    }
    
    
    
    func resetBehaviorSubjects() {
        outFilters.onNext([])
        outCategorySubfilters.onNext([])
    }
    
    
    
    func getNetError() -> PublishSubject<NetError> {
        return outNetError
    }
    
    
    
    func getFilters() -> BehaviorSubject<[FilterModel]> {
        return outFilters
    }
    
    
    
    func getCrossFilters() -> ReplaySubject<[FilterModel]>{
        return outCrossFilters
    }
    
    
    
    func getCrossSubfilters() -> ReplaySubject<[SubfilterModel]> {
        return outCrossSubfilters
    }
    
    
    
    func getCategorySubfilters() -> BehaviorSubject<[SubfilterModel]> {
        return outCategorySubfilters
    }

    
    
    func reqEnterSubFilter(filterId: FilterId, applied: Applied, rangePrice: RangePrice) {
        
        applyLogic.doLoadSubFilters(filterId, applied, rangePrice)
            .asObservable()
            .subscribe(onNext: {[weak self] res in
                let filterId = res.0
                let subfiltersIds = res.1
                let applied = res.2
                let countsItems = res.3
                self?.outEnterSubFilter.onNext((filterId, subfiltersIds, applied, countsItems))
            })
            .disposed(by: bag)
    }
    
    
    
    func getEnterSubFilterEvent() -> PublishSubject<(FilterId, SubFilterIds, Applied, CountItems)> {
        return outEnterSubFilter
    }

    
    
    internal func dbDeleteData(_ entity:String) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.includesPendingChanges = false
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try appDelegate.moc.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else { continue }
                appDelegate.moc.delete(objectData)
                appDelegate.saveContext()
            }
            
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
}



extension DataService {
    
    internal func emitCrossFilters(sql: String){
        
        if let filtersDB = dbLoadFilter(sql: sql) {
            let filters = filtersDB.compactMap({$0.getFilterModel()})
            self.applyLogic.setup(filters_: filters)
            self.outCrossFilters.onNext(filters)
        }
    }
    
    
    
    internal func doEmitCrossSubfilters(sql: String){
        
        if let subfiltersDB = dbLoadSubfilter(sql: sql) {
            let subfilters = subfiltersDB.compactMap({$0.getSubfilterModel()})
            self.applyLogic.setup(subFilters_: subfilters)
            self.outCrossSubfilters.onNext(subfilters)
        }
    }
    
    
    
    internal func emitCategoryFilters(sql: String){
        
        if let filtersDB = dbLoadFilter(sql: sql) {
            let filters = filtersDB.compactMap({$0.getFilterModel()})
            self.applyLogic.setup(filters_: filters)
            self.outFilters.onNext(filters)
        }
    }
    
    
    
    internal func emitCategorySubfilters(sql: String){
        
        if let subfiltersDB = dbLoadSubfilter(sql: sql) {
            let subfilters = subfiltersDB.compactMap({$0.getSubfilterModel()})
            self.applyLogic.setup(subFilters_: subfilters)
            self.outCategorySubfilters.onNext(subfilters)
        }
    }
    
    
    
    internal func setupApplyFromDB(sql: String){
        
        if let subfiltersItemsDB = dbLoadSubfiltersItems(sql: sql) {
            let (subfiltersByItem, itemsBySubfilter) = SubfilterItemPersistent.getApplyData(subfiltersItemPersistent: subfiltersItemsDB)
            self.applyLogic.setup(subfiltersByItem_: subfiltersByItem)
            self.applyLogic.setup(itemsBySubfilter_: itemsBySubfilter)
        }
        if let priceByItemDB = dbLoadPriceByItem(sql: sql) {
            let priceByItem = PriceByItemPersistent.getPriceByItem(priceByItemPersistent: priceByItemDB)
            self.applyLogic.setup(priceByItemId_: priceByItem)
        }
    }
    
    
    internal func dbLoadFilter(sql: String) -> [FilterPersistent]? {
        
        var db: [FilterPersistent]?
        let request: NSFetchRequest<FilterPersistent> = FilterPersistent.fetchRequest()
        request.includesPendingChanges = false
        request.predicate = NSPredicate(format: sql)
        do {
            db = try appDelegate.moc.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return db
    }
}
