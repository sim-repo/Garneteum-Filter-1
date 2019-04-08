import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SubFilterSelectVC: UIViewController {
    
    public var viewModel: SubFilterVM!
    private var bag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyView: ApplyButton!
    @IBOutlet weak var applyViewBottomCon: NSLayoutConstraint!

    
    private var timer: Timer?
    private let waitContainer: UIView = UIView()
    private let waitActivityView = UIActivityIndicatorView(style: .whiteLarge)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        uitCurrMemVCs += 1    // uitest
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        registerTableView()
        bindCell()
        bindSelection()
        bindApply()
        bindWaitEvent()
        bindNavigation()
        bindReloadData()
    }
    
    deinit {
        print("SubFilter VC deinit")
        uitCurrMemVCs -= 1    // uitest
    }
    
    private func setTitle(){
        let title = "Фильтры"
        navigationController?.navigationBar.tintColor = UIColor.white
        let navLabel = UILabel()
        let navTitle = NSMutableAttributedString(string: title, attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.light)])
        navLabel.attributedText = navTitle
        self.navigationItem.titleView = navLabel
        self.navigationItem.titleView?.accessibilityIdentifier = "My"+String(uitCurrMemVCs)
    }
    
    
    private func registerTableView(){
        tableView.rx.setDelegate(self)
            .disposed(by: bag)
    }
    
    
    private func bindCell(){
        
        viewModel.filterActionDelegate?.subFiltersEvent()
            .bind(to: self.tableView.rx.items) { [weak self] tableView, index, model in
                guard let `self` = self else { return UITableViewCell() }
                let indexPath = IndexPath(item: index, section: 0)
                let cell = tableView.dequeueReusableCell(withIdentifier: "SubFilterSelectCell", for: indexPath) as! SubFilterSelectCell
                if let `model` = model {
                    cell.configCell(model: model, isCheckmark: self.viewModel.isCheckmark(subFilterId: model.id))
                }
                return cell
            }
            .disposed(by: bag)
    }
    
    
    private func bindSelection(){
        
        tableView.rx.itemSelected
            .subscribe(onNext: {[weak self] indexPath  in
               let cell = self!.tableView.cellForRow(at: indexPath) as! SubFilterSelectCell
                
                if cell.selectedCell() {
                    self?.viewModel?.filterActionDelegate?.selectSubFilterEvent().onNext((cell.id, true))
                } else {
                    self?.viewModel?.filterActionDelegate?.selectSubFilterEvent().onNext((cell.id, false))
                }
            })
            .disposed(by: bag)
        
        
        viewModel.filterActionDelegate?.refreshedCellSelectionsEvent()
            .subscribe(onNext: {[weak self] ids in
                guard let `self` = self else { return }
                
                for row in 0...self.tableView.numberOfRows(inSection: 0) - 1 {
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? SubFilterSelectCell {
                        if ids.contains(cell.id) {
                            cell.selectCell()
                        }
                    }
                }
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
        
        viewModel.filterActionDelegate?.showApplyViewEvent()
            .bind(onNext: {[weak self] isShow in
                guard let `self` = self else {return}
                self.applyViewBottomCon.constant = isShow ? 0 : self.applyView.frame.height
                self.view.layoutIfNeeded()
            })
            .disposed(by: bag)
    }
    
    private func bindReloadData(){
        viewModel.filterActionDelegate?.reloadSubfilterVC()
            .subscribe(onNext: {[weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: bag)
    }
    
    private func bindNavigation(){
        viewModel.outCloseSubFilterVC
            .take(1)
            .subscribe{[weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: bag)
    }
}



// Waiting Indicator
extension SubFilterSelectVC {
    
    private func showAlert(text: String){
        let alert = UIAlertController(title: "Ошибка", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func internalWaitControl() {
        if waitActivityView.isAnimating {
            showAlert(text: "Ошибка сетевого запроса.")
            stopWait()
        }
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
            .filter({[.enterSubFilter].contains($0.0)})
            .takeWhile({$0.1 == true})
            .subscribe(
                onNext: {[weak self] res in
                    let delay = res.2
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)){ [weak self] in
                        guard let `self` = self else {return}
                        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.internalWaitControl), userInfo: nil, repeats: false)
                        self.startWait()
                    }
                },
                onCompleted: {
                        self.stopWait()
                })
            .disposed(by: bag)
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

extension SubFilterSelectVC: UITableViewDelegate {
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            viewModel.backEvent.onNext(.back)
        }
    }
}
