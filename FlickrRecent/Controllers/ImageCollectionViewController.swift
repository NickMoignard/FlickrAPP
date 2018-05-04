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
    
    /// Refresh Control object to update collection view with most recent photos uploaded to Flickr
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ImageCollectionViewController.refreshRecentFlickrPhotos(_:)),
                                 for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    // MARK: - View Controller Methods
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
        
        // Remove previous search results and extraneous photos from view
        if var currentResponse = self.previousFlickrResponses.first {
            if currentResponse.photos != nil {
                let numToRemove = currentResponse.photos!.count - 20
                currentResponse.photos!.removeFirst(numToRemove)
            }
            
            self.previousFlickrResponses.removeAll()
            self.previousFlickrResponses.append(currentResponse)
        }
        self.reload()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass Flickr Photo to destination view controller
        if segue.identifier == "ShowFlickrPhoto" {
            let vc = segue.destination as! FlickrPhotoDetailViewController
            let cell = sender as! FlickrPhotoCollectionViewCell
            if let indexPath = self.collectionView?.indexPath(for: cell) {
                vc.flickrPhoto = previousFlickrResponses[0].photos![indexPath.row]
            }
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    // Search Flickr for a given search term if user presses enter inside the search bar text field
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        textField.placeholder = ""
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        
        // Search Flickr
        networkManager.searchFlickr(textField.text!) {
            response in
            activityIndicator.removeFromSuperview()
            textField.placeholder = "Search Flickr"
            
            if response != nil {
                // Fill collection view with response data
                if response!.error == nil {
                    self.previousFlickrResponses.insert(response!, at: 0)
                    self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                  at: .top,
                                                  animated: true)
                   self.reload()
                } else {
                    print("Error Searching Flickr")
                    print("Code: \(response!.error!.code), Message: \(response!.error!.message)")
                }
            }
        }
        // Finished searching. so reset
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Collection View Methods
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if previousFlickrResponses[0].photos != nil {
            return previousFlickrResponses[0].photos!.count
        } else {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Setup Flickr Photo Cell
        
        let flickrPhoto = previousFlickrResponses[0].photos![indexPath.row]
        let flickrphotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlickrPhotoCollectionViewCell
        
        flickrphotoCell.backgroundColor = UIColor.white
        flickrphotoCell.layer.cornerRadius = 10
        flickrphotoCell.titleLabel.text = flickrPhoto.ownerName
        
        if let url = flickrPhoto.photoURL() {
            flickrphotoCell.imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder.png"))
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
    
    // MARK: - Loading Activity Indicator Implementation
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let heightOfFooter: CGFloat = 55
        if self.loadingNextPage {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.size.width, height: heightOfFooter)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // Setup Header and Footer for CollectionView
        
        if kind == UICollectionElementKindSectionFooter {
            // User is trying to load more images
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerViewReuseIdentifier, for: indexPath) as! CollectionFooterView
            self.footerView = aFooterView
            self.footerView?.backgroundColor = UIColor.clear
            return aFooterView
        } else {
            // Set information inside the header
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
    
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Check if user is trying view more images
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
        // Check if user pulled hard enough to trigger loading new images
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
            response in
            if response != nil {
                if response!.error == nil {
                    self.previousFlickrResponses.insert(response!, at: 0)
                    self.reload()
                } else {
                    print("Error getting recent photos from Flickr")
                    print("Code: \(response!.error!.code), Message: \(response!.error!.message)")
                }
            }
        }
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
            response in
            if response != nil {
                if response!.error == nil {
                    if let photos = response!.photos {
                        for photo in photos {
                            self.previousFlickrResponses[0].photos!.append(photo)
                        }
                        self.reload()
                        self.loadingNextPage =  false
                    }
                } else {
                    print("Error getting next page of photos from Flickr")
                    print("Code: \(response!.error!.code), Message: \(response!.error!.message)")
                }
            }
        }
    }

}



