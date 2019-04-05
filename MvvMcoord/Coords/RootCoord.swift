import UIKit
import RxSwift

class RootCoord: BaseCoord<CoordRetEnum> {
    
    private var window: UIWindow?
    private var parentBaseId: CategoryId
    
    
    init(window: UIWindow? = nil, parentBaseId: Int){
        self.window = window
        self.parentBaseId = parentBaseId
    }
    
    
    override func start() -> Observable<CoordRetEnum> {
        viewModel = CategoryVM(parentBaseId: parentBaseId)
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Category") as! CategoryVC
        let navigationController = UINavigationController(rootViewController: viewController)
        
        guard let vm = viewModel as? CategoryVM
            else { fatalError("view model") }
        
        
        viewController.viewModel = vm

//         let creater = FirebaseCreator.shared
//         creater.run()

        getDataService().screenHandle(dataTaskEnum: .didStartApplication)

        vm.outShowSubcategory
            .subscribe(
                onNext: {[weak self] baseId in
                    self?.showSubcategory(on: viewController, parentBaseId: baseId)
                    .asObservable()
                    .subscribe()
                    .disposed(by: self!.disposeBag)
                },
                onCompleted: {
                    print("onCompleted")
                }
            )
            .disposed(by: disposeBag)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return Observable
            .merge(vm.backEvent)
    }
    
    
    private func showSubcategory(on rootViewController: UIViewController, parentBaseId: CategoryId) -> Observable<CoordRetEnum>{
        let nextCoord = CategoryCoord(rootViewController: rootViewController, parentBaseId: parentBaseId)
        return coordinate(coord: nextCoord)
    }
}
