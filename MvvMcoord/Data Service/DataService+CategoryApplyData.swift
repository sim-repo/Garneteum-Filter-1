import UIKit
import RxSwift
import CoreData



// MARK: - CATEGORY APPLY DATA
extension DataService {
    
    
    internal func applyRefreshDone(categoryId: Int) {
        
        let uids = dbLoadLastUIDs(sql: "categoryId == \(categoryId) && needRefresh == 1 && type = 'subfiltersByItem' ||" +
                                       "categoryId == \(categoryId) && needRefresh == 1 && type = 'itemsBySubfilter' || " +
                                       "categoryId == \(categoryId) && needRefresh == 1 && type = 'priceByItemId'" )
        guard let _uids = uids else { return }
        for uid in _uids {
            uid.needRefresh = false
        }
        self.appDelegate.saveContext()
    }
    
    
    
    internal func applySave(categoryId: CategoryId, subfiltersByItem: SubfiltersByItem?, priceByItemId: PriceByItemId?) {
        
        guard let _subfiltersByItem = subfiltersByItem,
            let _priceByItemId = priceByItemId
            else { return }
        
        self.applyLogic.setupItemsAndSubfilters(subfiltersByItem: _subfiltersByItem)
        self.applyLogic.setup(priceByItemId_: _priceByItemId)
        
        applyDelete(categoryId: categoryId)
        appDelegate.moc.performAndWait {
            var db1 = [SubfilterItemPersistent]()
            for element in _subfiltersByItem {
                for subfilterId in element.value {
                    let row = SubfilterItemPersistent(entity: SubfilterItemPersistent.entity(), insertInto: appDelegate.moc)
                    row.setup(categoryId: categoryId, subfilterId: subfilterId, itemId: element.key)
                    db1.append(row)
                }
            }
            appDelegate.saveContext()
            var db2 = [PriceByItemPersistent]()
            for element in _priceByItemId {
                let row = PriceByItemPersistent(entity: PriceByItemPersistent.entity(), insertInto: appDelegate.moc)
                row.setup(categoryId: categoryId, itemId: element.key, price: element.value)
                db2.append(row)
            }
            appDelegate.saveContext()
            applyRefreshDone(categoryId: categoryId)
        }
    }
    
    
    
    internal func dbLoadSubfiltersItems(sql:String) -> [SubfilterItemPersistent]?{
        
        var db: [SubfilterItemPersistent]?
        let request: NSFetchRequest<SubfilterItemPersistent> = SubfilterItemPersistent.fetchRequest()
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
    
    
    
    internal func dbLoadPriceByItem(sql:String) -> [PriceByItemPersistent]?{
        
        var db: [PriceByItemPersistent]?
        let request: NSFetchRequest<PriceByItemPersistent> = PriceByItemPersistent.fetchRequest()
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
    
    
    
    internal func applyDelete(categoryId: CategoryId) {
        
        let res1 = dbLoadSubfiltersItems(sql: "categoryId == \(categoryId)")
        guard let _res1 = res1 else { return }
        for element in _res1 {
            self.appDelegate.moc.delete(element)
        }
        appDelegate.saveContext()
        let res2 = dbLoadPriceByItem(sql: "categoryId == \(categoryId)")
        guard let _res2 = res2 else { return }
        for element in _res2 {
            self.appDelegate.moc.delete(element)
        }
        appDelegate.saveContext()
    }
    
}
