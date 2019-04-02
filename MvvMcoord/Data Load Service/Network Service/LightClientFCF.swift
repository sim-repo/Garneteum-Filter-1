import Foundation
import SwiftyJSON
import RxSwift
import Firebase
import FirebaseDatabase
import FirebaseFunctions


var functions = Functions.functions()

class LightClientFCF : NetworkFacadeBase {
    
    private override init(){}
    
    public static var shared = LightClientFCF()
    
    typealias Completion = (() -> Void)?
    
    private var networkingFunc: Completion
    
    private func runRequest(networkFunction: Completion = nil){
        networkFunction?()
    }
    
    private func firebaseHandleErr(error: NSError){
        if error.domain == FunctionsErrorDomain {
            let code = FunctionsErrorCode(rawValue: error.code)
            let message = error.localizedDescription
            let details = error.userInfo[FunctionsErrorDetailsKey]
            
            if code == FunctionsErrorCode.resourceExhausted {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(30), execute: {[weak self] in
                    self?.networkingFunc?()
                })
            }
            print("error:\(String(describing: code)) : \(message) : \(String(describing: details))")
        }
    }
    
    
    
//    override func reqCatalogStart(categoryId: CategoryId) {
//        networkingFunc = {
//            functions.httpsCallable("catalogTotal").call(["useCache":true,
//                                                          "categoryId":categoryId
//            ]){[weak self] (result, error) in
//                guard let `self` = self else { return }
//
//                if let error = error as NSError? {
//                    self.firebaseHandleErr(error: error)
//                    return
//                }
//                let fetchLimit_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "fetchLimit")
//
//                let itemIds: ItemIds = ParsingHelper.parseJsonArr(result: result, key: "itemIds")
//                let minPrice_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "minPrice")
//                let maxPrice_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "maxPrice")
//
//
//                guard let fetchLimit = fetchLimit_,
//                    let minPrice = minPrice_,
//                    let maxPrice = maxPrice_
//                    else { return self.firebaseHandleErr(error: NSError(domain: FunctionsErrorDomain, code: 1, userInfo: ["Parse Int":0])  )}
//
//                self.fireCatalogTotal(categoryId, itemIds, fetchLimit, CGFloat(minPrice), CGFloat(maxPrice))
//            }
//        }
//        runRequest(networkFunction: networkingFunc)
//    }
//
//    
//    override func reqCatalogModel(itemIds: ItemIds) {
//        networkingFunc = {
//            functions.httpsCallable("catalogEntities").call([ "useCache": true,
//                                                              "itemsIds": itemIds
//            ]){[weak self] (result, error) in
//                guard let `self` = self else { return }
//                
//                if let error = error as NSError? {
//                    self.firebaseHandleErr(error: error)
//                    return
//                }
//                let arr:[CatalogModel] = ParsingHelper.parseCatalogModel(result: result, key: "items")
//                self.fireCatalogModel(catalogModel: arr)
//            }
//        }
//        runRequest(networkFunction: networkingFunc)
//    }
    
    
    override func reqPreloadFullFilterEntities(categoryId: CategoryId) {}
    
    override func reqFullFilterEntities(categoryId: CategoryId){
        networkingFunc = {
            functions.httpsCallable("fullFilterEntities").call(["useCache":true
            ]) {[weak self] (result, error) in
                guard let `self` = self else { return }
                
                if let error = error as NSError? {
                    self.firebaseHandleErr(error: error)
                    return
                }
                let filters:[FilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "filters")
                let subfilters:[SubfilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "subFilters")
                self.fireFullFilterEntities(filters, subfilters)
            }
        }
        networkingFunc?()
        runRequest(networkFunction: networkingFunc)
    }
    
    
    
    override func reqEnterSubFilter(filterId: FilterId, appliedSubFilters: Applied, rangePrice: RangePrice){
//        networkingFunc = {
//            functions.httpsCallable("currSubFilterIds").call(["useCache":true,
//                                                              "categoryId": categoryId,
//                                                              "filterId":filterId,
//                                                              "appliedSubFilters":Array(appliedSubFilters),
//                                                              "userMinPrice":rangePrice.userMinPrice,
//                                                              "userMaxPrice":rangePrice.userMaxPrice,
//                                                              "tipMinPrice":rangePrice.tipMinPrice,
//                                                              "tipMaxPrice":rangePrice.tipMaxPrice
//            ]) {[weak self] (result, error) in
//                guard let `self` = self else { return }
//
//
//                if let error = error as NSError? {
//                    self.firebaseHandleErr(error: error)
//                    return
//                }
//                let filterId_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "filterId")
//                guard let filterId = filterId_
//                    else { return self.firebaseHandleErr(error: NSError(domain: "parse INT error", code: 0, userInfo: [:]))}
//
//                let subfiltersIds:SubFilterIds = ParsingHelper.parseJsonArr(result: result, key: "subFiltersIds")
//                let applied:Applied = Set(ParsingHelper.parseJsonArr(result: result, key: "appliedSubFiltersIds"))
//                let countsItems: CountItems = ParsingHelper.parseJsonDict(result: result, key: "countItemsBySubfilter")
//                self.fireEnterSubFilter(filterId, subfiltersIds, applied, countsItems)
//            }
//        }
//        runRequest(networkFunction: networkingFunc)
    }
    
    
    
    override func reqApplyFromFilter(categoryId: CategoryId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice){
        networkingFunc = {
            functions.httpsCallable("applyFromFilterNow").call(["useCache":true,
                                                                "categoryId":categoryId,
                                                                "selectedSubFilters":Array(selectedSubFilters),
                                                                "appliedSubFilters":Array(appliedSubFilters),
                                                                "userMinPrice":rangePrice.userMinPrice,
                                                                "userMaxPrice":rangePrice.userMaxPrice,
                                                                "tipMinPrice":rangePrice.tipMinPrice,
                                                                "tipMaxPrice":rangePrice.tipMaxPrice
            ]) {[weak self] (result, error) in
                guard let `self` = self else { return }
                
                
                if let error = error as NSError? {
                    self.firebaseHandleErr(error: error)
                    return
                }
                
                let filterIds: FilterIds = ParsingHelper.parseJsonArr(result: result, key: "filtersIds")
                let subfilterIds: SubFilterIds = ParsingHelper.parseJsonArr(result: result, key: "subFiltersIds")
                let applied: Applied = Set(ParsingHelper.parseJsonArr(result: result, key: "appliedSubFiltersIds"))
                let selected: Selected = Set(ParsingHelper.parseJsonArr(result: result, key: "selectedSubFiltersIds"))
                let itemIds: ItemIds = ParsingHelper.parseJsonArr(result: result, key: "itemIds")
                
                self.fireApplyForItems(filterIds, subfilterIds, applied, selected, itemIds)
            }
        }
        runRequest(networkFunction: networkingFunc)
    }
    
    
    override func reqApplyFromSubFilter(categoryId: CategoryId, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice){
        
        networkingFunc = {
            functions.httpsCallable("applyFromSubFilterNow").call([ "useCache":true,
                                                                    "categoryId":categoryId,
                                                                    "filterId":filterId,
                                                                    "selectedSubFilters":Array(selectedSubFilters),
                                                                    "appliedSubFilters":Array(appliedSubFilters),
                                                                    "initialMinPrice":rangePrice.initialMinPrice,
                                                                    "initialMaxPrice":rangePrice.initialMaxPrice,
                                                                    "userMinPrice":rangePrice.userMinPrice,
                                                                    "userMaxPrice":rangePrice.userMaxPrice,
                                                                    "tipMinPrice":rangePrice.tipMinPrice,
                                                                    "tipMaxPrice":rangePrice.tipMaxPrice
            ]) {[weak self] (result, error) in
                guard let `self` = self else { return }
                
                if let error = error as NSError? {
                    self.firebaseHandleErr(error: error)
                    return
                }
                
                let filterIds: FilterIds = ParsingHelper.parseJsonArr(result: result, key: "filtersIds")
                let subfilterIds: SubFilterIds = ParsingHelper.parseJsonArr(result: result, key: "subFiltersIds")
                let applied: Applied = Set(ParsingHelper.parseJsonArr(result: result, key: "appliedSubFiltersIds"))
                let selected: Selected = Set(ParsingHelper.parseJsonArr(result: result, key: "selectedSubFiltersIds"))
                let sTipMinPrice_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "tipMinPrice")
                let sTipMaxPrice_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "tipMaxPrice")
                let itemsTotal_: ItemsTotal? = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "itemsTotal")
                
                guard let tipMinPrice = sTipMinPrice_,
                    let tipMaxPrice = sTipMaxPrice_,
                    let itemsTotal = itemsTotal_
                    else { return self.firebaseHandleErr(error: NSError(domain: FunctionsErrorDomain, code: 1, userInfo: ["Parse Int":0])  )}
                
                self.fireApplyForFilters(filterIds,
                                          subfilterIds,
                                          applied,
                                          selected,
                                          CGFloat(tipMinPrice),
                                          CGFloat(tipMaxPrice),
                                          itemsTotal
                )
            }
        }
        runRequest(networkFunction: networkingFunc)
    }
    
    
    override func reqApplyByPrices(categoryId: CategoryId, rangePrice: RangePrice){
        networkingFunc = {
            functions.httpsCallable("applyByPrices").call(["useCache":true,
                                                           "categoryId":categoryId,
                                                           "userMinPrice":rangePrice.userMinPrice,
                                                           "userMaxPrice":rangePrice.userMaxPrice,
                                                           "tipMinPrice":rangePrice.tipMinPrice,
                                                           "tipMaxPrice":rangePrice.tipMaxPrice
            ]) {[weak self] (result, error) in
                guard let `self` = self else { return }
                
                if let error = error as NSError? {
                    self.firebaseHandleErr(error: error)
                    return
                }
                
                let filterIds: FilterIds = ParsingHelper.parseJsonArr(result: result, key: "filterIds")
                
                self.fireApplyByPrices(filterIds)
            }
        }
        runRequest(networkFunction: networkingFunc)
    }
    
    
    override func reqRemoveFilter(categoryId: CategoryId, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice){
        networkingFunc = {
            functions.httpsCallable("apiRemoveFilter").call(["useCache":true,
                                                            "filterId":filterId,
                                                            "selectedSubFilters":Array(selectedSubFilters),
                                                            "appliedSubFilters":Array(appliedSubFilters),
                                                            "categoryId":categoryId,
                                                            "initialMinPrice":rangePrice.initialMinPrice,
                                                            "initialMaxPrice":rangePrice.initialMaxPrice,
                                                            "userMinPrice":rangePrice.userMinPrice,
                                                            "userMaxPrice":rangePrice.userMaxPrice,
                                                            "tipMinPrice":rangePrice.tipMinPrice,
                                                            "tipMaxPrice":rangePrice.tipMaxPrice
            ]) {[weak self] (result, error) in
                guard let `self` = self else { return }
                
                
                if let error = error as NSError? {
                    self.firebaseHandleErr(error: error)
                }
                
                let filterIds: FilterIds = ParsingHelper.parseJsonArr(result: result, key: "filtersIds")
                let subfilterIds: SubFilterIds = ParsingHelper.parseJsonArr(result: result, key: "subFiltersIds")
                let applied: Applied = Set(ParsingHelper.parseJsonArr(result: result, key: "appliedSubFiltersIds"))
                let selected: Selected = Set(ParsingHelper.parseJsonArr(result: result, key: "selectedSubFiltersIds"))
                let sTipMinPrice_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "tipMinPrice")
                let sTipMaxPrice_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "tipMaxPrice")
                let itemsTotal_: ItemsTotal? = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "itemsTotal")
                
                guard let tipMinPrice = sTipMinPrice_,
                    let tipMaxPrice = sTipMaxPrice_,
                    let itemsTotal = itemsTotal_
                    else { return self.firebaseHandleErr(error: NSError(domain: FunctionsErrorDomain, code: 1, userInfo: ["Parse Int":0])  )}
                
                self.fireApplyForFilters(filterIds,
                                         subfilterIds,
                                         applied,
                                         selected,
                                         CGFloat(tipMinPrice),
                                         CGFloat(tipMaxPrice),
                                         itemsTotal
                )
            
            }
        }
        runRequest(networkFunction: networkingFunc)
    }
    
    
    
    override func reqMidTotal(categoryId: CategoryId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
        networkingFunc = {
            functions.httpsCallable("doCalcMidTotal").call(["useCache":true,
                                                            "selectedSubFilters":Array(selectedSubFilters),
                                                            "appliedSubFilters":Array(appliedSubFilters),
                                                            "userMinPrice":rangePrice.userMinPrice,
                                                            "userMaxPrice":rangePrice.userMaxPrice,
                                                            "tipMinPrice":rangePrice.tipMinPrice,
                                                            "tipMaxPrice":rangePrice.tipMaxPrice
            ]) {[weak self] (result, error) in
                guard let `self` = self else { return }
                
                
                if let error = error as NSError? {
                    self.firebaseHandleErr(error: error)
                }

                let sTotal = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "itemsTotal")
                
                guard let total = sTotal
                    else { return self.firebaseHandleErr(error: NSError(domain: FunctionsErrorDomain, code: 1, userInfo: ["Parse Int":0])  )}
                
                self.fireMidTotal(Int(total))
            }
        }
        runRequest(networkFunction: networkingFunc)
    }
}
