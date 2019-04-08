import UIKit
import RxCocoa
import RxSwift

class CatalogVC: UIViewController {
    
    var viewModel: CatalogVM!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var currPage: UILabel!
    
    var bag = DisposeBag()
    var collectionDisposable: Disposable?
    
    private var cellLayout: CellLayoutEnum = .list
    private var cellHeight: CGFloat = 100.0
    private var cellWidth: CGFloat = 100.0
    private var cellSpace: CGFloat = 0.0
    private var lineSpace: CGFloat = 0.0
    private var planButtonImage = ""
    private var timer: Timer?
    internal let waitContainer: UIView = UIView()
    internal let waitActivityView = UIActivityIndicatorView(style: .whiteLarge)
    
    var itemCount = 0
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        uitCurrMemVCs += 1 // uitest
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFlowLayout()
        setTitle()
       // collectionView.prefetchDataSource = self
        collectionView.isHidden = true
        handleReloadEvent()
        handleWaitEvent()
        handleFetchStartEvent() // added test
        handleFetchCompleteEvent()
        bindNavigation()
        bindLayout()
        //self.collectionView.decelerationRate = UIScrollView.DecelerationRate.normal
    }

    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }
    
    
    deinit {
        print("Catalog VC deinit")
        uitCurrMemVCs -= 1 // uitest
    }
    
    private func setFlowLayout(){
        if let collectionViewFlowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewFlowLayout.minimumInteritemSpacing = 0
        }
    }
    
    
    private func setTitle(){
        var title = viewModel.outTitle.value
        if (title.isEmpty) {
            title = "Каталог"
        }
        let navLabel = UILabel()
        let navTitle = NSMutableAttributedString(string: title, attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.light)])
        
        navLabel.attributedText = navTitle
        self.navigationItem.titleView = navLabel
        self.navigationItem.titleView?.accessibilityIdentifier = "My"+String(uitCurrMemVCs)
    }
    
    
    private func handleReloadEvent(){
        viewModel.outReloadCatalogVC
            .filter({$0 == true})
            .subscribe(onNext: {[weak self] _ in
                self?.collectionView.isHidden = false
                self?.collectionView.reloadData()
            })
            .disposed(by: bag)
    }
    
    
    private func handleFetchStartEvent(){
        viewModel.outFetchStart
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else {return}
                self.itemCount = 0
                self.changeCurrPage()
            })
            .disposed(by: bag)
    }
    
    private func changeCurrPage(){
        let totalP = self.viewModel.totalPages == 0 ? 1: self.viewModel.totalPages + 1
        let currP = self.viewModel.currentPage < 0 ? 1 : self.viewModel.currentPage + 1
        self.currPage.text = "\(currP)/\( totalP)"
    }
    
    
    private func handleFetchCompleteEvent(){
        viewModel.outFetchComplete
            .subscribe(onNext: {[weak self] indexPaths_ in
                guard let `self` = self else {return}
                guard let indexPaths = indexPaths_ else { return }
                self.collectionView.performBatchUpdates({
                    if indexPaths.count < 20 {
                        print("err: \(indexPaths.count)")
                    }
                    self.itemCount += indexPaths.count
                    self.collectionView.insertItems(at: indexPaths)
                })
            })
            .disposed(by: bag)
    }
    
    
    private func bindLayout(){
        planButton.rx.tap
            .bind{[weak self] _ -> Void in
                self?.viewModel.inPressLayout.value = Void()}
            .disposed(by: bag)
        
        
        filterButton.rx.tap
            .bind{[weak self] _ -> Void in
                self?.viewModel.inPressFilter.onNext(Void())
            }
            .disposed(by: bag)
        
        
        viewModel.outLayout
            .asObservable()
            .subscribe(onNext: {[weak self] cellLayout in
                guard let layout = cellLayout else { return }
                guard let `self` = self else {return}
                
                self.cellHeight = layout.cellScale.height  *  self.collectionView.frame.height
                self.cellWidth = layout.cellScale.width *  self.collectionView.frame.width - layout.cellSpace
                self.planButton.setImage(UIImage(named: layout.layoutImageName), for: .normal)
                self.cellLayout = layout.cellLayoutType
                self.collectionView.reloadData()
            })
            .disposed(by: bag)
    }
    
    
    public func bindNavigation() {
        viewModel.outCloseVC
            .take(1)
            .subscribe{[weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: bag)
    }
}




