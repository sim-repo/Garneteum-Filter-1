import UIKit
import RxSwift
import CoreData



// MARK: - CATEGORY SUBFILTERS
extension DataService {
    
    internal func doEmitCategoryAllFilters(_ categoryId: CategoryId){
        
        print("START Category")
        let moc = getMoc()
        let res = dbLoadLastUIDs(sql: "categoryId == \(categoryId) && needRefresh == 1 && type == 'filters' ", moc)
        guard let _res = res,
            _res.count > 0
            else {
                print("EMIT Category")
                self.emitCategoryFilters(sql: "categoryId == \(categoryId)", moc)
                self.emitCategorySubfilters(sql: "categoryId == \(categoryId)", moc)
                self.setupApplyFromDB(sql: "categoryId == \(categoryId)", moc)
                return
        }
        for uid in _res {
            print("NETLOAD Category")
            categoryNetLoad(categoryId: Int(uid.categoryId))
        }
    }
    
    
    
    internal func categoryRefreshDone(categoryId: Int, _ moc_: NSManagedObjectContext? = nil) {
        let moc = getMoc()
        let uids = dbLoadLastUIDs(sql: "categoryId == \(categoryId) && type = 'filters'", moc)
        guard let _uids = uids else { return }
        for uid in _uids {
            uid.needRefresh = false
        }
        save(moc: moc)
    }
    
    
    //MARK: -NetRequest
    internal func categoryNetLoad(categoryId: FilterId){
        
        let completion: (([FilterModel]?, [SubfilterModel]?, NetError?) -> Void)? = { [weak self] (filters, subfilters, err) in
            guard let error = err
                else {
                    self?.categorySave(categoryId: categoryId, filters: filters, subfilters: subfilters)
                    return
            }
            self?.fireNetError(netError: error)
            self?.fixNetError(netError: error, categoryId)
        }
        
        networkService.reqLoadCategoryFilters(categoryId: categoryId, completion: completion)
        
        let completion2: ((SubfiltersByItem?, PriceByItemId?, NetError?) -> Void)? = { [weak self] (subfiltersByItem, priceByItemId, err) in
            guard let error = err
                else {
                    self?.applySave(categoryId: categoryId, subfiltersByItem: subfiltersByItem, priceByItemId: priceByItemId)
                    return
            }
            self?.fireNetError(netError: error)
        }
     
        networkService.reqLoadCategoryApply(categoryId: categoryId, completion: completion2)
    }
    
    
    //MARK: -Save
    internal func categorySave(categoryId: CategoryId, filters: [FilterModel]?, subfilters: [SubfilterModel]?) {
        
        guard let _filters = filters,
            let _subfilters = subfilters
            else { return }
        
        print("SAVE: category filters")
        
        
        applyLogic.setup(subFilters_: _subfilters)
        applyLogic.setup(filters_: filters)
        outCategorySubfilters.onNext(_subfilters)
        outFilters.onNext(_filters)
        
        let moc = getMoc()
        categoryDelete(categoryId: categoryId, moc) //added moc
        
        moc.performAndWait {
            var filtersDB = [FilterPersistent]()
            for element in _filters {
              //  let filterDB = FilterPersistent(entity: FilterPersistent.entity(), insertInto: appDelegate.moc)
                let filterDB = NSEntityDescription.insertNewObject(forEntityName: "FilterPersistent", into: moc) as! FilterPersistent
                filterDB.setup(filterModel: element)
                filtersDB.append(filterDB)
            }
            var subfiltersDB = [SubfilterPersistent]()
            for element in _subfilters {
               // let subfilterDB = SubfilterPersistent(entity: SubfilterPersistent.entity(), insertInto: appDelegate.moc)
                let subfilterDB = NSEntityDescription.insertNewObject(forEntityName: "SubfilterPersistent", into: moc) as! SubfilterPersistent
                subfilterDB.setup(subfilterModel: element)
                subfiltersDB.append(subfilterDB)
            }
            save(moc: moc)
            categoryRefreshDone(categoryId: categoryId, moc) //added moc
        }
    }
    
    

    internal func categoryDelete(categoryId: CategoryId, _ moc_ : NSManagedObjectContext? = nil) {
        
        let moc = getMoc(moc_)
        let res1 = dbLoadSubfilter(sql: "categoryId == \(categoryId)", moc)
        guard let _res1 = res1 else { return }
        for element in _res1 {
            moc.delete(element)
        }
        let res2 = dbLoadCrossFilter(sql: "categoryId == \(categoryId)", moc) // ?????????
        guard let _res2 = res2 else { return }
        for element in _res2 {
            moc.delete(element)
        }
        save(moc: moc)
    }
}

