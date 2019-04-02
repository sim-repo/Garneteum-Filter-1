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
        uploadFilters(categoryId: 01010101,
                      totalItems: 6006,
                      minPrice: 1000,
                      maxPrice: 25000,
                      biege: 462,
                      white: 462,
                      blue: 462,
                      yellow: 462,
                      green: 462,
                      brown: 462,
                      red: 462,
                      orange: 462,
                      pink: 462,
                      gray: 462,
                      darkblue: 462,
                      violet: 462,
                      black: 462,
                      filters: [.size, .season , .material , .delivery, .clasp, .neckline, .decorElements, .dressStructuralElements, .sleeveType]
                      )
//
//        uploadFilters(categoryId: 01010101,
//                      totalItems: 52,
//                      minPrice: 1000,
//                      maxPrice: 25000,
//                      biege: 4,
//                      white: 4,
//                      blue: 4,
//                      yellow: 4,
//                      green: 4,
//                      brown: 4,
//                      red: 4,
//                      orange: 4,
//                      pink: 4,
//                      gray: 4,
//                      darkblue: 4,
//                      violet: 4,
//                      black: 4,
//                      filters: [.season]
//        )
    }
    
    
    func ЖенскиеБрюки() {
//        uploadFilters(categoryId: 01010604,
//                      totalItems: 14,
//                      minPrice: 800,
//                      maxPrice: 7700,
//                      biege: 1,
//                      white: 1,
//                      blue: 1,
//                      yellow: 1,
//                      green: 1,
//                      brown: 1,
//                      red: 1,
//                      orange: 1,
//                      pink: 1,
//                      gray: 1,
//                      darkblue: 1,
//                      violet: 1,
//                      black: 2,
//                      filters: [.size, .season , .material , .delivery])

        
        uploadFilters(categoryId: 01010604,
                      totalItems: 153,
                      minPrice: 800,
                      maxPrice: 7700,
                      biege: 14,
                      white: 9,
                      blue: 26,
                      yellow: 19,
                      green: 9,
                      brown: 17,
                      red: 10,
                      orange: 9,
                      pink: 8,
                      gray: 9,
                      darkblue: 8,
                      violet: 9,
                      black: 6,
                      filters: [.size, .season , .material , .delivery, .clasp, .trouserModel, .decorElements, .pocketType, .warmer, .trouserModelPantsCut, .fitType])
    }
    
    
    func ЖенскиеРубашки() {
        uploadFilters(categoryId: 01010403,
                      totalItems: 59,
                      minPrice: 400,
                      maxPrice: 2200,
                      biege: 14,
                      white: 9,
                      blue: 8,
                      yellow: 7,
                      green: 4,
                      brown: 6,
                      red: 6,
                      orange: 5,
                      pink: 0,
                      gray: 0,
                      darkblue: 0,
                      violet: 0,
                      black: 0,
                      filters: [.size, .season , .material , .delivery, .decorElements, .pocketType, .sleeveType, .trouserModelPantsCut, .clasp])
    }
    
    func run(){
        uploadCrossFilters()
        lastFilterId = ft.getFirstFilterId()
        ЖенскиеПовседневныеПлатья()
        print("ЖенскиеПовседневныеПлатья OK")
        ЖенскиеБрюки()
        print("ЖенскиеБрюки OK")
        ЖенскиеРубашки()
        print("ЖенскиеРубашки OK")
    }
}


