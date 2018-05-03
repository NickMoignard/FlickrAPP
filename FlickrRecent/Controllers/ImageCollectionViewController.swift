import UIKit
import SDWebImage

/// Main ViewController Class for application
class ImageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    // MARK: - Data Members
    fileprivate let networkManager = FlickrNetworkManager()
    fileprivate let headerViewReuseIdentifier = "FlickrResultsHeader"
    fileprivate let footerViewReuseIdentifier = "RefreshFooterView"
    fileprivate let reuseIdentifier = "FlickrPhotoCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 20.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 2
    
    fileprivate var footerView: CollectionFooterView?
    fileprivate var previousFlickrResponses: [FlickrResponse] = []
    fileprivate var numResults: Int = 0
    fileprivate var headerTitle: String = "Total results"
    fileprivate var loadingNextPage = false
    
    // MARK: - View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateRecentPhotos()
        self.collectionView?.addSubview(refreshControl)
        
        if let collectionView = self.collectionView {
                
            collectionView.register(UINib(nibName: "CollectionFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerViewReuseIdentifier)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFlickrPhoto" {
            let vc = segue.destination as! FlickrPhotoDetailViewController
            let cell = sender as! FlickrPhotoCollectionViewCell
            if let indexPath = self.collectionView?.indexPath(for: cell) {
                vc.flickrPhoto = previousFlickrResponses[0].photos![indexPath.row]
            }
        }
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
    


    // MARK: - Search Flickr
    // TODO: - Refactor & Comment
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        textField.placeholder = ""
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        
        networkManager.searchFlickr(textField.text!) {
            response, error in
            activityIndicator.removeFromSuperview()
            textField.placeholder = "Search"
            if let error = error {
                print("error encounted \(error)")
                return
            }
            
            if let response = response {
                
                self.previousFlickrResponses.insert(response, at: 0)
                self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                  at: .top,
                                                  animated: true)
                self.reload()
            }
        }
        textField.text = nil
        
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Collection View Methods

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if previousFlickrResponses.count >= 1 {
            return previousFlickrResponses[0].photos!.count
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let flickrPhoto = previousFlickrResponses[0].photos![indexPath.row]
        let flickrphotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlickrPhotoCollectionViewCell
        
        // Setup Cell
        flickrphotoCell.backgroundColor = UIColor.white
        flickrphotoCell.layer.cornerRadius = 10
        flickrphotoCell.titleLabel.text = flickrPhoto.ownerName
        if let url = flickrPhoto.photoURL() {
            flickrphotoCell.imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder.png"))
        } else {
            // TODO: Handle Error
            print("Image URL Error")
        }
        
        return flickrphotoCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Set the size of collection view cells
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let heightOfFooter: CGFloat = 55
        if self.loadingNextPage {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.size.width, height: heightOfFooter)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerViewReuseIdentifier, for: indexPath) as! CollectionFooterView
            self.footerView = aFooterView
            self.footerView?.backgroundColor = UIColor.clear
            return aFooterView
        } else {
            // Setup the header for the CollectionView
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerViewReuseIdentifier, for: indexPath) as! HeaderCollectionReusableView
            headerView.headerTitleLabel.text = "Total results: \(numResults)"
            
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
    // TODO: Refactor and Comment
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

    // MARK: - Helper Methods
    
    fileprivate func setNumberResultsLabel() {
        
    }
    
    fileprivate func updateRecentPhotos() {
        print("Getting recents")
        networkManager.getRecentPhotos {
            results, error in
            if let results = results {
                self.previousFlickrResponses.insert(results, at: 0)
                self.reload()
            } else {
                print("Error getting recent photos")
            }
        }
        // TODO: - Error Handling
    }
    
    fileprivate func reload() {
        self.collectionView?.reloadData()
        if let total = self.previousFlickrResponses[0].totalResults {
            self.numResults = total
        }
    }
    
    fileprivate func loadNextPageOfFlickrResults() {
        networkManager.getNextPageOfResults {
            response, error in
            if let response = response, let responsePhotos = response.photos {
                for photo in responsePhotos {
                    self.previousFlickrResponses[0].photos!.append(photo)
                }
                self.collectionView?.reloadData()
                self.loadingNextPage =  false
            } else {
                // TODO: Handle Error
            }
        }
    }
}



