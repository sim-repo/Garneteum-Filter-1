import UIKit
import RxSwift



protocol NetworkFacadeProtocol {

    func reqPrefetch(itemIds: ItemIds, completion: (([CatalogModel1], NetError?)->Void)?)

    func reqLoadCrossFilters(filterId: Int, completion: (([FilterModel],[SubfilterModel])->Void)? )

    func reqLoadUIDs(completion: (([UidModel])->Void)?)

    func reqLoadCategoryFilters(categoryId: CategoryId, completion: (([FilterModel],[SubfilterModel])->Void)? )

    func reqLoadCategoryApply(categoryId: CategoryId, completion: ((SubfiltersByItem?, PriceByItemId?)->Void)? )
    
    func reqCatalogStart(categoryId: CategoryId, completion: ((CategoryId, Int, ItemIds, Int, Int)->Void)? )
}



class NetworkFacadeBase: NetworkFacadeProtocol {
    
    public init(){
        setupOperationQueue()
    }
    
    internal var outNetworkError = PublishSubject<FilterActionEnum>()

    internal var operationQueues: [Int: OperationQueue] = [:]
    
    enum NetTasksEnum: Int {
        case crossUIDs = 0, crossFilters, categoryFilters, categoryApply, catalogStart, catalogPrefetch
    }
    
    enum NetTaskStatusEnum: Int {
        case requestLimitAchieved = 0, rerunAfterError, success
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

    func reqLoadCrossFilters(filterId: Int, completion: (([FilterModel],[SubfilterModel])->Void)? ) {}

    func reqLoadUIDs(completion: (([UidModel])->Void)?){}

    func reqLoadCategoryFilters(categoryId: CategoryId, completion: (([FilterModel],[SubfilterModel])->Void)? ) { }

    func reqLoadCategoryApply(categoryId: CategoryId, completion: ((SubfiltersByItem?, PriceByItemId?)->Void)? ) {}
 

}
