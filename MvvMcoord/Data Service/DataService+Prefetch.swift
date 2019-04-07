import UIKit
import RxSwift
import CoreData



// MARK: - CATALOG
extension DataService {
    
    
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
        self.appDelegate.saveContext()
    }
    
    
    internal func doEmitPrefetch(categoryId: CategoryId, itemIds: Set<Int>){
        
        let res = dbLoadPrefetch(itemIds: itemIds)
        guard res.count >= itemIds.count
            else {
                
                let dbFoundItems = PrefetchPersistent.getModels(prefetchPersistents: res)
                
                let completion: (([CatalogModel1], NetError?)->Void)? = { [weak self] catalogModels, err in
                    guard let error = err
                        else {
                            self?.dbSavePrefetch(categoryId, catalogModels, dbFoundItems)
                            return
                        }
                     self?.fireNetError(netError: error)
                }
                
                let midCompletion: ((NetError, Int)->Void)? = { [weak self] err, cnt in
                    self?.fireMidNetError(netError: err, trying: cnt)
                }
                
                let dbFoundItemIds = Set(res.compactMap({Int($0.itemId)}))
                let notFoundItemsIds = Set(itemIds).subtracting(dbFoundItemIds)
                networkService.reqPrefetch(itemIds: Array(notFoundItemsIds), completion: completion, midCompletion: midCompletion)
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

        var res = netItems.compactMap({CatalogModel(catalogModel1: $0)})
        res.append(contentsOf: dbFoundItems)
        firePrefetch(res)
        
        var db = [PrefetchPersistent]()
        for model in netItems {
            let row = PrefetchPersistent(entity: PrefetchPersistent.entity(), insertInto: appDelegate.moc)
            row.setup(model: model)
            db.append(row)
        }
        appDelegate.saveContext()
    }
    
    
    
    internal func dbLoadPrefetch(itemIds: Set<Int>) -> Set<PrefetchPersistent>{
        
        var db: Set<PrefetchPersistent>  = Set<PrefetchPersistent>()
            
        let request: NSFetchRequest<PrefetchPersistent> = PrefetchPersistent.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor.init(key: "itemId", ascending: true)
        ]
        request.includesPendingChanges = false
        request.predicate = NSPredicate(format: "ANY itemId IN %@", itemIds)
        do {
            db = try Set(appDelegate.readMoc.fetch(request))
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return db
    }
}
