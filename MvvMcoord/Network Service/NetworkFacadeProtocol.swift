import UIKit
import RxSwift



protocol NetworkFacadeProtocol {

    func reqPrefetch(itemIds: ItemIds, completion: (([CatalogModel1], NetError?)->Void)?, midCompletion: ((NetError, Int)->Void)?)

    func reqLoadCrossFilters(filterId: Int, completion: (([FilterModel],[SubfilterModel], NetError?)->Void)? )

    func reqLoadUIDs(completion: (([UidModel], NetError?)->Void)?)

    func reqLoadCategoryFilters(categoryId: CategoryId, completion: (([FilterModel],[SubfilterModel], NetError?)->Void)? )

    func reqLoadCategoryApply(categoryId: CategoryId, completion: ((SubfiltersByItem?, PriceByItemId?, NetError?)->Void)? )
    
    func reqCatalogStart(categoryId: CategoryId, completion: ((CategoryId, Int, ItemIds, Int, Int, NetError?)->Void)? )
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
    
    
    func reqCatalogStart(categoryId: CategoryId, completion: ((CategoryId, Int, ItemIds, Int, Int, NetError?)->Void)? ) {}

    func reqPrefetch(itemIds: ItemIds, completion: (([CatalogModel1], NetError?)->Void)?, midCompletion: ((NetError, Int)->Void)?) {}

    func reqLoadCrossFilters(filterId: Int, completion: (([FilterModel],[SubfilterModel], NetError?)->Void)? ) {}

    func reqLoadUIDs(completion: (([UidModel], NetError?)->Void)?) {}

    func reqLoadCategoryFilters(categoryId: CategoryId, completion: (([FilterModel],[SubfilterModel], NetError?)->Void)? ) {}

    func reqLoadCategoryApply(categoryId: CategoryId, completion: ((SubfiltersByItem?, PriceByItemId?, NetError?)->Void)? ) {}
 

}
