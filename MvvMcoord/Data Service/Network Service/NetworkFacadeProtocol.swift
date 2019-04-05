import UIKit
import RxSwift



protocol NetworkFacadeProtocol {

    func reqPrefetch(itemIds: ItemIds, completion: (([CatalogModel1], NetError?)->Void)?)
    
    func reqFullFilterEntities(categoryId: CategoryId)
    
    func reqEnterSubFilter(filterId: FilterId, appliedSubFilters: Applied, rangePrice: RangePrice)
    
    func reqApplyFromFilter(categoryId: CategoryId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    
    func reqApplyFromSubFilter(categoryId: CategoryId, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    
    func reqApplyByPrices(categoryId: CategoryId, rangePrice: RangePrice)
    
    func reqRemoveFilter(categoryId: CategoryId, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    
    func reqPreloadFullFilterEntities(categoryId: CategoryId)
    
    func reqPreloadFiltersChunk1(categoryId: CategoryId)
    
    func reqPreloadSubFiltersChunk2(categoryId: CategoryId)
    
    func reqPreloadItemsChunk3(categoryId: CategoryId)
    
    func reqPreloadSinglesChunk4(filterId: FilterId, uuid: String)
    
    func reqPreloadSinglesChunk5(filterId: FilterId, uuid: String)
    
    func reqMidTotal(categoryId: CategoryId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    
    func reqLoadCrossSubfilters(filterId: FilterId, uuid: String, completion: (([SubfilterModel])->Void)?)
    
    func reqLoadCrossFilters(filterId: Int, completion: (([FilterModel],[SubfilterModel])->Void)? )
    
    func reqLoadUIDs(completion: (([UidModel])->Void)?)
    
    func reqLoadCategoryFilters(categoryId: CategoryId, completion: (([FilterModel],[SubfilterModel])->Void)? )
    
    func reqLoadCategoryApply(categoryId: CategoryId, completion: ((SubfiltersByItem?, PriceByItemId?)->Void)? )
    
    func reqCatalogStart(categoryId: CategoryId, completion: ((CategoryId, Int, ItemIds, Int, Int)->Void)? )
    
    
    
    
    func getFullFilterEntitiesEvent() -> BehaviorSubject<([FilterModel], [SubfilterModel])>
    
    func getEnterSubFilterEvent() -> PublishSubject<(FilterId, SubFilterIds, Applied, CountItems)>
    
    func getApplyForItemsEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)>
    
    func getApplyForFiltersEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, MinPrice, MaxPrice, ItemsTotal)>
    
    func getApplyByPriceEvent() -> PublishSubject<FilterIds>
    
    func getCatalogTotalEvent() -> BehaviorSubject<(CategoryId, ItemIds, Int, MinPrice, MaxPrice)>
    
    func getCatalogModelEvent() -> PublishSubject<[CatalogModel?]>
    
    func getFilterChunk1() -> BehaviorSubject<[FilterModel]>
    
    func getSubFilterChunk2() -> BehaviorSubject<[SubfilterModel]>
    
    func getMidTotal() -> PublishSubject<ItemsTotal>
    
    func getDownloadsDoneEvent()-> PublishSubject<Void>
    
    func getNetworkErrorEvent() -> PublishSubject<FilterActionEnum>
    
    func resetNetworkBehaviorSubjects()
    
}



class NetworkFacadeBase: NetworkFacadeProtocol {
    
    public init(){
        setupDownload()
        setupOperationQueue()
    }
    
    internal var outFilterEntitiesResponse = BehaviorSubject<([FilterModel], [SubfilterModel])>(value: ([],[]))
    internal var outEnterSubFilterResponse = PublishSubject<(FilterId, SubFilterIds, Applied, CountItems)>()
    internal var outApplyItemsResponse = PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)>()
    internal var outApplyFiltersResponse = PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, MinPrice, MaxPrice, ItemsTotal)>()
    internal var outApplyByPrices = PublishSubject<FilterIds>()
    internal var outCatalogTotal = BehaviorSubject<(CategoryId, ItemIds, Int, MinPrice, MaxPrice)>(value: (0,[],20, 0, 0))
    internal var outCatalogModel = PublishSubject<[CatalogModel?]>()
    
