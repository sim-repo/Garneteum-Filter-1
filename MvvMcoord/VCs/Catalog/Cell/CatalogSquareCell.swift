import UIKit

class CatalogSquareCell : UICollectionViewCell{
    
    @IBOutlet weak var cartButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var discountView: DiscountLabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var oldPriceLabel: UILabel!
    @IBOutlet weak var newPriceLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    
    
    func configCell(model: CatalogModel?, indexPath: IndexPath){
        
        if let `model` = model {
            
            let gsReference = storage.reference(forURL: "gs://filterproject2.appspot.com/\(model.thumbnail).jpg")
            
            imageView.image = UIImage(named: "no-images")
            gsReference.getData(maxSize: 1 * 640 * 360) {[weak self] data, error in
                if let error = error {
                    print("Storage: \(error.localizedDescription)")
                } else {
                    if self?.tag == indexPath.row {
                        self?.imageView.image = UIImage(data: data!)
                    }
                }
            }
            discountView.label?.text = "    -" + String(model.discount) + "%"
            itemNameLabel.text = model.name
            newPriceLabel.text = model.newPrice
            oldPriceLabel.attributedText = model.oldPrice
            starsLabel.attributedText = model.stars
        } else {
            imageView.image = UIImage(named: "no-images")
            discountView.label?.text = ""
            itemNameLabel.text = ""
            newPriceLabel.text = ""
            oldPriceLabel.attributedText = nil
            starsLabel.attributedText = nil
        }
    }
    
}
