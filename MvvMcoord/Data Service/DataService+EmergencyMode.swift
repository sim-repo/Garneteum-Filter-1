import UIKit
import RxSwift
import CoreData
import Kingfisher


// MARK: - CATALOG
extension DataService {

    
    
    internal func fixNetError(netError: NetError, _ categoryId: CategoryId? = 0) {
        if ReloadIfNeeded(netError) == false {
            
            errorCount += 1
            print("EMERGENCY MODE:")
            switch netError {
                case .prefetch_ServerRetEmpty, .prefetch_ServerRetError:
                    print("FIX prefetch")
                    if let id = categoryId {
                        fixWorkPrefetch(id)
                    }
                
                case .catalogStart_ServerRetEmpty, .catalogStart_ServerRetError:
                    print("FIX catalog start")
                    if let id = categoryId {
                        fixCatalog(id)
                    }
                
                case .categoryApply_ServerRetEmpty, .categoryApply_ServerRetError:
                    print("FIX category apply")
                    if let id = categoryId {
                        fixCategoryApply(id)
                    }
                
                case .categoryFilters_ServerRetEmpty, .categoryFilters_ServerRetError:
                    print("FIX category filters")
                    if let id = categoryId {
                        fixCategoryFilters(id)
                    }
                
                case .crossFilters_ServerRetEmpty, .crossFilters_ServerRetError:
                    print("FIX cross filters")
                    fixCrossFilters()
                
                case .uid_ServerRetEmpty, .uid_ServerRetError:
                    print("FIX uid")
                    fixUid()
                
                default:
                    break
            }
        }
    }
    
    
    internal func ReloadIfNeeded(_ netError: NetError) -> Bool{
        if errorCount >= netErrorLimitBeforeCleanDB {
            print("START FULL CLEANUP DB..")
            reloadAll(netError)
            errorCount = 0
            return true
        }
        
        return false
    }
    
    
    internal func reloadAll(_ netError: NetError){
        let moc = getMoc()
        dbAllDeleteEntity(clazz: NewUidPersistent.self, entity: "NewUidPersistent", moc)
        dbAllDeleteEntity(clazz: LastUidPersistent.self, entity: "LastUidPersistent", moc)
        dbAllDeleteEntity(clazz: PrefetchPersistent.self, entity: "PrefetchPersistent", moc)
        dbAllDeleteEntity(clazz: CategoriesPersistent.self, entity: "CategoriesPersistent", moc)
        dbAllDeleteEntity(clazz: CategoryItemIdsPersistent.self, entity: "CategoryItemIdsPersistent", moc)
        dbAllDeleteEntity(clazz: PriceByItemPersistent.self, entity: "PriceByItemPersistent", moc)
        dbAllDeleteEntity(clazz: SubfilterItemPersistent.self, entity: "SubfilterItemPersistent", moc)
        dbAllDeleteEntity(clazz: FilterPersistent.self, entity: "FilterPersistent", moc)
        dbAllDeleteEntity(clazz: SubfilterPersistent.self, entity: "SubfilterPersistent", moc)
        screenHandle(dataTaskEnum: .didStartApplication)
        outCriticalNetError.onNext(netError)
    }
    
    
    internal func dbAllLoadEntity<T: NSManagedObject>(_ clazz: T.Type,
                                                      _ entity: String,
                                                      _ moc_: NSManagedObjectContext? = nil ) -> [T]?{
        let moc = getMoc(moc_)
        var db: [T]?
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        do {
            db = try moc.fetch(request) as? [T]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return db
    }
    
    
    internal func dbAllDeleteEntity<T: NSManagedObject>(clazz: T.Type,
                                                        entity: String,
                                                        _ moc_: NSManagedObjectContext? = nil){
        
        let moc = getMoc(moc_)
        let res_ = dbAllLoadEntity(clazz, entity, moc_)
        guard let res = res_ else { return }
        for element in res {
            moc.delete(element)
        }
        save(moc: moc)
    }
    
    internal func fixWorkPrefetch(_ categoryId: CategoryId){
        let moc = getMoc()
        dbDeleteEntity(categoryId, clazz: CategoriesPersistent.self, entity: "CategoriesPersistent", fetchBatchSize: 0, moc) // added moc
        dbDeleteEntity(categoryId, clazz: CategoryItemIdsPersistent.self, entity: "CategoryItemIdsPersistent", fetchBatchSize: 0, moc) // added moc
        doEmitCatalogStart(categoryId, moc)
    }
    
    internal func fixCatalog(_ categoryId: CategoryId) {
        let moc = getMoc()
        dbDeleteEntity(categoryId, clazz: CategoriesPersistent.self, entity: "CategoriesPersistent", fetchBatchSize: 0, moc) // added moc
        dbDeleteEntity(categoryId, clazz: CategoryItemIdsPersistent.self, entity: "CategoryItemIdsPersistent", fetchBatchSize: 0, moc) // added moc
        doEmitCatalogStart(categoryId, moc)
    }
    
    internal func fixCategoryApply(_ categoryId: CategoryId) {

    }
    
    internal func fixCrossFilters(){
        
    }
    
    internal func fixCategoryFilters(_ categoryId: CategoryId) {
        
    }
    
    internal func fixUid(){
        
    }
}
