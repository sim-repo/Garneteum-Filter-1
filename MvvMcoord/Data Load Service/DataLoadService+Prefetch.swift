import UIKit
import RxSwift
import CoreData

// MARK: - CATALOG
extension DataLoadService {
    
    internal func clearOldPrefetch() {
        let res = dbLoadLastUIDs(sql: "needRefresh == 1 && type == 'prefetch' ")
        guard let _res = res,
            _res.count > 0
            else {
                return
        }
        for uid in _res {
            dbDeleteEntity(0, clazz: PrefetchPersistent.self, entity: "PrefetchPersistent", fetchBatchSize: 0, sql: "categoryId == \(Int(uid.categoryId))")
            uid.needRefresh = false
        }
       // print("clearOldPrefetch")
        self.appDelegate.saveContext()
    }
    
    
    internal func doEmitPrefetch(categoryId: CategoryId, itemIds: Set<Int>){
        let res = dbLoadPrefetch(itemIds: itemIds)
        guard res.count >= itemIds.count
            else {
                
                let dbFoundItems = PrefetchPersistent.getModels(prefetchPersistents: res)
                let completion: (([CatalogModel1])->Void)? = { [weak self] catalogModels in
                    self?.dbSavePrefetch(categoryId, catalogModels, dbFoundItems)
                }
                let dbFoundItemIds = Set(res.compactMap({Int($0.itemId)}))
                let notFoundItemsIds = Set(itemIds).subtracting(dbFoundItemIds)
                networkService.reqPrefetch(itemIds: Array(notFoundItemsIds), completion: completion)
                return
        }
        let catalogModels: [CatalogModel] = PrefetchPersistent.getModels(prefetchPersistents: res)
        firePrefetch(catalogModels)
    }
    
    
    
    internal func firePrefetch(_ models: [CatalogModel]) {
        outPrefetch.onNext(models)
    }
    
    func getPrefetchEvent() -> PublishSubject<[CatalogModel]> {
        return outPrefetch
    }
    
    
    internal func dbSavePrefetch(_ categoryId: CategoryId, _ netItems: [CatalogModel1], _ dbFoundItems: [CatalogModel]){
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let `self` = self else { return }
            self.appDelegate.moc.performAndWait {
                var db = [PrefetchPersistent]()
                for model in netItems {
                    let row = PrefetchPersistent(entity: PrefetchPersistent.entity(), insertInto: self.appDelegate.moc)
                    row.setup(model: model)
                    db.append(row)
                }
                //print("dbSavePrefetch")
                self.appDelegate.saveContext()
                var res = netItems.compactMap({CatalogModel(catalogModel1: $0)})
                res.append(contentsOf: dbFoundItems)
                self.firePrefetch(res)
            }
        }
    }
    
    
    internal func dbLoadPrefetch(itemIds: Set<Int>) -> Set<PrefetchPersistent>{
        var db = Set<PrefetchPersistent>()
        
        let request: NSFetchRequest<PrefetchPersistent> = PrefetchPersistent.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor.init(key: "itemId", ascending: true)
        ]
        request.predicate = NSPredicate(format: "ANY itemId IN %@", itemIds)
        do {
            db = try Set(appDelegate.moc.fetch(request))
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return db
    }
}
