import Foundation
import RxSwift
import RxDataSources
import SwiftyJSON

public class CatalogModel  {
    
    let id: Int
    let categoryId: CategoryId
    let name: String
    let thumbnail: String
    let stars: NSMutableAttributedString
    let newPrice: String
    let oldPrice: NSMutableAttributedString
    let votes: Int
    let discount: Int
    var imageView: UIImageView?
    
    init(id: Int, categoryId: CategoryId, name: String, thumbnail: String, stars: Int, newPrice: NSNumber, oldPrice: NSNumber, votes: Int, discount: Int) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
        self.thumbnail = thumbnail
        self.stars = Formatter.starsFormat(stars: stars, votes: votes)
        self.newPrice = Formatter.priceFormat(price: newPrice, localeIdentifier: "ru_RU")!
        self.oldPrice = Formatter.strikePriceFormat(price: oldPrice, localeIdentifier: "ru_RU")!
        self.votes = votes
        self.discount = discount
       // downloadImage()
    }
    
    convenience init(catalogModel1: CatalogModel1) {
        self.init(id: catalogModel1.id,
                  categoryId: catalogModel1.categoryId,
                  name: catalogModel1.name,
                  thumbnail: catalogModel1.thumbnail,
                  stars: catalogModel1.stars,
                  newPrice: catalogModel1.newPrice as NSNumber,
                  oldPrice: catalogModel1.oldPrice as NSNumber,
                  votes: catalogModel1.votes,
                  discount: catalogModel1.discount)
    }

    required init(json: JSON?) {
        let json = json!
            self.id = json["id"].intValue
            self.categoryId = json["categoryId"].intValue
            self.name = json["name"].stringValue
            self.thumbnail = json["thumbnail"].stringValue
            self.votes = json["votes"].intValue
        
            let starsNum = json["stars"].intValue
            self.stars =  Formatter.starsFormat(stars: starsNum, votes: votes)
            self.newPrice =  Formatter.priceFormat(price: NSNumber(value: json["newPrice"].intValue), localeIdentifier: "ru_RU")!
            self.oldPrice = Formatter.strikePriceFormat(price: NSNumber(value: json["oldPrice"].intValue), localeIdentifier: "ru_RU")!
            self.discount = json["discount"].intValue
          //  downloadImage()
    }

//
//    private func downloadImage(){
//        let gsReference = storage.reference(forURL: "gs://filterproject2.appspot.com/\(self.thumbnail).jpg")
//      //  image = UIImage(named: "no-images")
//        gsReference.getData(maxSize: 1 * 320 * 240) {[weak self] data, error in
//            if let error = error {
//                print("Storage: \(error.localizedDescription)")
//            } else {
//                self?.image = UIImage(data: data!)
//            }
//        }
//    }
    
    
    static func localTitle(categoryId: Int)->Observable<String> {
        guard
            let parent = models2[categoryId]
            else { return .empty()}
        
        return Observable.just(parent.title)
    }

}
