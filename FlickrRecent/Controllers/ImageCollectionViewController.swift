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
            #selector(ImageCollectionViewController.refreshRecentFlickrPhotos(_:)),
                                 for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    
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
    // compute the scroll value and play witht the threshold to get desired effect
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let THRESHOLD: Float = 50.0
        
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let frameHeight = scrollView.bounds.size.height;
        
        let heightDelta = contentHeight - contentOffset;
        let triggerThreshold  = min( (Float( heightDelta - frameHeight) / THRESHOLD) , 0.0)
        let viewPulled = min(fabs(triggerThreshold),1.0);
        
        self.footerView?.setTransform(inTransform: CGAffineTransform.identity, scaleFactor: CGFloat(viewPulled))
        
        if viewPulled >= 1 {
            self.footerView?.animateFinal()
        }
    }
    

    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Check if user is trying to load more images
        let DISTANCE_FROM_BOTTOM: CGFloat = 35.0
        
        let contentOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.bounds.size.height
        
        let heightDelta = contentHeight - contentOffset
        let pullHeight  = fabs(heightDelta - frameHeight)
        
        if pullHeight <= DISTANCE_FROM_BOTTOM {
            // User is trying to load more images, so load them
            if (self.footerView?.isAnimatingFinal)! {
                self.loadingNextPage = true
                self.footerView?.startAnimate()
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer:Timer) in
                    self.loadNextPageOfFlickrResults()
                })
            }
        }
    }


    // MARK: - Helper Methods
    
    /**
     Function to be called when user pulls down to refresh
     - Parameter refreshControl: refresh control to initiate CollectionView refresh
     */
    @objc func refreshRecentFlickrPhotos(_ refreshControl: UIRefreshControl) {
        
        self.updateRecentPhotos()
        refreshControl.endRefreshing()
    }
    
    /// Helper Function to download recent photos uploaded to Flickr
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
    
    /// Helper function to reload the Collection View and update header information
    fileprivate func reload() {
        self.collectionView?.reloadData()
        if let total = self.previousFlickrResponses[0].totalResults {
            self.numResults = total
        }
    }

    /// Helper function to download the next page of results for current Flickr API query
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



