import UIKit



class SubFilterSelectCell : UITableViewCell{
    
    @IBOutlet weak var subFilterLabel: UILabel!
    
    func configCell(model: SubfilterModel){
        subFilterLabel.text = model.title
    }
}
