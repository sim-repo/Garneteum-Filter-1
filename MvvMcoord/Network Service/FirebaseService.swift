import Foundation
import SwiftyJSON
import RxSwift
import Firebase
import FirebaseDatabase
import FirebaseFunctions

var functions = Functions.functions()

class FirebaseService : NetworkFacadeBase {
    
    private override init(){
        super.init()
    }
    
    public static var shared = FirebaseService()
    
    var taskNo: Int = 0
    var activeTasks: [Int: Completion] = [:]
    
    let applyLogic: FilterApplyLogic = FilterApplyLogic.shared
    
    typealias Completion = (() -> Void)?
    
    private var reqTry: [Int:Int] = [:]
    private let limitTry = 3

    
    private func showTime() -> String{
        let now = Date()
        
        let formatter = DateFormatter()
        
        formatter.timeZone = TimeZone.current
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm.ss.SSSZ"
        
        let dateString = formatter.string(from: now)
        return dateString
    }
    
   
    private func reRunTask(task: Completion, taskId: Int, error: NSError, delay: Int = 0){
        
        if let tryno = reqTry[taskId] {
            reqTry[taskId] = tryno + 1
        } else {
            reqTry[taskId] = 1
        }
        
        let period = delay == 0 ? 2 : delay
        
        if error.domain == FunctionsErrorDomain {
            let code = FunctionsErrorCode(rawValue: error.code)
            let message = error.localizedDescription
            let details = error.userInfo[FunctionsErrorDetailsKey]
            
          //  if code == FunctionsErrorCode.resourceExhausted {
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(period), qos: .background) {
                task?()
            }
            print("error:\(String(describing: code)) : \(message) : \(String(describing: details))")
        }
    }
    
    
    override func reqLoadUIDs(completion: (([UidModel])->Void)?) {
        print("NETWORK: reqLoadUIDs")
        taskNo += 1
        runCheckUUIDS(taskCode: NetTasksEnum.crossUIDs.rawValue, taskIdx: taskNo, completion: completion)
    }
    
    override func reqLoadCrossFilters(filterId: Int, completion: (([FilterModel],[SubfilterModel])->Void)? ) {
        print("NETWORK: reqLoadCrossFilters")
        taskNo += 1
        runCrossFilters(taskCode: NetTasksEnum.crossFilters.rawValue, taskIdx: taskNo, filterId: filterId, completion: completion)
    }
    
    override func reqLoadCategoryFilters(categoryId: CategoryId, completion: (([FilterModel],[SubfilterModel])->Void)? ) {
        print("NETWORK: reqLoadCategoryFilters")
        taskNo += 1
        runCategoryFilters(taskCode: NetTasksEnum.categoryFilters.rawValue, taskIdx: taskNo, categoryId: categoryId, completion: completion)
    }
    
    override func reqLoadCategoryApply(categoryId: CategoryId, completion: ((SubfiltersByItem?, PriceByItemId?)->Void)? ) {
        print("NETWORK: reqLoadCategoryApply")
        taskNo += 1
        runCategoryApply(taskCode: NetTasksEnum.categoryApply.rawValue, taskIdx: taskNo, categoryId: categoryId, completion: completion)
    }
    
    override func reqCatalogStart(categoryId: CategoryId, completion: ((CategoryId, Int, ItemIds, Int, Int)->Void)? ) {
        print("NETWORK: reqCatalogStart")
        taskNo += 1
        runCatalogStart(taskCode: NetTasksEnum.catalogStart.rawValue, taskIdx: taskNo, categoryId: categoryId, completion: completion)
    }

    override func reqPrefetch(itemIds: ItemIds, completion: (([CatalogModel1], NetError?)->Void)?) {
        print("NETWORK: reqPrefetch")
        taskNo += 1
        runPrefetch(taskCode: NetTasksEnum.catalogPrefetch.rawValue, taskIdx: taskNo, itemIds: itemIds, completion: completion)
    }
    
    private func checkedReqLimit(taskIdx: Int, error: Error?) -> NetTaskStatusEnum {
        if let err = error as NSError? {
            let cnt = self.reqTry[taskIdx] ?? 0
            if cnt < self.limitTry,
                let completion = self.activeTasks[taskIdx] {
                self.reRunTask(task: completion, taskId: taskIdx, error: err)
                return .rerunAfterError
            } else {
                self.reqTry[taskIdx] = 0
                self.activeTasks[taskIdx] = nil
                return .requestLimitAchieved
            }
        }
        return .success
    }
    
}



