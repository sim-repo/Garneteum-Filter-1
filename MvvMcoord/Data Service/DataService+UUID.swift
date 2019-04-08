import UIKit
import RxSwift
import CoreData

// MARK: - UUIDS
extension DataService {
    
    
    internal func loadNewUIDs(){
        let completion: (([UidModel], NetError?) -> Void)? = { [weak self] (uids, err) in
            guard let error = err
                else {
                    self?.saveNewUIDs(uids)
                    return
            }
            self?.fireNetError(netError: error)
        }
        networkService.reqLoadUIDs(completion: completion)
    }
    
    
    
    internal func saveNewUIDs(_ uids: [UidModel]?) {
        
        guard let _uids = uids
            else { return }
        self.dbDeleteData("NewUidPersistent")
        self.appDelegate.moc.performAndWait {
            var uidsDB = [NewUidPersistent]()
            for element in _uids {
               // let uidDB = NewUidPersistent(entity: NewUidPersistent.entity(), insertInto: self.appDelegate.moc)
                let uidDB = NSEntityDescription.insertNewObject(forEntityName: "NewUidPersistent", into: self.appDelegate.moc) as! NewUidPersistent

                uidDB.setup(uidModel: element)
                uidsDB.append(uidDB)
            }
            self.appDelegate.saveContext()
            self.compare()
        }
    }
    
    
    
    internal func saveLastUIDs(_ uids: [NewUidPersistent]) {
        
        appDelegate.moc.performAndWait {
            var uidsDB = [LastUidPersistent]()
            for element in uids {
                let uidDB = LastUidPersistent(entity: LastUidPersistent.entity(), insertInto: self.appDelegate.moc)
                uidDB.setup(newUID: element)
                uidsDB.append(uidDB)
            }
            self.appDelegate.saveContext()
            self.checkCrossRefresh()
            self.clearOldPrefetch()
            self.clearOldCatalog()
        }
    }
    
    
    
    internal func toRefresh(last: LastUidPersistent, newUid: String){
        last.needRefresh = true
        last.uid = newUid
        self.appDelegate.saveContext()
    }
    
    
    
    internal func compare() {
        
        guard let newUids = dbLoadNewUIDs() else { return }
        guard let lastUids = dbLoadLastUIDs(),
            lastUids.count > 0
        else {
            saveLastUIDs(newUids)
            return
        }
        
        var needToSave = [NewUidPersistent]()
        
        for new in newUids {
            if new.cross {
                if let last = lastUids.first(where: {$0.filterId == new.filterId && $0.type == new.type}) {
                    if last.uid != new.uid {
                        toRefresh(last: last, newUid: new.uid)
                    }
                } else {
                    needToSave.append(new)
                }
                
            } else {
                if let last = lastUids.first(where: {$0.categoryId == new.categoryId && $0.type == new.type}) {
                    if last.uid != new.uid {
                        toRefresh(last: last, newUid: new.uid)
                    }
                } else {
                    needToSave.append(new)
                }
            }
        }
        saveLastUIDs(needToSave)
    }
    
    
    
    internal func dbLoadNewUIDs() -> [NewUidPersistent]?{
        
        var uidDB: [NewUidPersistent]?
        do {
            uidDB = try self.appDelegate.moc.fetch(NewUidPersistent.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return uidDB
    }
    
    
    
    internal func dbLoadLastUIDs() -> [LastUidPersistent]?{
        
        var uidDB: [LastUidPersistent]?
        do {
            uidDB = try self.appDelegate.moc.fetch(LastUidPersistent.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return uidDB
    }
}

