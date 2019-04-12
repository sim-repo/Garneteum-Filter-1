import UIKit


typealias CategoryId = Int
typealias CountItems = [Int:Int]
typealias FilterIds = [Int?]
typealias SubFilterIds = [Int?]
typealias Applied = Set<Int>
typealias Selected = Set<Int>
typealias FilterId = Int
typealias SubFilterId = Int
typealias ItemIds = [Int]
typealias ApplyingByFilter = [Int:[Int]]
typealias Filters = [Int:FilterModel]
public typealias SubfiltersByFilter = [Int:[Int]]
typealias SectionSubFiltersByFilter = [Int:[SectionOfSubFilterModel]]
typealias SubFilters = [Int:SubfilterModel]
public typealias SubfiltersByItem = [Int: [Int]]
public typealias ItemsBySubfilter = [Int: [Int]]
public typealias ItemsById = [Int:CatalogModel]
typealias ItemsByCatalog = [Int:[CatalogModel]]
public typealias PriceByItemId = [Int:CGFloat]
typealias EnabledFilters = [Int:Bool]
typealias EnabledSubfilters = [Int:Bool]
typealias ItemsTotal = Int
typealias MinPrice = CGFloat
typealias MaxPrice = CGFloat
typealias UuidByFilter = [Int:String]


extension Date {
    func currentTimeMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

enum CloudProviderEnum {
    case firebase, aws
}

enum DataTasksEnum: Int {
    case didStartApplication = 0, willCatalogShow, willStartPrefetch, willPrefetch
}

enum NetError: Error {
    case specificError,
    prefetch_ServerRetError,
    catalogStart_ServerRetError,
    prefetch_ServerRetEmpty,
    catalogStart_ServerRetEmpty,
    categoryApply_ServerRetError,
    categoryApply_ServerRetEmpty,
    categoryFilters_ServerRetError,
    categoryFilters_ServerRetEmpty,
    crossFilters_ServerRetError,
    crossFilters_ServerRetEmpty,
    uid_ServerRetError,
    uid_ServerRetEmpty
}


var providerMode: CloudProviderEnum = .firebase

func getNetworkService() -> NetworkFacadeProtocol {
    switch providerMode {
    case .firebase:
        return FirebaseService.shared
    default:
        return FirebaseService.shared
    }
}

func getDataService() -> DataFacadeProtocol {
    return DataService.shared
}


public func +<K, V>(left: [K:V], right: [K:V]) -> [K:V] {
    return left.merging(right) { $1 }
}

extension Array {
    func getElement(at index: Int) -> Element? {
        let isValidIndex = index >= 0 && index < count
        return isValidIndex ? self[index] : nil
    }
}

public func getCatalogImage(picName: String)->String {
    return "gs://filterproject2.appspot.com/\(picName).jpg"
}


