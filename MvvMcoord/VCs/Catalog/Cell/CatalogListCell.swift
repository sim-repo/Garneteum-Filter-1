import UIKit

class CatalogListCell : UICollectionViewCell{
    
    @IBOutlet weak var cartButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var discountView: DiscountLabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var oldPriceLabel: UILabel!
    @IBOutlet weak var newPriceLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    
    
    var viewModel: CatalogVM!
    
    func configCell(model: CatalogModel?, indexPath: IndexPath, viewModel: CatalogVM){
    
        if let `model` = model {
            imageView.image = UIImage(named: "no-images")
           
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
    
    func willAppear(indexPath: IndexPath, viewModel: CatalogVM){
        
        viewModel.downloadImage(indexPath: indexPath) {[weak self] url in
            self?.imageView.kf.setImage(with: URL(string: url),
                                        placeholder: nil,
                                        options: [],
                                        progressBlock: nil,
                                        completionHandler: { img, err, cache, url in
                                            self?.setNeedsDisplay()
                                        })
        }
    }
}
