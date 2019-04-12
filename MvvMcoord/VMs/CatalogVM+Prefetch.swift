import Foundation
import RxSwift
import RxCocoa
import Kingfisher



extension CatalogVM {
    
    func prefetchItemAt(indexPaths: [IndexPath]) {
        guard let firstIdx = indexPaths.first else { return }
        
        guard imgLastPrefetchedIdx <= firstIdx.row + imgStartLoadWhenScrollTo else { return }
        let from = imgLastPrefetchedIdx
        imgLastPrefetchedIdx = from + imgBatchLoad
        let to = imgLastPrefetchedIdx
            
            
        print("cur: \(indexPaths.first)    from: \(from)    to: \(to)")
        DispatchQueue.global(qos: .userInteractive).async {[weak self] in
            
            guard let `self` = self else { return }
            
                let arr = Array(from...to)
        
                let sum: Float = Float(indexPaths.count)
                var cnt:Float = 0
                for idx in arr {

                    usleep(useconds_t(imgSleepBetweenRequestsInMS * 1000))
                    
                    cnt += 1
                    let priority = (sum - cnt)/sum
                    
                    DispatchQueue.main.async {
                        if let model = self.catalog(at: idx) {
                            self.downloadIf_ModelExists(model: model, priority)
                        } else {
                            print("No Model at \(idx)")
                        }
                    }
                }
        }
    }
    
    
    
    private func downloadIf_ModelExists(model: CatalogModel, _ priority: Float){
        if let url = model.thumbnailURL {
            let imageView = UIImageView()
            imageView.kf.setImage(with: URL(string: url),
                                  placeholder: nil,
                                  options: [.downloadPriority(1), .fromMemoryCacheOrRefresh],
                                  progressBlock: nil,
                                  completionHandler: nil)
        } else {
            
            storage.reference(forURL: getCatalogImage(picName: model.thumbnail)).downloadURL(completion: {(url, error)in
                if let err = error {
                    //  print("PrefetchItemAt: \(err.localizedDescription)")
                    return
                }
                guard let url = url else {
                    return
                }
                print("download at prefetch!!!")
                model.thumbnailURL = url.absoluteString
                let img = UIImageView()
                img.kf.setImage(with: URL(string: url.absoluteString),
                                placeholder: nil,
                                options: [.downloadPriority(priority), .fromMemoryCacheOrRefresh],
                                progressBlock: nil,
                                completionHandler: nil)
            })
        }
    }
    
    
    
    func downloadImage(indexPath: IndexPath, completion: ((String)->Void)? = nil) {
        if let model = self.catalog(at: indexPath.row),
            let url = model.thumbnailURL {
            completion?(url)
        }
    }
    
    
}
