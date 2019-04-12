import Foundation
import RxSwift
import RxDataSources
import SwiftyJSON

var bag = DisposeBag()

enum FilterEnum : String{
    case select, range, section
}

protocol ModelProtocol: class {
    init(json: JSON?) // need for AlamofireNetworkManager.parseJSON
}

public class FilterModel : ModelProtocol {
    var id: FilterId = 0
    var title: String = ""
    var categoryId: CategoryId = 0
    var filterEnum: FilterEnum = .select
    var enabled = true
    var cross = false
    var uuid: String = ""
    
    convenience init(id: Int, categoryId: Int, title: String, cross: Bool, filterEnum: FilterEnum) {
        self.init(json: nil)
        self.id = id
        self.categoryId = categoryId
        self.title = title
        self.filterEnum = filterEnum
        self.cross = cross
    }
    
    
    required init(json: JSON?) {
        if let json = json {
            self.id = json["id"].intValue
            self.title = json["title"].stringValue
            self.cross = json["cross"].boolValue
            if !self.cross {
                self.categoryId = json["categoryId"].intValue
            }
            self.filterEnum = FilterEnum(rawValue: json["filterEnum"].stringValue)!
            self.enabled = json["enabled"].boolValue
            self.uuid = json["uuid"].stringValue
        }
    }
}



public class SubfilterModel : ModelProtocol {
    var id: SubFilterId = 0
    var filterId: FilterId = 0
    var categoryId: CategoryId = 0
    var title: String = ""
    var enabled = true
    var sectionHeader = ""
    var countItems = 0
    var cross = false
    

    convenience init(id: Int, filterId: Int, categoryId: Int, title: String, sectionHeader: String = "", cross: Bool, countItems: Int) {
        self.init(json: nil)
        self.filterId = filterId
        self.id = id
        self.categoryId = categoryId
        self.title = title
        self.sectionHeader = sectionHeader
        self.cross = cross
        self.countItems = countItems
    }
    
    required init(json: JSON?) {
        if let json = json {
            self.id = json["id"].intValue
            self.filterId = json["filterId"].intValue
            self.cross = json["cross"].boolValue
            if !cross {
                self.categoryId = json["categoryId"].intValue
            }
            self.title = json["title"].stringValue
            self.enabled = json["enabled"].boolValue
            self.sectionHeader = json["sectionHeader"].stringValue
            //FilterApplyLogic.shared.addSubF(id: id, subFilter: self)
        }
    }
}




public struct SectionOfSubFilterModel {
    var header: String
    public var items: [SubfilterModel]
}


extension SectionOfSubFilterModel: SectionModelType {
    public typealias Item = SubfilterModel
    
    public init(original: SectionOfSubFilterModel, items: [Item]) {
        self = original
        self.items = items
    }
}