// MARK: -run task functions
extension FirebaseService  {
    
    
    private func runCheckUUIDS(taskCode: Int, taskIdx: Int, completion: (([UidModel])->Void)?) {
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["method":"getUIDs"]) { [weak self] (result, error) in
                DispatchQueue.global(qos: .userInteractive).async {
                    guard let `self` = self else { return }
                    let ret = self.checkedReqLimit(taskIdx: taskIdx, error: error)
                    switch ret {
                        case .success: break
                        case .rerunAfterError: return
                        case .requestLimitAchieved: return
                    }
                  
                    let uuidModels: [UidModel] = ParsingHelper.parseUUIDModel(result: result, key: "uids")
                    completion?(uuidModels)
                    self.activeTasks[taskIdx] = nil
                }
            }
        }
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
    
    
    private func runCrossFilters(taskCode: Int, taskIdx: Int, filterId: Int, completion: (([FilterModel],[SubfilterModel])->Void)? ) {
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["useCache":true, "filterId": filterId,  "method":"getCrossChunk4"]) { [weak self] (result, error) in
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let `self` = self else { return }
                    let ret = self.checkedReqLimit(taskIdx: taskIdx, error: error)
                    switch ret {
                        case .success: break
                        case .rerunAfterError: return
                        case .requestLimitAchieved: return
                    }
                    
                    let filters:[FilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "filter")
                    let subFilters:[SubfilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "subFilters")
                    completion?(filters, subFilters)
                    self.activeTasks[taskIdx] = nil
                }
            }
        }
        
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
    
    

    
    private func runCategoryFilters(taskCode: Int, taskIdx: Int, categoryId: CategoryId, completion: (([FilterModel], [SubfilterModel])->Void)? ){
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["useCache":true,
                                                  "categoryId": categoryId,
                                                  "method":"getCategoryFiltersChunk5"]) { [weak self] (result, error) in
                
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let `self` = self else { return }
                    let ret = self.checkedReqLimit(taskIdx: taskIdx, error: error)
                    switch ret {
                        case .success: break
                        case .rerunAfterError: return
                        case .requestLimitAchieved: return
                    }
                    let filters:[FilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "filters")
                    let subFilters:[SubfilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "subFilters")
                    completion?(filters, subFilters)
                    self.activeTasks[taskIdx] = nil
                }
            }
        }
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
    
    
    
    private func runCategoryApply(taskCode: Int, taskIdx: Int, categoryId: CategoryId, completion: ((SubfiltersByItem?, PriceByItemId?)->Void)? ){
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["useCache":true,
                                                  "categoryId": categoryId,
                                                  "method":"getItemsChunk3"]) { [weak self] (result, error) in
               
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let `self` = self else { return }
                    let ret = self.checkedReqLimit(taskIdx: taskIdx, error: error)
                    switch ret {
                        case .success: break
                        case .rerunAfterError: return
                        case .requestLimitAchieved: return
                    }
                    let subfiltersByItem = ParsingHelper.parseJsonDictWithValArr(result: result, key: "subfiltersByItem")
                    let priceByItemId = ParsingHelper.parseJsonDict(type: CGFloat.self, result: result, key: "priceByItemId")
                    completion?(subfiltersByItem, priceByItemId)
                    self.activeTasks[taskIdx] = nil
                }
            }
        }
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
    
    
    
   func runCatalogStart(taskCode: Int, taskIdx: Int, categoryId: CategoryId, completion: ((CategoryId, Int, ItemIds, Int, Int)->Void)? ) {
    
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["useCache":true,
                                                  "categoryId": categoryId,
                                                  "method":"getCatalogTotals"]) { [weak self] (result, error) in
                DispatchQueue.global(qos: .userInteractive).async {
                    guard let `self` = self else { return }
                    let ret = self.checkedReqLimit(taskIdx: taskIdx, error: error)
                    switch ret {
                        case .success: break
                        case .rerunAfterError: return
                        case .requestLimitAchieved: return
                    }
                    let fetchLimit_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "fetchLimit")
                    let itemIds: ItemIds = ParsingHelper.parseJsonArr(result: result, key: "itemIds")
                    let minPrice_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "minPrice")
                    let maxPrice_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "maxPrice")
                    
                    guard let fetchLimit = fetchLimit_,
                          let minPrice = minPrice_,
                          let maxPrice = maxPrice_,
                          itemIds.count > 0
                    else {
                        let _ = self.checkedReqLimit(taskIdx: taskIdx, error: NSError(domain: "Network Service: runCatalogStart no values", code: 777, userInfo: nil))
                        return
                    }
                    completion?(categoryId, fetchLimit, itemIds, minPrice, maxPrice)
                    self.activeTasks[taskIdx] = nil
                }
            }
        }
        
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
    
    
    
    func runPrefetch(taskCode: Int, taskIdx: Int, itemIds: ItemIds, completion: (([CatalogModel1], NetError?)->Void)? ) {
        print("prefetch")
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["useCache": true,
                                                  "itemsIds": itemIds,
                                                  "method":"getPrefetching"
            ]){[weak self] (result, error) in
                DispatchQueue.global(qos: .userInteractive).async {
                    guard let `self` = self else { return }
                    let ret = self.checkedReqLimit(taskIdx: taskIdx, error: error)
                    switch ret {
                        case .success: break
                        case .rerunAfterError: return
                        case .requestLimitAchieved:
                            completion?([], NetError.firPrefetchResourceExhausted)
                            return
                    }
                    let arr:[CatalogModel1] = ParsingHelper.parseCatalogModel1(result: result, key: "items")
                    completion?(arr, nil)
                    self.activeTasks[taskIdx] = nil
                }
            }
        }
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
}