extension CatalogVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("itemCOUNT: \(itemCount)")
        return itemCount //viewModel.totalItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: UICollectionViewCell!
        
        if isLoadingCell2(for: indexPath) {
            viewModel.emitPrefetchEvent()
            changeCurrPage()
        }
        
        switch cellLayout {
            case .list:
                let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCellList", for: indexPath) as! CatalogListCell
                cell1.tag = indexPath.row
                if isLoadingCell(for: indexPath) {
                    cell1.configCell(model: nil, indexPath: indexPath)
                } else {
                    if let model = viewModel.catalog(at: indexPath.row) {
                        cell1.configCell(model: model, indexPath: indexPath)
                    } else {
                        cell1.configCell(model: nil, indexPath: indexPath)
                    }
                }
                cell = cell1
            case .square:
                let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCellSquare", for: indexPath) as! CatalogSquareCell
                cell1.tag = indexPath.row
                if isLoadingCell(for: indexPath) {
                    cell1.configCell(model: nil, indexPath: indexPath)
                } else {
                    if let model = viewModel.catalog(at: indexPath.row) {
                        cell1.configCell(model: model, indexPath: indexPath)
                    } else {
                        cell1.configCell(model: nil, indexPath: indexPath)
                    }
                }
                cell = cell1
            case .squares:
                let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCellSquares", for: indexPath) as! CatalogSquaresCell
                cell1.tag = indexPath.row
                if isLoadingCell(for: indexPath) {
                    cell1.configCell(model: nil, indexPath: indexPath)
                } else {
                    if let model = viewModel.catalog(at: indexPath.row) {
                        cell1.configCell(model: model, indexPath: indexPath)
                    } else {
                        cell1.configCell(model: nil, indexPath: indexPath)
                    }
                }
                cell = cell1
        }
        return cell
    }
}




extension CatalogVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return sectionInset
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            viewModel.backEvent.onNext(.back)
        }
    }
    
}

private extension CatalogVC {
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= viewModel.currItemsCount()
    }
    
    
    func isLoadingCell2(for indexPath: IndexPath) -> Bool {
        if viewModel.currItemsCount() == 0 {
            return false
        }
        return indexPath.row >= viewModel.currItemsCount()-1
    }
    
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath])->[IndexPath]{
        let indexPathsForVisibleRows = collectionView.indexPathsForVisibleItems 
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}



// Waiting Indicator
extension CatalogVC {
    
    public func handleWaitEvent(){
        waitContainer.frame = CGRect(x: view.center.x, y: view.center.y, width: 80, height: 80)
        waitContainer.backgroundColor = .lightGray
        waitContainer.center = self.view.center
        waitActivityView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        waitContainer.isHidden = true
        waitActivityView.hidesWhenStopped = true
        waitContainer.addSubview(waitActivityView)
        view.addSubview(waitContainer)
        
        // reusable wait
        viewModel.wait()
            .filter({[.prefetchCatalog, .applyFilter].contains($0.0)})
            .subscribe(
            onNext: {[weak self] res in
                guard let `self` = self else {return}
                if res.1 == true {
                    self.waitContainer.alpha = 1.0
                    let delay = res.2
                    self.timer = Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(self.internalWaitControl), userInfo: nil, repeats: false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)){[weak self] in
                        self?.startWait()
                    }
                } else {
                    self.stopWait()
                }
            },
            onCompleted: {
                 self.timer?.invalidate() //!!!
            })
            .disposed(by: bag)
    }
    
    
    private func startWait() {
        guard waitContainer.alpha == 1.0 else { return }
        UIView.animate(withDuration: 0.7,
                       animations: {[weak self] in
                        self?.collectionView.alpha = 0.0
        },
                       completion: {[weak self] _ in
                        self?.collectionView.isHidden = true
        })
        waitContainer.isHidden = false
        waitActivityView.startAnimating()
    }
    
    private func stopWait(){
        self.waitContainer.alpha = 0.0
        UIView.animate(withDuration: 1.5, animations: {[weak self] in
            self?.collectionView.alpha = 1.0
            self?.collectionView.isHidden = false
        })
        waitContainer.isHidden = true
        waitActivityView.stopAnimating()
    }
    
    private func showAlert(text: String){
        let alert = UIAlertController(title: "Ошибка", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func internalWaitControl() {
        if waitActivityView.isAnimating {
            if viewIfLoaded?.window != nil {
                showAlert(text: "Ошибка сетевого запроса.")
            }
            timer?.invalidate()
            stopWait()
        }
    }
}
