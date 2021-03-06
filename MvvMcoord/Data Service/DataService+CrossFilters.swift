import UIKit
import RxSwift
import CoreData


// MARK: - CROSS FILTERS
extension DataService {
    
    internal func emitCrossFilters(_ moc_ : NSManagedObjectContext? = nil){
        
        print("start CROSS")
        let moc = getMoc(moc_)
        let res = dbLoadLastUIDs(sql: "cross == 1 && needRefresh == 1", moc) // added moc
        guard let _res = res,
            _res.count > 0
            else {
                print("emit CROSS")
                doEmitCrossSubfilters(sql: "cross == 1", moc)
                emitCrossFilters(sql: "cross == 1", moc)
                return
        }
        
        
        for uid in _res {
            crossDelete(filterId: Int(uid.filterId))
        }
        
        for uid in _res {
            print("netload CROSS")
            crossNetLoad(filterId: Int(uid.filterId))
        }
    }
    
    
    
    internal func crossRefreshDone(filterId: Int, _ moc_ : NSManagedObjectContext? = nil) {
        
        let moc = getMoc(moc_)
        let res = dbLoadLastUIDs(sql: "filterId == \(filterId)", moc) // added moc
        guard let _res = res else { return }
        _res[0].needRefresh = false
        save(moc: moc)
    }
    
    
    
    internal func dbLoadLastUIDs(sql:String, _ moc_: NSManagedObjectContext? = nil) -> [LastUidPersistent]?{
        
        var uidDB: [LastUidPersistent]?
        let request: NSFetchRequest<LastUidPersistent> = LastUidPersistent.fetchRequest()
        request.includesPendingChanges = false
        request.predicate = NSPredicate(format: sql)
        let moc = getMoc(moc_)
        do {
            uidDB = try moc.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return uidDB
    }
    
    
    
    
    internal func dbLoadSubfilter(sql:String, _ moc_: NSManagedObjectContext? = nil) -> [SubfilterPersistent]?{
        
        let moc = getMoc(moc_)
        var db: [SubfilterPersistent]?
        let request: NSFetchRequest<SubfilterPersistent> = SubfilterPersistent.fetchRequest()
        request.includesPendingChanges = false
        if sql != "" {
            request.predicate = NSPredicate(format: sql)
        }
        do {
            db = try moc.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return db
    }
    
    
    
    internal func dbLoadCrossFilter(sql:String, _ moc_: NSManagedObjectContext? = nil) -> [FilterPersistent]?{
        
        let moc = getMoc(moc_)
        var db: [FilterPersistent]?
        let request: NSFetchRequest<FilterPersistent> = FilterPersistent.fetchRequest()
        request.includesPendingChanges = false
        request.predicate = NSPredicate(format: sql)
        do {
            db = try moc.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return db
    }
    
    
    //MARK: -NetRequest
    internal func crossNetLoad(filterId: FilterId){
        let completion: (([FilterModel]?, [SubfilterModel]?, NetError?) -> Void)? = { [weak self] (filters, subfilters, err) in
            guard let error = err
                else {
                    self?.crossSave(filterId: filterId, filters: filters, subfilters: subfilters)
                    return
            }
            self?.fireNetError(netError: error)
            self?.fixNetError(netError: error)
        }
        networkService.reqLoadCrossFilters(filterId: filterId, completion: completion)
    }
    
    
    //MARK: -Save
    internal func crossSave(filterId: FilterId, filters: [FilterModel]?, subfilters: [SubfilterModel]?) {

        print("SAVE: cross filters")
        
        guard let _filters = filters,
            let _subfilters = subfilters
            else { return }
        
        applyLogic.setup(filters_: _filters)
        outCrossFilters.onNext(_filters)
        applyLogic.setup(subFilters_: subfilters)
        outCrossSubfilters.onNext(_subfilters)
        
        let moc = getMoc()
        moc.performAndWait {
            var filtersDB = [FilterPersistent]()
            for element in _filters {
                //let filterDB = FilterPersistent(entity: FilterPersistent.entity(), insertInto: appDelegate.moc)
                let filterDB = NSEntityDescription.insertNewObject(forEntityName: "FilterPersistent", into: moc) as! FilterPersistent
                filterDB.setup(filterModel: element)
                filtersDB.append(filterDB)
            }
            save(moc: moc)
            var subfiltersDB = [SubfilterPersistent]()
            for element in _subfilters {
                //let subfilterDB = SubfilterPersistent(entity: SubfilterPersistent.entity(), insertInto: appDelegate.moc)
                let subfilterDB = NSEntityDescription.insertNewObject(forEntityName: "SubfilterPersistent", into: moc) as! SubfilterPersistent
                subfilterDB.setup(subfilterModel: element)
                subfiltersDB.append(subfilterDB)
            }
            save(moc: moc)
            crossRefreshDone(filterId: filterId, moc) //added moc
        }
    }
    
    
    
    internal func crossDelete(filterId: FilterId) {
        
        let moc = getMoc()
        let res1 = dbLoadSubfilter(sql: "filterId == \(filterId)", moc) //added moc
        guard let _res1 = res1 else { return }
        for element in _res1 {
            moc.delete(element)
        }
        
        let res2 = dbLoadCrossFilter(sql: "id == \(filterId)", moc) //added moc
        guard let _res2 = res2 else { return }
        for element in _res2 {
            moc.delete(element)
        }
        save(moc: moc)
    }
}
