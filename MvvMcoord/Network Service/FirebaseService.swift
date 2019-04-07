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
    
    
    override func reqLoadUIDs(completion: (([UidModel], NetError?)->Void)?) {
        print("NETWORK: reqLoadUIDs")
        taskNo += 1
        runCheckUUIDS(taskCode: NetTasksEnum.crossUIDs.rawValue, taskIdx: taskNo, completion: completion)
    }
    
    override func reqLoadCrossFilters(filterId: Int, completion: (([FilterModel],[SubfilterModel], NetError?)->Void)? ) {
        print("NETWORK: reqLoadCrossFilters")
        taskNo += 1
        runCrossFilters(taskCode: NetTasksEnum.crossFilters.rawValue, taskIdx: taskNo, filterId: filterId, completion: completion)
    }
    
    override func reqLoadCategoryFilters(categoryId: CategoryId, completion: (([FilterModel],[SubfilterModel], NetError?)->Void)? ) {
        print("NETWORK: reqLoadCategoryFilters")
        taskNo += 1
        runCategoryFilters(taskCode: NetTasksEnum.categoryFilters.rawValue, taskIdx: taskNo, categoryId: categoryId, completion: completion)
    }
    
    override func reqLoadCategoryApply(categoryId: CategoryId, completion: ((SubfiltersByItem?, PriceByItemId?, NetError?)->Void)? ) {
        print("NETWORK: reqLoadCategoryApply")
        taskNo += 1
        runCategoryApply(taskCode: NetTasksEnum.categoryApply.rawValue, taskIdx: taskNo, categoryId: categoryId, completion: completion)
    }
    
    override func reqCatalogStart(categoryId: CategoryId, completion: ((CategoryId, Int, ItemIds, Int, Int, NetError?)->Void)? ) {
        print("NETWORK: reqCatalogStart")
        taskNo += 1
        runCatalogStart(taskCode: NetTasksEnum.catalogStart.rawValue, taskIdx: taskNo, categoryId: categoryId, completion: completion)
    }

    override func reqPrefetch(itemIds: ItemIds, completion: (([CatalogModel1], NetError?)->Void)?, midCompletion: ((NetError, Int)->Void)?) {
        print("NETWORK: reqPrefetch")
        taskNo += 1
        runPrefetch(taskCode: NetTasksEnum.catalogPrefetch.rawValue, taskIdx: taskNo, itemIds: itemIds, completion, midCompletion)
    }
    
    private func checkedReqLimit(taskIdx: Int, error: Error?) -> (NetTaskStatusEnum, NetError?, Int) {
        if let err = error as NSError? {
            let cnt = self.reqTry[taskIdx] ?? 0
            if cnt < self.limitTry,
                let completion = self.activeTasks[taskIdx] {
                self.reRunTask(task: completion, taskId: taskIdx, error: err)
                return (.rerunAfterError, nil, cnt)
            } else {
                self.reqTry[taskIdx] = 0
                self.activeTasks[taskIdx] = nil
                var netError = NetError.specificError
                if let e = err as? NetError {
                    netError = e
                }
                return (.requestLimitAchieved, netError, cnt)
            }
        }
        return (.success, nil, 0)
    }
    
}



