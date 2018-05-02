

import UIKit
import SDWebImage


class ImageCollectionViewController: UICollectionViewController {
    let networkManager = FlickrNetworkManager()
    let headerViewReuseIdentifier = "FlickrResultsHeader"
    let footerViewReuseIdentifier = "RefreshFooterView"
    var headerTitle: String = "Recent uploads"
    var numResults: Int = 0
    var footerView: CollectionFooterView?
    fileprivate let reuseIdentifier = "pink"
    fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 20.0, right: 20.0)
    
    
    fileprivate var previousFlickrResults: [FlickrResults] = []

    
    
    fileprivate let itemsPerRow: CGFloat = 2
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateRecentPhotos()
        self.collectionView?.addSubview(refreshControl)
        
        
        
        if let collectionView = self.collectionView {
                
            collectionView.register(UINib(nibName: "CollectionFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerViewReuseIdentifier)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    
    // MARK: - Refresh Control
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ImageCollectionViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        self.updateRecentPhotos()
        refreshControl.endRefreshing()
    }
    
    var loadingNextPage = false
    


    // MARK: - Navigation

   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFlickrPhoto" {
            let vc = segue.destination as! FlickrPhotoDetailViewController
            let cell = sender as! FlickrPhotoCollectionViewCell
            if let indexPath = self.collectionView?.indexPath(for: cell) {
                vc.flickrPhoto = previousFlickrResults[0].searchResults[indexPath.row]
            }
        }
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if previousFlickrResults.count >= 1 {
            return previousFlickrResults[0].searchResults.count
        } else {
            return 0
        }
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        
        let flickrPhoto = previousFlickrResults[0].searchResults[indexPath.row]
        
        let pinkCell = collectionView.dequeueReusableCell(withReuseIdentifier: "pink", for: indexPath) as! FlickrPhotoCollectionViewCell
        pinkCell.backgroundColor = UIColor.white
        pinkCell.layer.cornerRadius = 10
        
        if let url = flickrPhoto.photoURL() {
            pinkCell.imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder.png"))
        } else {
            print("Image URL Error")
        }
        
        pinkCell.titleLabel.text = flickrPhoto.ownerName
    
        return pinkCell
    }

    // MARK: - HELPERS
    
    fileprivate func updateRecentPhotos() {
        print("Getting recents")
        networkManager.getRecentPhotos {
            results, error in
            if let results = results {
                self.previousFlickrResults.insert(results, at: 0)
                self.collectionView?.reloadData()
            } else {
                print("Error getting recent photos")
            }
        }
        // TODO: - Error Handling
    }
    fileprivate func loadNextPageOfFlickrResults() {

        
        
            networkManager.getNextPageOfResults {
                results, error in
                if let results = results {
                    self.previousFlickrResults[0].searchResults.append(contentsOf: results.searchResults)
                    self.collectionView?.reloadData()
                    self.loadingNextPage =  false
                } else {
                    print("Error getting recent photos")
                }
            }
        
    }
    

    
    
}

extension ImageCollectionViewController {
    
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.loadingNextPage {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.size.width, height: 55)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerViewReuseIdentifier, for: indexPath) as! CollectionFooterView
            self.footerView = aFooterView
            self.footerView?.backgroundColor = UIColor.clear
            return aFooterView
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerViewReuseIdentifier, for: indexPath) as! HeaderCollectionReusableView
            headerView.headerTitleLabel.text = headerTitle
            headerView.numResultsLabel.text = "\(numResults)"
            
            return headerView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionFooter {
            self.footerView?.prepareInitialAnimation()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionFooter {
            self.footerView?.stopAnimate()
        }
    }
    
    //compute the scroll value and play witht the threshold to get desired effect
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold   = 50.0 ;
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        var triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold);
        triggerThreshold   =  min(triggerThreshold, 0.0)
        let pullRatio  = min(fabs(triggerThreshold),1.0);
        self.footerView?.setTransform(inTransform: CGAffineTransform.identity, scaleFactor: CGFloat(pullRatio))
        if pullRatio >= 1 {
            self.footerView?.animateFinal()
        }
        print("pullRatio:\(pullRatio)")
    }
    
    //compute the offset and call the load method
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let DISTANCE_FROM_BOTTOM: CGFloat = 35.0
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        let pullHeight  = fabs(diffHeight - frameHeight);
        if pullHeight <= DISTANCE_FROM_BOTTOM
        {
            if (self.footerView?.isAnimatingFinal)! {
                print("load more trigger")
                self.loadingNextPage = true
                self.footerView?.startAnimate()
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer:Timer) in
                    self.loadNextPageOfFlickrResults()
                })
            }
        }
    }
}


extension ImageCollectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        textField.placeholder = ""
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        
        networkManager.searchFlickr(textField.text!) {
            results, error in
            activityIndicator.removeFromSuperview()
            textField.placeholder = "Search"
            if let error = error {
                print("error encounted \(error)")
                return
            }
            
            if let results = results {
                self.previousFlickrResults.insert(results, at: 0)
                self.collectionView?.reloadData()
            }
        }
        textField.text = nil
        
        textField.resignFirstResponder()
        return true
    }
}

extension ImageCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}



