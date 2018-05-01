//
//  ImageCollectionViewController.swift
//  FlickrRecent
//
//  Created by Alice Newman on 29/4/18.
//  Copyright © 2018 Nicholas Moignard. All rights reserved.
//

import UIKit
import SDWebImage


class ImageCollectionViewController: UICollectionViewController {
    let networkManager = FlickrNetworkManager()
    
    
    fileprivate let reuseIdentifier = "pink"
    /// Set padding size around images
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate var previousSearches: [FlickrSearchResults] = []
    fileprivate let itemsPerRow: CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkManager.searchFlickr("dad") {
            results, error in
            if let results = results {
                self.previousSearches.insert(results, at: 0)
                self.collectionView?.reloadData()
                
                
                for photo in results.searchResults {
                    print(photo.title, photo.photoID)
                }
                
            }
            
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if previousSearches.count >= 1 {
            return previousSearches[0].searchResults.count
        } else {
            return 0
        }
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pink", for: indexPath)
        
        let flickrPhoto = previousSearches[0].searchResults[indexPath.row]
        
        let pinkCell = collectionView.dequeueReusableCell(withReuseIdentifier: "pink", for: indexPath) as! FlickrPhotoCollectionViewCell
        pinkCell.backgroundColor = UIColor.white
        pinkCell.layer.cornerRadius = 10
        
        if let url = flickrPhoto.photoURL() {
            pinkCell.imageView.sd_setImage(with: URL(string: url.absoluteString), placeholderImage: UIImage(named: "placeholder.png"))
        } else {
            print("Image URL Error")
        }
        
        pinkCell.titleLabel.text = flickrPhoto.title
    
        return pinkCell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension ImageCollectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        
        networkManager.searchFlickr(textField.text!) {
            results, error in
            activityIndicator.removeFromSuperview()
            
            if let error = error {
                print("error encounted \(error)")
                return
            }
            
            if let results = results {
                self.previousSearches.insert(results, at: 0)
                self.collectionView?.reloadData()
                
   
                for photo in results.searchResults {
                    print(photo.title, photo.photoID)
                }

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



