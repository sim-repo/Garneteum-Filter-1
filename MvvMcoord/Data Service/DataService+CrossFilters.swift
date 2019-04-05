import UIKit
import RxSwift
import CoreData


// MARK: - CROSS FILTERS
extension DataService {
    
    internal func checkCrossRefresh(){
        
        let res = dbLoadLastUIDs(sql: "cross == 1 && needRefresh == 1")
        guard let _res = res,
            _res.count > 0
            else {
                doEmitCrossSubfilters(sql: "cross == 1")
                emitCrossFilters(sql: "cross == 1")
                return
        }
        
        for uid in _res {
            crossDelete(filterId: Int(uid.filterId))
        }
        
        for uid in _res {
            crossNetLoad(filterId: Int(uid.filterId))
        }
    }
    
    
    
    internal func crossRefreshDone(filterId: Int) {
        
        let res = dbLoadLastUIDs(sql: "filterId == \(filterId)")
        guard let _res = res else { return }
        _res[0].needRefresh = false
        self.appDelegate.saveContext()
    }
    
    
    
    internal func dbLoadLastUIDs(sql:String) -> [LastUidPersistent]?{
        
        var uidDB: [LastUidPersistent]?
        let request: NSFetchRequest<LastUidPersistent> = LastUidPersistent.fetchRequest()
        request.includesPendingChanges = false
        request.predicate = NSPredicate(format: sql)
        do {
            uidDB = try self.appDelegate.moc.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return uidDB
    }
    
    
    
    
    internal func dbLoadSubfilter(sql:String) -> [SubfilterPersistent]?{
        
        var db: [SubfilterPersistent]?
        let request: NSFetchRequest<SubfilterPersistent> = SubfilterPersistent.fetchRequest()
        request.includesPendingChanges = false
        if sql != "" {
            request.predicate = NSPredicate(format: sql)
        }
        do {
            db = try self.appDelegate.moc.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return db
    }
    
    
    
    internal func dbLoadCrossFilter(sql:String) -> [FilterPersistent]?{
        
        var db: [FilterPersistent]?
        let request: NSFetchRequest<FilterPersistent> = FilterPersistent.fetchRequest()
        request.includesPendingChanges = false
        request.predicate = NSPredicate(format: sql)
        do {
            db = try self.appDelegate.moc.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return db
    }
    
    
    
    internal func crossNetLoad(filterId: FilterId){
        let completion: (([FilterModel]?, [SubfilterModel]?) -> Void)? = { [weak self] (filters, subfilters) in
            self?.crossSave(filterId: filterId, filters: filters, subfilters: subfilters)
        }
        networkService.reqLoadCrossFilters(filterId: filterId, completion: completion)
    }
    
    
    
    internal func crossSave(filterId: FilterId, filters: [FilterModel]?, subfilters: [SubfilterModel]?) {

        guard let _filters = filters,
            let _subfilters = subfilters
            else { return }
        
        applyLogic.setup(filters_: _filters)
        outCrossFilters.onNext(_filters)
        applyLogic.setup(subFilters_: subfilters)
        outCrossSubfilters.onNext(_subfilters)
        
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
            appDelegate.saveContext()
            crossRefreshDone(filterId: filterId)
        }
    }
    
    
    
    internal func crossDelete(filterId: FilterId) {
        
        let res1 = dbLoadSubfilter(sql: "filterId == \(filterId)")
        guard let _res1 = res1 else { return }
        for element in _res1 {
            self.appDelegate.moc.delete(element)
        }
        
        let res2 = dbLoadCrossFilter(sql: "id == \(filterId)")
        guard let _res2 = res2 else { return }
        for element in _res2 {
            self.appDelegate.moc.delete(element)
        }
        appDelegate.saveContext()
    }
}