    internal var outFilterChunk1 = BehaviorSubject<[FilterModel]>(value: [])
    internal var outSubFilterChunk2 = BehaviorSubject<[SubfilterModel]>(value: [])
    internal var outTotals = PublishSubject<Int>()
    
    internal var outNetworkError = PublishSubject<FilterActionEnum>()
    
    
    internal var didDownloadChunk1 = PublishSubject<Void>()
    internal var didDownloadChunk2 = PublishSubject<Void>()
    internal var didDownloadChunk31 = PublishSubject<Void>()
    internal var didDownloadChunk32 = PublishSubject<Void>()
    internal var didDownloadChunk33 = PublishSubject<Void>()
    internal var didDownloadChunk4 = PublishSubject<Void>()
    internal var didDownloadChunk5 = PublishSubject<Void>()
    internal var outDownloadsDone = PublishSubject<Void>()
    
    
    
    var didDownloadComplete: Observable<Void>?
    
    internal var operationQueues: [Int: OperationQueue] = [:]
    
    enum NetTasksEnum: Int {
        case crossUIDs = 0, crossFilters, categoryFilters, categoryApply, catalogStart, catalogPrefetch
    }
    
    enum NetTaskStatusEnum: Int {
        case requestLimitAchieved = 0, rerunAfterError, success
    }
    
    
    private func setupDownload(){
        let didDownloadComplete = Observable.combineLatest(didDownloadChunk1,
                                                           didDownloadChunk2,
                                                           didDownloadChunk31,
                                                           didDownloadChunk32,
                                                           didDownloadChunk33,
                                                           didDownloadChunk4,
                                                           didDownloadChunk5,
                                                           resultSelector:{
            didDownloadChunk1, didDownloadChunk2, didDownloadChunk31, didDownloadChunk32, didDownloadChunk33, didDownloadChunk4, didDownloadChunk5 in
            "okey!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        })
        
        didDownloadComplete.subscribe(onNext: {[weak self] value in
            self?.outDownloadsDone.onNext(Void())
        })
        .disposed(by: bag)
    }
    
    
    
    private func setupOperationQueue(){
        addOperation(newTaskEnum: NetTasksEnum.crossUIDs)
        addOperation(newTaskEnum: NetTasksEnum.crossFilters)
        addOperation(newTaskEnum: NetTasksEnum.categoryFilters)
        addOperation(newTaskEnum: NetTasksEnum.categoryApply)
        addOperation(newTaskEnum: NetTasksEnum.catalogStart)
        addOperation(newTaskEnum: NetTasksEnum.catalogPrefetch)
    }
    
    private func addOperation(newTaskEnum: NetTasksEnum) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        operationQueues[newTaskEnum.rawValue] = queue
    }
    
    
   
    func reqCatalogStart(categoryId: CategoryId, completion: ((CategoryId, Int, ItemIds, Int, Int)->Void)? ) {}
    
    func reqPrefetch(itemIds: ItemIds, completion: (([CatalogModel1], NetError?)->Void)?) {}
    
    func reqFullFilterEntities(categoryId: CategoryId) {}
    
    func reqEnterSubFilter(filterId: FilterId, appliedSubFilters: Applied, rangePrice: RangePrice) {}
    
    func reqApplyFromFilter(categoryId: CategoryId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {}
    
    func reqApplyFromSubFilter(categoryId: CategoryId, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {}
    
    func reqApplyByPrices(categoryId: CategoryId, rangePrice: RangePrice) {}
    
    func reqRemoveFilter(categoryId: CategoryId, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {}
    
    func reqPreloadFullFilterEntities(categoryId: CategoryId) {}
    
    func reqPreloadFiltersChunk1(categoryId: CategoryId) {}
    
    func reqPreloadSubFiltersChunk2(categoryId: CategoryId) {}
    
    func reqPreloadItemsChunk3(categoryId: CategoryId) {}
    
    func reqPreloadSinglesChunk4(filterId: FilterId, uuid: String) {}
    
    func reqPreloadSinglesChunk5(filterId: FilterId, uuid: String) {}
    
    func reqMidTotal(categoryId: CategoryId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {}
    
    
    func reqLoadCrossSubfilters(filterId: FilterId, uuid: String, completion: (([SubfilterModel])->Void)?) {}
    
    func reqLoadCrossFilters(filterId: Int, completion: (([FilterModel],[SubfilterModel])->Void)? ) {}
    
    func reqLoadUIDs(completion: (([UidModel])->Void)?){}
    
    func reqLoadCategoryFilters(categoryId: CategoryId, completion: (([FilterModel],[SubfilterModel])->Void)? ) { }
   
    func reqLoadCategoryApply(categoryId: CategoryId, completion: ((SubfiltersByItem?, PriceByItemId?)->Void)? ) {}
    
    
    func getFullFilterEntitiesEvent() -> BehaviorSubject<([FilterModel], [SubfilterModel])> {
        return outFilterEntitiesResponse
    }
    
    func getEnterSubFilterEvent() -> PublishSubject<(FilterId, SubFilterIds, Applied, CountItems)>{
        return outEnterSubFilterResponse
    }
    
    func getApplyForItemsEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)> {
        return outApplyItemsResponse
    }
    
    func getApplyForFiltersEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, MinPrice, MaxPrice, ItemsTotal)> {
        return outApplyFiltersResponse
    }
    
    func getApplyByPriceEvent() -> PublishSubject<FilterIds> {
        return outApplyByPrices
    }
    
    func getCatalogTotalEvent() -> BehaviorSubject<(CategoryId, ItemIds, Int, MinPrice, MaxPrice)> {
        return outCatalogTotal
    }
    
    func getCatalogModelEvent() -> PublishSubject<[CatalogModel?]> {
        return outCatalogModel
    }
    
    func getFilterChunk1() -> BehaviorSubject<[FilterModel]> {
        return outFilterChunk1
    }
    
    func getSubFilterChunk2() -> BehaviorSubject<[SubfilterModel]> {
        return outSubFilterChunk2
    }
    
    func getMidTotal() -> PublishSubject<Int> {
        return outTotals
    }
    
    func getDownloadsDoneEvent()-> PublishSubject<Void> {
        return outDownloadsDone
    }
    
    func getNetworkErrorEvent() -> PublishSubject<FilterActionEnum> {
        return outNetworkError
    }
    
    func resetNetworkBehaviorSubjects() {
        getFilterChunk1().onNext([])
        getSubFilterChunk2().onNext([])
    }
    
    
    internal func fireFullFilterEntities(_ filterModels: [FilterModel], _ subFilterModels: [SubfilterModel]) {
        outFilterEntitiesResponse.onNext((filterModels, subFilterModels))
    }
    
    internal func fireEnterSubFilter(_ filterId: FilterId, _ subFiltersIds: SubFilterIds, _ appliedSubFilters: Applied, _ cntBySubfilterId: CountItems) {
        outEnterSubFilterResponse.onNext((filterId, subFiltersIds, appliedSubFilters, cntBySubfilterId))
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
    
    internal func fireCatalogModel(catalogModel:[CatalogModel?]) {
        outCatalogModel.onNext(catalogModel)
    }
    
    internal func fireCatalogTotal(_ categoryId: CategoryId ,_ itemIds: ItemIds, _ fetchLimit: Int, _ minPrice: MinPrice, _ maxPrice: MaxPrice) {
        outCatalogTotal.onNext((categoryId, itemIds, fetchLimit, minPrice, maxPrice))
    }
    
    internal func fireFilterChunk1(_ filterModel: [FilterModel]){
        outFilterChunk1.onNext(filterModel)
    }
    
    internal func fireFilterChunk2(_ subfilterModel: [SubfilterModel]){
        outSubFilterChunk2.onNext(subfilterModel)
    }
    
    internal func fireMidTotal(_ total: Int) {
        outTotals.onNext(total)
    }
    
    internal func fireNetworkError(errorType: FilterActionEnum){
        outNetworkError.onNext(errorType)
    }

}
