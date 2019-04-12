import UIKit
import RxSwift
import Firebase
import CoreData
import Kingfisher

let storage = Storage.storage()


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoord!
    private let disposeBag = DisposeBag()
    var navigationController: UINavigationController?
    
    // MARK: >>> Core Data:
    var persistentContainer: NSPersistentContainer = {
        objc_sync_enter(self)
        let container = NSPersistentContainer(name: "FilterCoreData")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            print(storeDescription)
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        objc_sync_exit(self)
        return container
    }()
    
    
    // MARK: >>> Kingfisher:
    func setupKingfisher(){
        
        let downloader = KingfisherManager.shared.downloader
        downloader.downloadTimeout = 15 // Download process will timeout after 5 seconds. Default is 15.
        
        let cache = KingfisherManager.shared.cache
        
        ImageCache.default.maxMemoryCost = 1024 * 1024 * 30
        
        
        // Set max disk cache to 50 mb. Default is no limit.
        cache.maxDiskCacheSize = 50 * 1024 * 1024
        
        // Set max disk cache to duration to 1 day, Default is 1 week.
        cache.maxCachePeriodInSecond = 60 * 60 * 24 * 1
    }
    
    func kfCleanMemoryCache(){
        let cache = KingfisherManager.shared.cache
        cache.clearMemoryCache()
    }
    
    func kfCleanDiskCache(){
        let cache = KingfisherManager.shared.cache
        cache.clearDiskCache()
    }
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        let _ = getNetworkService()
        usleep(10000)
        let _ = getDataService()
        
        setupKingfisher()
        
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

