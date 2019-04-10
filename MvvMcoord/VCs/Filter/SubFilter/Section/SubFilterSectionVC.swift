import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SubFilterSectionVC: UIViewController {
    
    var viewModel: SubFilterVM!
    var bag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyView: ApplyButton!
    @IBOutlet weak var applyViewBottomCon: NSLayoutConstraint!
    
    private let waitContainer: UIView = UIView()
    private let waitActivityView = UIActivityIndicatorView(style: .whiteLarge)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableView()
        bindCell()
        bindSelection()
        bindNavigation()
        bindApply()
        bindWaitEvent()
    }
    
    private func registerTableView(){
        tableView.rx.setDelegate(self)
            .disposed(by: bag)
    }
    
    private func bindCell(){
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfSubFilterModel>(
            configureCell: { dataSource, tableView, indexPath, model in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubFilterSectionCell", for: indexPath) as? SubFilterSectionCell else { return (UITableViewCell()) }
                cell.configCell(model: model, isCheckmark: self.viewModel.isCheckmark(subFilterId: model.id))
                return cell
        })
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }
        
        viewModel.filterActionDelegate?.sectionSubFiltersEvent()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
    
    private func bindSelection(){
        
        tableView.rx.itemSelected
            .subscribe(onNext: {[weak self] indexPath  in
                let cell = self!.tableView.cellForRow(at: indexPath) as! SubFilterSectionCell
                
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
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? SubFilterSectionCell {
                        if ids.contains(cell.id) {
                            cell.selectCell()
                        }
                    }
                }
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
}


// Waiting Indicator
extension SubFilterSectionVC {
    
    
    private func showAlert(text: String){
        let alert = UIAlertController(title: "Ошибка", message: text, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Отмена", style: .default) { (_) -> Void in
        }
        let refreshAction = UIAlertAction(title: "Обновить снова", style: .default) { (_) -> Void in
            self.viewModel.filterActionDelegate?.refreshFromSubfilter()
        }
        alert.addAction(cancelAction)
        alert.addAction(refreshAction)
        
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
        
        viewModel.filterActionDelegate?.wait()
            .filter({[.enterSubFilter].contains($0.0)})
            .takeWhile({$0.1 == true})
            .subscribe(
                onNext: {[weak self] res in
                    let delay = res.2
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)){
                        guard let `self` = self else {return}
                        Timer.scheduledTimer(timeInterval: waitForSubfiltersTimeoutInSec, target: self, selector: #selector(self.internalWaitControl), userInfo: nil, repeats: false)
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
        tableView.isHidden = false
        waitContainer.alpha = 0.0
        waitContainer.isHidden = true
        waitActivityView.stopAnimating()
    }
}





extension SubFilterSectionVC: UITableViewDelegate {
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            viewModel.backEvent.onCompleted()
        }
    }
}
