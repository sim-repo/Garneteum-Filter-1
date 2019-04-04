import UIKit
import RxSwift
import CoreData

// MARK: - CATEGORY SUBFILTERS
extension DataLoadService {
    
    internal func doEmitCategoryAllFilters(_ categoryId: CategoryId){
        let res = dbLoadLastUIDs(sql: "categoryId == \(categoryId) && needRefresh == 1 && type == 'filters' ")
        guard let _res = res,
            _res.count > 0
            else {
                //self.emitCategoryFilters(sql: "categoryId == \(categoryId) || cross == 1")
                self.emitCategoryFilters(sql: "categoryId == \(categoryId)")
                self.emitCategorySubfilters(sql: "categoryId == \(categoryId)")
                self.setupApplyFromDB(sql: "categoryId == \(categoryId)")
                return
        }
        for uid in _res {
            categoryNetLoad(categoryId: Int(uid.categoryId))
        }
    }
    
    
    internal func categoryRefreshDone(categoryId: Int) {
      // print("done: \(categoryId)")
        let uids = dbLoadLastUIDs(sql: "categoryId == \(categoryId) && type = 'filters'")
        guard let _uids = uids else { return }
        for uid in _uids {
            uid.needRefresh = false
        }
      //  print("categoryRefreshDone")
        self.appDelegate.saveContext()
        self.emitCategorySubfilters(sql: "categoryId == \(categoryId)")
        self.emitCategoryFilters(sql: "categoryId == \(categoryId)")
        //self.emitCategoryFilters(sql: "categoryId == \(categoryId) || cross == 1")
    }
    
    
    internal func categoryNetLoad(categoryId: FilterId){
       // print("category load from NETWORK: \(categoryId)")
        let completion: (([FilterModel]?, [SubfilterModel]?) -> Void)? = { [weak self] (filters, subfilters) in
            self?.categorySave(categoryId: categoryId, filters: filters, subfilters: subfilters)
        }
        networkService.reqLoadCategoryFilters(categoryId: categoryId, completion: completion)
        
        let completion2: ((SubfiltersByItem?, PriceByItemId?) -> Void)? = { [weak self] (subfiltersByItem, priceByItemId) in
            self?.applySave(categoryId: categoryId, subfiltersByItem: subfiltersByItem, priceByItemId: priceByItemId)
        }
        
        networkService.reqLoadCategoryApply(categoryId: categoryId, completion: completion2)
    }
    
    
    internal func categorySave(categoryId: CategoryId, filters: [FilterModel]?, subfilters: [SubfilterModel]?) {
       // print("categorySave: \(categoryId)")
        guard let _filters = filters,
            let _subfilters = subfilters
            else { return }
        
        categoryDelete(categoryId: categoryId)

        appDelegate.moc.performAndWait {
            var filtersDB = [FilterPersistent]()
            for element in _filters {
                let filterDB = FilterPersistent(entity: FilterPersistent.entity(), insertInto: appDelegate.moc)
                filterDB.setup(filterModel: element)
                filtersDB.append(filterDB)
            }
            var subfiltersDB = [SubfilterPersistent]()
            for element in _subfilters {
                let subfilterDB = SubfilterPersistent(entity: SubfilterPersistent.entity(), insertInto: appDelegate.moc)
                subfilterDB.setup(subfilterModel: element)
                subfiltersDB.append(subfilterDB)
            }
          //  print("categorySave")
            appDelegate.saveContext()
            categoryRefreshDone(categoryId: categoryId)
        }
        
    }
    
    
  
    
    
    internal func categoryDelete(categoryId: CategoryId) {
        let res1 = dbLoadSubfilter(sql: "categoryId == \(categoryId)")
        guard let _res1 = res1 else { return }
        for element in _res1 {
            self.appDelegate.moc.delete(element)
        }
        let res2 = dbLoadCrossFilter(sql: "categoryId == \(categoryId)") // ?????????
        guard let _res2 = res2 else { return }
        for element in _res2 {
            self.appDelegate.moc.delete(element)
        }
       // print("categoryDelete")
        appDelegate.saveContext()
    }
    
    
}

