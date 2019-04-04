import UIKit
import RxSwift
import Firebase
import CoreData


let storage = Storage.storage()


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FilterCoreData")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            print(storeDescription)
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    

    
    private(set) lazy var moc: NSManagedObjectContext = {
        
        // Initialize Managed Object Context
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    
    private(set) lazy var readMoc: NSManagedObjectContext = {
        
        // Initialize Managed Object Context
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    
    func saveContext() {
           // moc.perform {[weak self] in
                do {
                    if self.moc.hasChanges{
                        try self.moc.save()
                    }
                } catch let error as NSError {
                   
                    print("Unable to Save Changes of Managed Object Context")
                    print("\(error), \(error.localizedDescription)")
                }
                
          //  }
    }
    
    
    private var appCoordinator: AppCoord!
    private let disposeBag = DisposeBag()
    var navigationController: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        CategoryModel.fillModels()
        
        window = UIWindow()
        if let window = window {
            let mainVC = ViewController()
            navigationController = UINavigationController(rootViewController: mainVC)
            window.rootViewController = navigationController
        }
        
        appCoordinator = AppCoord(window: window!)
        appCoordinator.start()
            .subscribe()
            .disposed(by: disposeBag)
        
        return true
    }

}

