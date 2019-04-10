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
    
    let controlActiveTasks = DispatchQueue(label: "", attributes: .concurrent)

    public init(){
        setupOperationQueue()
    }
    
    internal var outNetworkError = PublishSubject<FilterActionEnum>()

    internal var operationQueuesDict: [Int: OperationQueue] = [:]
    
    typealias Completion = (() -> Void)?
    
    var activeTasks: [Int: Completion] = [:]
    
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
    
    internal func asyncWriteTask(taskIdx : Int, closure: Completion) {
        controlActiveTasks.async(flags: .barrier) {
            self.activeTasks[taskIdx] = closure
        }
    }
    
    internal func syncRunTask(taskIdx : Int){
        controlActiveTasks.sync {
            guard let task = activeTasks[taskIdx] else { return }
            task?()
        }
    }
    
    private func addOperation(newTaskEnum: NetTasksEnum) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        operationQueuesDict[newTaskEnum.rawValue] = queue
    }
    
    
    func reqCatalogStart(categoryId: CategoryId, completion: ((CategoryId, Int, ItemIds, Int, Int, NetError?)->Void)? ) {}

    func reqPrefetch(itemIds: ItemIds, completion: (([CatalogModel1], NetError?)->Void)?, midCompletion: ((NetError, Int)->Void)?) {}

    func reqLoadCrossFilters(filterId: Int, completion: (([FilterModel],[SubfilterModel], NetError?)->Void)? ) {}

    func reqLoadUIDs(completion: (([UidModel], NetError?)->Void)?) {}

    func reqLoadCategoryFilters(categoryId: CategoryId, completion: (([FilterModel],[SubfilterModel], NetError?)->Void)? ) {}

    func reqLoadCategoryApply(categoryId: CategoryId, completion: ((SubfiltersByItem?, PriceByItemId?, NetError?)->Void)? ) {}
 

}
