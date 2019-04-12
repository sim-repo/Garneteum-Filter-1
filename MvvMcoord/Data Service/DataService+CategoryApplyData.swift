import UIKit
import RxSwift
import CoreData



// MARK: - CATEGORY APPLY DATA
extension DataService {
    
    
    internal func applyRefreshDone(categoryId: Int, _ moc_ : NSManagedObjectContext? = nil) {
        
        let moc = getMoc(moc_)
        let uids = dbLoadLastUIDs(sql: "categoryId == \(categoryId) && needRefresh == 1 && type = 'subfiltersByItem' ||" +
                                       "categoryId == \(categoryId) && needRefresh == 1 && type = 'itemsBySubfilter' || " +
                                       "categoryId == \(categoryId) && needRefresh == 1 && type = 'priceByItemId'",
                                  moc) // added moc
        guard let _uids = uids else { return }
        for uid in _uids {
            uid.needRefresh = false
        }
        save(moc: moc)
    }
    
    
    //MARK: -Save
    internal func applySave(categoryId: CategoryId, subfiltersByItem: SubfiltersByItem?, priceByItemId: PriceByItemId?) {
        
        guard let _subfiltersByItem = subfiltersByItem,
            let _priceByItemId = priceByItemId
            else { return }
        
        print("SAVE: category apply")
        
        
        self.applyLogic.setupItemsAndSubfilters(subfiltersByItem: _subfiltersByItem)
        self.applyLogic.setup(priceByItemId_: _priceByItemId)
        
        applyDelete(categoryId: categoryId)
        
        let moc = getMoc()

        moc.performAndWait {
            var db1 = [SubfilterItemPersistent]()
            for element in _subfiltersByItem {
                for subfilterId in element.value {
                    //let row = SubfilterItemPersistent(entity: SubfilterItemPersistent.entity(), insertInto: appDelegate.moc)
                    let row = NSEntityDescription.insertNewObject(forEntityName: "SubfilterItemPersistent", into: moc) as! SubfilterItemPersistent
                    row.setup(categoryId: categoryId, subfilterId: subfilterId, itemId: element.key)
                    db1.append(row)
                }
            }
            save(moc: moc)

            var db2 = [PriceByItemPersistent]()
            for element in _priceByItemId {
               // let row = PriceByItemPersistent(entity: PriceByItemPersistent.entity(), insertInto: appDelegate.moc)
                let row = NSEntityDescription.insertNewObject(forEntityName: "PriceByItemPersistent", into: moc) as! PriceByItemPersistent
                row.setup(categoryId: categoryId, itemId: element.key, price: element.value)
                db2.append(row)
            }
            save(moc: moc)
            applyRefreshDone(categoryId: categoryId, moc) // added moc
        }
    }
    
    
    
    internal func dbLoadSubfiltersItems(sql:String, _ moc_: NSManagedObjectContext? = nil) -> [SubfilterItemPersistent]?{
        
        let moc = getMoc(moc_)
        var db: [SubfilterItemPersistent]?
        let request: NSFetchRequest<SubfilterItemPersistent> = SubfilterItemPersistent.fetchRequest()
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
    
    
    
    internal func dbLoadPriceByItem(sql:String, _ moc_: NSManagedObjectContext? = nil) -> [PriceByItemPersistent]?{
        
        let moc = getMoc(moc_)
        var db: [PriceByItemPersistent]?
        let request: NSFetchRequest<PriceByItemPersistent> = PriceByItemPersistent.fetchRequest()
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
    
    
    
    internal func applyDelete(categoryId: CategoryId, _ moc_ : NSManagedObjectContext? = nil) {
        
        let moc = getMoc(moc_)
        
        let res1 = dbLoadSubfiltersItems(sql: "categoryId == \(categoryId)", moc)
        guard let _res1 = res1 else { return }
        for element in _res1 {
            moc.delete(element)
        }
        save(moc: moc)
        
        
        let res2 = dbLoadPriceByItem(sql: "categoryId == \(categoryId)", moc)
        guard let _res2 = res2 else { return }
        for element in _res2 {
            moc.delete(element)
        }
        save(moc: moc)
    }
    
}
