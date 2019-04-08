import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class FilterVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyView: ApplyButton!
    @IBOutlet weak var priceApplyView: PriceApply!
    @IBOutlet weak var priceApplyViewBottomCon: NSLayoutConstraint!

    
    
    
    public var viewModel: FilterVM!
    private var bag = DisposeBag()
    private var indexPaths: Set<IndexPath> = []
    private let waitContainer: UIView = UIView()
    private let waitActivityView = UIActivityIndicatorView(style: .whiteLarge)
    private var timer: Timer?
    var removeFilterEvent = PublishSubject<Int>()
    
    var rangeCellIndexPath: IndexPath!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        uitCurrMemVCs += 1  // uitest
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindCell()
        bindApply()
        bindPriceApply()
        bindWaitEvent()
        bindSelection()
        bindRemoveFilter()
        setTitle()
        bindNavigation()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 52
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    deinit {
        print("Filter VC deinit")
        uitCurrMemVCs -= 1  // uitest
    }
    

    
    private func setTitle(){
        navigationController?.navigationBar.tintColor = UIColor.white
        
        let title = "Фильтры"
        let navLabel = UILabel()
        let navTitle = NSMutableAttributedString(string: title, attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.light)])
        navLabel.attributedText = navTitle
        self.navigationItem.titleView = navLabel
        self.navigationItem.titleView?.accessibilityIdentifier = "My"+String(uitCurrMemVCs)
    }
    
    
    private func bindCell(){
        viewModel?.filterActionDelegate?.filtersEvent()
            .bind(to: self.tableView.rx.items) { [weak self] tableView, index, model in
                if let `self` = self,
                   let `model` = model {
                    let appliedTitles = self.viewModel.appliedTitles(filterId: model.id)
        
                    let indexPath = IndexPath(item: index, section: 0)
                    switch model.filterEnum {
                    case .range:
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as? FilterCell else { return UITableViewCell() }
                        cell.configCell(model: model, viewModel: self.viewModel)
                        cell.state = self.cellIsExpanded(at: indexPath) ? .expanded : .collapsed
                        return cell
                    case .select:
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCellSelect", for: indexPath) as? FilterCellSelect else { return UITableViewCell() }
                        cell.configCell(model: model, appliedTitles: appliedTitles, tableView: self.tableView, parent: self)
                        return cell
                    case .section:
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCellSection", for: indexPath) as? FilterCellSection else { return UITableViewCell() }
                        cell.configCell(model: model, appliedTitles: appliedTitles, tableView: self.tableView, parent: self)
                        return cell
                    }
                } else {
                    return UITableViewCell()
                }
            }.disposed(by: bag)
    }
    
   
    
    
    private func doHideRangePricesCell()->Bool{
        guard rangeCellIndexPath == nil
            else {
                let cell = tableView.cellForRow(at: rangeCellIndexPath) as! FilterCell
                cell.state = .collapsed
                removeExpandedIndexPath(rangeCellIndexPath)
                viewModel.filterActionDelegate?.showPriceApplyViewEvent().onNext(false)
                rangeCellIndexPath = nil
                tableView.beginUpdates()
                tableView.endUpdates()
                return true
        }
        return false
    }
    
    
    private func bindSelection(){
        
        let selected = tableView.rx.itemSelected
        
        selected
            .subscribe(onNext: {[weak self] indexPath  in
                let cell = self!.tableView.cellForRow(at: indexPath)
                self!.tableView.deselectRow(at: indexPath, animated: true)
                switch cell {
                case is FilterCellSelect:
                    
                    guard self!.doHideRangePricesCell() == false else { return }
                    
                    let id = (cell as! FilterCellSelect).id!
                    self!.viewModel.inSelectFilter.onNext(id)
                    
                case is FilterCell:
                    if let `cell` = cell as? FilterCell {
                        cell.state = .expanded
                        self!.addExpandedIndexPath(indexPath)
                        cell.setupRangeSlider()
                        self!.viewModel.filterActionDelegate?.showPriceApplyViewEvent().onNext(true)
                        self!.rangeCellIndexPath = indexPath
                    }
                    
                case is FilterCellSection:
                    guard self!.doHideRangePricesCell() == false else { return }
                    
                    let id = (cell as! FilterCellSection).id!
                    self!.viewModel.inSelectFilter.onNext(id)
                    
                default:
                    print("bindingRowSelected err")
                }
                self!.tableView.beginUpdates()
                self!.tableView.endUpdates()
            })
            .disposed(by: bag)
    }
    
    
    private func bindApply(){
        
        applyView.applyButton.rx.tap
            .subscribe{[weak self] _ in
                self?.viewModel.inApply.onNext(Void())
            }
            .disposed(by: bag)
        
        applyView.cleanUpButton.rx.tap
            .subscribe{[weak self] _ in
                self?.viewModel.inCleanUp.onNext(Void())
            }
            .disposed(by: bag)
        
        viewModel.filterActionDelegate?.showApplyWarning()
            .subscribe{[weak self] _ in
                self?.showAlert(text: "В указанных фильтрах отсутствуют товары. \n Необходимо изменить фильтры.")
            }
            .disposed(by: bag)
        
    }
    
    
    private func bindPriceApply(){
        
        priceApplyView.applyButton.rx.tap
            .subscribe{ [weak self] _ in
                let _ = self?.doHideRangePricesCell()
                self?.viewModel.priceInApply.onNext(Void())
            }
            .disposed(by: bag)
        
        viewModel.filterActionDelegate?.showPriceApplyViewEvent()
            .bind(onNext: {[weak self] isShow in
                guard let `self` = self else {return}
                self.priceApplyViewBottomCon.constant = isShow ? 0 : self.priceApplyView.frame.height
                self.view.layoutIfNeeded()
            })
            .disposed(by: bag)
        
        viewModel.filterActionDelegate?.getMidTotal()
            .subscribe(onNext: {[weak self] count in
                self?.priceApplyView.applyButton.setTitle("Применить \(count) товаров", for: .normal)
                self?.applyView.applyButton.setTitle("Применить \n \(count) товаров", for: .normal)
            })
            .disposed(by: bag)
    }
    
    
    private func bindNavigation() {
        viewModel.outCloseFilterVC
        .take(1)
        .subscribe{[weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        .disposed(by: bag)
    }
    
    
    private func bindRemoveFilter(){
        removeFilterEvent
            .subscribe(onNext: {[weak self] filterId in
                let _ = self!.doHideRangePricesCell()
                self!.viewModel.inRemoveFilter.onNext(filterId)
            })
            .disposed(by: bag)
    }
    
    
    func cellIsExpanded(at indexPath: IndexPath) -> Bool {
        return indexPaths.contains(indexPath)
    }
    
    
    func addExpandedIndexPath(_ indexPath: IndexPath) {
        indexPaths.insert(indexPath)
    }
    
    
    func removeExpandedIndexPath(_ indexPath: IndexPath) {
        indexPaths.remove(indexPath)
    }
}


// Waiting Indicator
extension FilterVC {
    
    private func showAlert(text: String){
        let alert = UIAlertController(title: "Ошибка", message: text, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .default) { (_) -> Void in
        }
        let refreshAction = UIAlertAction(title: "Обновить снова", style: .default) { (_) -> Void in
            self.viewModel.filterActionDelegate?.refreshFromFilter()
        }
        alert.addAction(cancelAction)
        alert.addAction(refreshAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func bindWaitEvent(){
        waitContainer.frame = CGRect(x: view.center.x, y: view.center.y, width: 80, height: 80)
        waitContainer.backgroundColor = .lightGray
        waitContainer.center = self.view.center
        waitActivityView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        waitContainer.isHidden = true
        waitContainer.addSubview(waitActivityView)
        waitContainer.alpha = 1.0
        view.addSubview(waitContainer)
        
        // occuring once wait
        viewModel.filterActionDelegate?.wait()
            .filter({[.enterFilter, .applySubFilter, .removeFilter].contains($0.0)})
            .takeWhile({$0.1 == true})
            .subscribe(onNext: {[weak self] res in
                                    let delay = res.2
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)){ [weak self] in
                                        guard let `self` = self else {return}
                                        self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.internalWaitControl), userInfo: nil, repeats: false)
                                        self.startWait()
                                    }
                        },
                       onCompleted: {
                            self.stopWait()
                        }
            )
            .disposed(by: bag)
    }
    
    @objc func internalWaitControl() {
        if waitActivityView.isAnimating {
            showAlert(text: "Ошибка сетевого запроса.")
            stopWait()
        }
    }
    
    private func startWait() {
        guard waitContainer.alpha == 1.0 else { return }
        tableView.isHidden = true
        waitContainer.isHidden = false
        waitActivityView.startAnimating()
    }
    
    private func stopWait(){
        timer?.invalidate()
        tableView.isHidden = false
        waitContainer.alpha = 0.0
        waitContainer.isHidden = true
        waitActivityView.stopAnimating()
    }
}


extension FilterVC: UITableViewDelegate {
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            viewModel.backEvent.onNext(.back)
        }
    }
}

