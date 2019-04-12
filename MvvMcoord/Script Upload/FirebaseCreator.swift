import UIKit

class FirebaseCreator {
    
    
    private init() {}
    public static let shared = FirebaseCreator()
    
    var nextItemId = 0
    var lastFilterId = 0
    var lastSubfilterId = 0
    var ft = FirebaseTemplate()
    var brandsSIDs: [Int] = []
    
    
    func uploadCrossFilters(){
        ft.cleanupFirebase()
        ft.uploadCrossFilters()
        (lastSubfilterId, brandsSIDs) = ft.uploadCrossSubFilters()
    }
    
    
    func uploadFilters(categoryId: Int,
                       totalItems: Int,
                       minPrice: Int,
                       maxPrice: Int,
                       biege: Int,
                       white: Int,
                       blue: Int,
                       yellow: Int,
                       green: Int,
                       brown: Int,
                       red: Int,
                       orange: Int,
                       pink: Int,
                       gray: Int,
                       darkblue: Int,
                       violet: Int,
                       black: Int,
                       filters: [FirebaseTemplate.FilterEnum]){
        
        
        ft.uploadCategory(categoryId: categoryId)
        
        let countsByColor = ft.getCountsByColor(biege: biege,
                                                white: white,
                                                blue: blue,
                                                yellow: yellow,
                                                green: green,
                                                brown: brown,
                                                red: red,
                                                orange: orange,
                                                pink: pink,
                                                gray: gray,
                                                darkblue: darkblue,
                                                violet: violet,
                                                black: black)
        
        let itemsIds = ft.createItemIds(nextItemId: &nextItemId, totalItems: totalItems)
        let imageByItem = ft.createItemImage(catergoryId: categoryId, itemIds: itemsIds, countsByColor: countsByColor)
        let colorByItem = ft.createItemColor(itemIds: itemsIds, countsByColor: countsByColor)
        var filterByCode: [Int:Int] = [:]
        var multipleFilter: [Int: Int]
        (lastFilterId, filterByCode, multipleFilter) = ft.uploadFilters(categoryId: categoryId, nextFilterId: lastFilterId, filters: filters)
        
        
        var subfiltersByFilter: [Int:[Int]]
        
        (lastSubfilterId, subfiltersByFilter) = ft.uploadSubFilters(categoryId: categoryId, filterByCode: filterByCode, _subfilterId: lastSubfilterId)
        
        ft.uploadSubfiltersByItem(categoryId: categoryId, colorByItem: colorByItem, subfiltersFilter: subfiltersByFilter, multiFilter: multipleFilter, brandsSubfilters: brandsSIDs)
        ft.uploadCatalog(categoryId: categoryId, imageByItem: imageByItem, minPrice: minPrice, maxPrice: maxPrice)
        
        ft.finalUpload(categoryId, minPrice: CGFloat(minPrice), maxPrice: CGFloat(maxPrice))
    }
    
    
    
    func ЖенскиеПовседневныеПлатья() {
        let count = 250
        let sum = count * 13
        uploadFilters(categoryId: 01010101,
                      totalItems: sum,
                      minPrice: 1000,
                      maxPrice: 25000,
                      biege: count,
                      white: count,
                      blue: count,
                      yellow: count,
                      green: count,
                      brown: count,
                      red: count,
                      orange: count,
                      pink: count,
                      gray: count,
                      darkblue: count,
                      violet: count,
                      black: count,
                      filters: [.size, .season , .material , .delivery, .clasp, .neckline, .decorElements, .dressStructuralElements, .sleeveType]
                      )
    }
    
    
    func ЖенскиеБрюки() {
        let count = 230
        let sum = count * 13
        uploadFilters(categoryId: 01010604,
                      totalItems: sum,
                      minPrice: 800,
                      maxPrice: 7700,
                      biege: count,
                      white: count,
                      blue: count,
                      yellow: count,
                      green: count,
                      brown: count,
                      red: count,
                      orange: count,
                      pink: count,
                      gray: count,
                      darkblue: count,
                      violet: count,
                      black: count,
                      filters: [.size, .season , .material , .delivery, .clasp, .trouserModel, .decorElements, .pocketType, .warmer, .trouserModelPantsCut, .fitType])
    }
    
    
    func ЖенскиеРубашки() {
        let count = 330
        let sum = count * 13
        uploadFilters(categoryId: 01010403,
                      totalItems: sum,
                      minPrice: 400,
                      maxPrice: 2200,
                      biege: count,
                      white: count,
                      blue: count,
                      yellow: count,
                      green: count,
                      brown: count,
                      red: count,
                      orange: count,
                      pink: count,
                      gray:count,
                      darkblue: count,
                      violet: count,
                      black: count,
                      filters: [.size, .season , .material , .delivery, .decorElements, .pocketType, .sleeveType, .trouserModelPantsCut, .clasp])
    }
    
    func ЖенскиеФутболки() {
        let count = 330
        let sum = count * 8
        uploadFilters(categoryId: 01010201,
                      totalItems: sum,
                      minPrice: 400,
                      maxPrice: 5300,
                      biege: 0,
                      white: 0,
                      blue: count,
                      yellow: count,
                      green: count,
                      brown: 0,
                      red: count,
                      orange: count,
                      pink: count,
                      gray: count,
                      darkblue: count,
                      violet: 0,
                      black: 0,
                      filters: [.size, .season , .material , .delivery, .neckline, .decorElements])
    }
    
    func run(){
       // ft.noUpload = true
        uploadCrossFilters()
        lastFilterId = ft.getFirstFilterId()
//        ЖенскиеПовседневныеПлатья()
//        print("ЖенскиеПовседневныеПлатья OK")
//        ЖенскиеБрюки()
//        print("ЖенскиеБрюки OK")
//        ЖенскиеРубашки()
//        print("ЖенскиеРубашки OK")
//        ft.noUpload = false
        ЖенскиеФутболки()
        print("ЖенскиеФутболки OK")
    }
}