// MARK: -run task functions
extension FirebaseService  {
    
    
    private func runCheckUUIDS(taskCode: Int, taskIdx: Int, completion: (([UidModel], NetError?)->Void)?) {
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["method":"getUIDs"]) { [weak self] (result, error) in
                DispatchQueue.global(qos: .userInteractive).async {
                    guard let `self` = self else { return }
                    
                    // block #1
                    let (status, err, cnt) = self.checkedReqLimit(taskIdx: taskIdx, error: error)
                    switch status {
                        case .success: break
                        case .rerunAfterError: return
                        case .requestLimitAchieved:
                            completion?([], err == .specificError ? NetError.uid_ServerRetError : err)
                            return
                    }
                  
                    // block #2
                    let uuidModels: [UidModel] = ParsingHelper.parseUUIDModel(result: result, key: "uids")
                    guard uuidModels.count > 0
                    else {
                        let (status, err, cnt) = self.checkedReqLimit(taskIdx: taskIdx, error: error)
                        switch status {
                            case .success: break
                            case .rerunAfterError: return
                            case .requestLimitAchieved:
                                completion?([], err == .specificError ? NetError.uid_ServerRetEmpty: err)
                                return
                        }
                        return
                    }
                    completion?(uuidModels, nil)
                    self.activeTasks[taskIdx] = nil
                }
            }
        }
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
    
    
    private func runCrossFilters(taskCode: Int, taskIdx: Int, filterId: Int, completion: (([FilterModel],[SubfilterModel], NetError?)->Void)? ) {
        
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["useCache":true, "filterId": filterId,  "method":"getCrossChunk4"]) { [weak self] (result, error) in
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let `self` = self else { return }
                    
                    // block #1
                    let (status, err, cnt) = self.checkedReqLimit(taskIdx: taskIdx, error: error)
                    switch status {
                        case .success: break
                        case .rerunAfterError: return
                        case .requestLimitAchieved:
                            completion?([], [], err == .specificError ? NetError.crossFilters_ServerRetError : err)
                            return
                    }
                    
                    // block #2
                    let filters:[FilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "filter")
                    let subFilters:[SubfilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "subFilters")
                    guard filters.count > 0,
                        subFilters.count > 0
                    else {
                        let (status, err, cnt) = self.checkedReqLimit(taskIdx: taskIdx, error: error)
                        switch status {
                            case .success: break
                            case .rerunAfterError: return
                            case .requestLimitAchieved:
                                completion?([], [], err == .specificError ? NetError.crossFilters_ServerRetEmpty: err)
                                return
                        }
                        return
                    }
                    completion?(filters, subFilters, nil)
                    self.activeTasks[taskIdx] = nil
                }
            }
        }
        
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
    
    

    
    private func runCategoryFilters(taskCode: Int, taskIdx: Int, categoryId: CategoryId, completion: (([FilterModel], [SubfilterModel], NetError?)->Void)? ){
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["useCache":true,
                                                  "categoryId": categoryId,
                                                  "method":"getCategoryFiltersChunk5"]) { [weak self] (result, error) in
                
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let `self` = self else { return }
                    
                    // block #1
                    let (status, err, cnt) = self.checkedReqLimit(taskIdx: taskIdx, error: error)
                    switch status {
                        case .success: break
                        case .rerunAfterError: return
                        case .requestLimitAchieved:
                            completion?([], [], err == .specificError ? NetError.categoryFilters_ServerRetError : err)
                            return
                    }
                    
                    // block #2
                    let filters:[FilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "filters")
                    let subFilters:[SubfilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "subFilters")
                    
                    guard filters.count > 0,
                        subFilters.count > 0
                    else {
                        let (status, err, cnt) = self.checkedReqLimit(taskIdx: taskIdx, error: error)
                        switch status {
                        case .success: break
                        case .rerunAfterError: return
                        case .requestLimitAchieved:
                            completion?([], [], err == .specificError ? NetError.categoryFilters_ServerRetEmpty : err)
                            return
                        }
                        return
                    }
                    completion?(filters, subFilters, nil)
                    self.activeTasks[taskIdx] = nil
                }
            }
        }
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
    
    
    
    private func runCategoryApply(taskCode: Int, taskIdx: Int, categoryId: CategoryId, completion: ((SubfiltersByItem?, PriceByItemId?, NetError?)->Void)? ){
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["useCache":true,
                                                  "categoryId": categoryId,
                                                  "method":"getItemsChunk3"]) { [weak self] (result, error) in
               
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let `self` = self else { return }
                    
                    // block #1
                    let (status, err, cnt) = self.checkedReqLimit(taskIdx: taskIdx, error: error)
                    switch status {
                        case .success: break
                        case .rerunAfterError: return
                        case .requestLimitAchieved:
                            completion?(nil, nil, err == .specificError ? NetError.categoryApply_ServerRetError : err)
                            return
                    }
                    
                    // block #2
                    let subfiltersByItem = ParsingHelper.parseJsonDictWithValArr(result: result, key: "subfiltersByItem")
                    let priceByItemId = ParsingHelper.parseJsonDict(type: CGFloat.self, result: result, key: "priceByItemId")
                    
                    guard subfiltersByItem.count > 0,
                          priceByItemId.count > 0
                    else {
                        let (status, err, cnt) = self.checkedReqLimit(taskIdx: taskIdx, error: error)
                        switch status {
                        case .success: break
                        case .rerunAfterError: return
                        case .requestLimitAchieved:
                            completion?(nil, nil, err == .specificError ? NetError.categoryApply_ServerRetEmpty : err)
                            return
                        }
                        return
                    }
                    
                    completion?(subfiltersByItem, priceByItemId, nil)
                    self.activeTasks[taskIdx] = nil
                }
            }
        }
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
    
    
    
   func runCatalogStart(taskCode: Int, taskIdx: Int, categoryId: CategoryId, completion: ((CategoryId, Int, ItemIds, Int, Int, NetError?)->Void)? ) {
    
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["useCache":true,
                                                  "categoryId": categoryId,
                                                  "method":"getCatalogTotals"]) { [weak self] (result, error) in
                DispatchQueue.global(qos: .userInteractive).async {
                    guard let `self` = self else { return }
                    // block #1
                    let (status, err, cnt) = self.checkedReqLimit(taskIdx: taskIdx, error: error)
                    switch status {
                        case .success: break
                        case .rerunAfterError: return
                        case .requestLimitAchieved:
                            completion?(0, 0, [], 0, 0, err == .specificError ? NetError.catalogStart_ServerRetError : err)
                            return
                    }
                    
                    // block #2
                    let fetchLimit_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "fetchLimit")
                    let itemIds: ItemIds = ParsingHelper.parseJsonArr(result: result, key: "itemIds")
                    let minPrice_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "minPrice")
                    let maxPrice_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "maxPrice")
                    
                    guard let fetchLimit = fetchLimit_,
                          let minPrice = minPrice_,
                          let maxPrice = maxPrice_,
                          itemIds.count > 0
                    else {
                        let (status, err, cnt) = self.checkedReqLimit(taskIdx: taskIdx, error: NetError.catalogStart_ServerRetEmpty)
                        switch status {
                            case .success: break
                            case .rerunAfterError: return
                            case .requestLimitAchieved:
                                completion?(0, 0, [], 0, 0, err == .specificError ? NetError.catalogStart_ServerRetEmpty : err)
                                return
                        }
                        return
                    }
                    
                    completion?(categoryId, fetchLimit, itemIds, minPrice, maxPrice, nil)
                    self.activeTasks[taskIdx] = nil
                }
            }
        }
        
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
    
    
    
    func runPrefetch(taskCode: Int, taskIdx: Int, itemIds: ItemIds, _ completion: (([CatalogModel1], NetError?)->Void)? , _ midCompletion: ((NetError, Int)->Void)?) {
        print("prefetch")
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["useCache": true,
                                                  "itemsIds": itemIds,
                                                  "method":"getPrefetching"
            ]){[weak self] (result, error) in
                DispatchQueue.global(qos: .userInteractive).async {
                    guard let `self` = self else { return }
                    
                    // block #1
                    let (status, err, cnt) = self.checkedReqLimit(taskIdx: taskIdx, error: error)
                    switch status {
                        case .success: break
                        case .rerunAfterError:
                            midCompletion?(.prefetch_ServerRetError, cnt)
                            return
                        case .requestLimitAchieved:
                            completion?([], err == .specificError ? .prefetch_ServerRetError : err)
                            return
                    }
                    
                    // block #2
                    let arr:[CatalogModel1] = ParsingHelper.parseCatalogModel1(result: result, key: "items")
                    guard arr.count > 0
                    else {
                        let (status, err, cnt) = self.checkedReqLimit(taskIdx: taskIdx, error: NetError.prefetch_ServerRetEmpty)
                        switch status {
                            case .success: break
                            case .rerunAfterError:
                                midCompletion?(.prefetch_ServerRetError, cnt)
                                return
                            case .requestLimitAchieved:
                                completion?([], err == .specificError ? .prefetch_ServerRetEmpty : err)
                                return
                        }
                        return
                    }
                    
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
