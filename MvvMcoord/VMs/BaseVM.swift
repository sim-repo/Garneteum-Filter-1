import UIKit
import RxSwift


enum CoordRetEnum: String {
    case back, reloadData
}

enum FilterActionEnum {
    case enterFilter, applyFilter, removeFilter, enterSubFilter, applySubFilter
}

enum BackEnum {
    case fromFilter, fromSubFilter
}

class BaseVM {
    let bag = DisposeBag()
    
    // MARK: - Proxies
    var backEvent = PublishSubject<CoordRetEnum>()
}
