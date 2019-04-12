import UIKit
import RxSwift
import CoreData

// MARK: - UUIDS
extension DataService {
    
    //MARK: -NetRequest
    internal func loadNewUIDs(){
        let completion: (([UidModel], NetError?) -> Void)? = { [weak self] (uids, err) in
            guard let error = err
                else {
                    self?.saveNewUIDs(uids)
                    return
            }
            self?.fireNetError(netError: error)
            self?.fixNetError(netError: error)
        }
        networkService.reqLoadUIDs(completion: completion)
    }
    
    
    //MARK: -Save
    internal func saveNewUIDs(_ uids: [UidModel]?) {
        print("SAVE: new uid")
        
        guard let _uids = uids
            else { return }
        
        let moc = getMoc()
        moc.performAndWait {
            self.dbDeleteData("NewUidPersistent", moc)
        
            var uidsDB = [NewUidPersistent]()
            for element in _uids {
                let uidDB = NewUidPersistent(entity: NewUidPersistent.entity(), insertInto: moc)
                //let uidDB = NSEntityDescription.insertNewObject(forEntityName: "NewUidPersistent", into: moc) as! NewUidPersistent

                uidDB.setup(uidModel: element)
                uidsDB.append(uidDB)
            }
            save(moc: moc)
            self.compare(moc)
        }
    }
    
    
    
    internal func saveLastUIDs(_ newUids: [NewUidPersistent], _ moc_ : NSManagedObjectContext? = nil) {
        
        guard newUids.count > 0
            else {
                self.emitCrossFilters(moc_)
                return
            }
        print("SAVE: last uid")
        
        let moc = getMoc(moc_)
        
        moc.performAndWait {
            var uidsDB = [LastUidPersistent]()
            for element in newUids {
                let uidDB = LastUidPersistent(entity: LastUidPersistent.entity(), insertInto: moc)
                uidDB.setup(newUID: element)
                uidsDB.append(uidDB)
            }
            self.save(moc: moc)
            self.emitCrossFilters(moc)
            self.clearOldPrefetch(moc)
            self.clearOldCatalog(moc)
        }
    }
    
    
    
    internal func toRefresh(last: LastUidPersistent, newUid: String, _ moc_ : NSManagedObjectContext? = nil){
        let moc = getMoc(moc_)
        last.needRefresh = true
        last.uid = newUid
        save(moc: moc)
    }
    
    
    
    internal func compare(_ moc_ : NSManagedObjectContext? = nil) {
        
        let moc = getMoc(moc_)
        
        guard let newUids = dbLoadNewUIDs(moc) else { return }
        guard let lastUids = dbLoadLastUIDs(moc),
            lastUids.count > 0
        else {
            saveLastUIDs(newUids, moc)
            return
        }
        
        var needToSave = [NewUidPersistent]()
        
        
        for new in newUids {
            if new.cross {
                if let last = lastUids.first(where: {$0.filterId == new.filterId && $0.type == new.type}) {
                    if last.uid != new.uid {
                        toRefresh(last: last, newUid: new.uid, moc) // added moc
                    }
                } else {
                    needToSave.append(new)
                }
                
            } else {
                if let last = lastUids.first(where: {$0.categoryId == new.categoryId && $0.type == new.type}) {
                    if last.uid != new.uid {
                        toRefresh(last: last, newUid: new.uid, moc) // added moc
                    }
                } else {
                    needToSave.append(new)
                }
            }
        }
        saveLastUIDs(needToSave, moc)
    }
    
    
    
    internal func dbLoadNewUIDs(_ moc_: NSManagedObjectContext? = nil) -> [NewUidPersistent]?{
        
        let moc = getMoc(moc_)
        var uidDB: [NewUidPersistent]?
        do {
            uidDB = try moc.fetch(NewUidPersistent.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return uidDB
    }
    
    
    
    internal func dbLoadLastUIDs(_ moc_: NSManagedObjectContext? = nil) -> [LastUidPersistent]?{
        
        let moc = getMoc(moc_)
        var uidDB: [LastUidPersistent]?
        do {
            uidDB = try moc.fetch(LastUidPersistent.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return uidDB
    }
    
}

