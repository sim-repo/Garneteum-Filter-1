import UIKit
import RxSwift
import CoreData



// MARK: - CATALOG 
extension DataService {
    
    internal func doEmitCatalogStart(_ categoryId: CategoryId){
        
        let moc = getMoc()
        
        let res1_ = dbLoadEntity(categoryId, CategoriesPersistent.self, "CategoriesPersistent", 1, moc)
        let res2_ = dbLoadEntity(categoryId, CategoryItemIdsPersistent.self, "CategoryItemIdsPersistent", 0, moc)
        guard let res1 = res1_,
            let res2 = res2_,
            res1.count > 0,
            res2.count > 0
            else {
                let completion: ((CategoryId, Int, ItemIds, Int, Int, NetError?)->Void)? = { [weak self] (categoryId, fetchLimit, itemIds, minPrice, maxPrice, err) in
                    guard let error = err
                        else {
                            self?.dbSaveCatalog(categoryId, fetchLimit, itemIds, minPrice, maxPrice)
                            return
                    }
                    self?.fireNetError(netError: error)
                }
                networkService.reqCatalogStart(categoryId: categoryId, completion: completion)
                return
        }
        var itemIds: [Int] = []
        for element in res2 {
            itemIds.append(Int(element.itemId))
        }
        fireCatalogTotal(categoryId, itemIds, Int(res1[0].fetchLimit), CGFloat(res1[0].minPrice), CGFloat(res1[0].maxPrice))
    }
    
    
    
    internal func clearOldCatalog(_ moc_: NSManagedObjectContext? = nil) {
        
        let moc = getMoc(moc_)
        let res = dbLoadLastUIDs(sql: "needRefresh == 1 && type == 'catalogIds' ", moc)
        guard let _res = res,
            _res.count > 0
            else {
                return
        }

        for uid in _res {
            dbDeleteEntity(Int(uid.categoryId), clazz: CategoriesPersistent.self, entity: "CategoriesPersistent", fetchBatchSize: 0, moc) // added moc
            dbDeleteEntity(Int(uid.categoryId), clazz: CategoryItemIdsPersistent.self, entity: "CategoryItemIdsPersistent", fetchBatchSize: 0, moc) // added moc
            uid.needRefresh = false
        }
        save(moc: moc)
    }

    
    internal func fireCatalogTotal(_ categoryId: CategoryId ,_ itemIds: ItemIds, _ fetchLimit: Int, _ minPrice: MinPrice, _ maxPrice: MaxPrice) {
        outCatalogTotal.onNext((categoryId, itemIds, fetchLimit, minPrice, maxPrice))
    }
    
    
    
    func getCatalogTotalEvent() -> BehaviorSubject<(CategoryId, ItemIds, Int, MinPrice, MaxPrice)> {
        return outCatalogTotal
    }
    
    
    internal func dbSaveCatalog(_ categoryId: CategoryId, _ fetchLimit: Int, _ itemIds: ItemIds, _ minPrice: Int, _ maxPrice: Int) {
        
        let moc = getMoc()

        fireCatalogTotal(categoryId, itemIds, fetchLimit, CGFloat(minPrice), CGFloat(maxPrice))
        
        dbDeleteEntity(categoryId, clazz: CategoriesPersistent.self, entity: "CategoriesPersistent", fetchBatchSize: 1, moc) // added moc
        dbDeleteEntity(categoryId, clazz: CategoryItemIdsPersistent.self, entity: "CategoryItemIdsPersistent", fetchBatchSize: 0, moc) // added moc

        moc.performAndWait {
            
            let row = CategoriesPersistent(entity: CategoriesPersistent.entity(), insertInto: moc)
            row.setup(categoryId, minPrice, maxPrice, fetchLimit)
            save(moc: moc)
            
            
            var db2 = [CategoryItemIdsPersistent]()
            for itemId in itemIds {
                let row = CategoryItemIdsPersistent(entity: CategoryItemIdsPersistent.entity(), insertInto: moc)
                //let row = NSEntityDescription.insertNewObject(forEntityName: "CategoryItemIdsPersistent", into: moc) as! CategoryItemIdsPersistent
                row.setup(categoryId, itemId)
                db2.append(row)
            }
            save(moc: moc)
        }
    }
    
    
    internal func dbLoadEntity<T: NSManagedObject>(_ categoryId: CategoryId,
                                                   _ clazz: T.Type,
                                                   _ entity: String,
                                                   _ fetchBatchSize: Int,
                                                   sql: String = "",
                                                   _ moc_: NSManagedObjectContext? = nil
                                                   ) -> [T]?{
        
        let moc = getMoc(moc_)
        var db: [T]?
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
         request.includesPendingChanges = false
        if fetchBatchSize != 0 {
            request.fetchBatchSize = fetchBatchSize
        }
        if sql == "" {
            request.predicate = NSPredicate(format: "categoryId == \(categoryId)")
        } else {
            request.predicate = NSPredicate(format: sql)
        }
        do {
            db = try moc.fetch(request) as? [T]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return db
    }
    
    
    
    internal func dbDeleteEntity<T: NSManagedObject>(_ categoryId: CategoryId,
                                                     clazz: T.Type,
                                                     entity: String,
                                                     fetchBatchSize: Int,
                                                     sql: String = "",
                                                     _ moc_: NSManagedObjectContext? = nil){
        
        let moc = getMoc(moc_)
        let res_ = dbLoadEntity(categoryId, clazz, entity, fetchBatchSize, sql: sql, moc_)
        guard let res = res_ else { return }
        for element in res {
            moc.delete(element)
        }
        save(moc: moc)
    }
}
