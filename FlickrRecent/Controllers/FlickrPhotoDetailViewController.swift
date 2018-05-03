import UIKit

class FlickrPhotoDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var flickrPhoto: FlickrPhoto?
    
    // MARK: - Data Members
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    // MARK: - View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        if let photo = flickrPhoto {
            setupView(photo)
        }
    }
    
    // MARK: - Pinch to zoom implementation
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    fileprivate func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
    }
    
    
    // MARK: - Helper Methods
    fileprivate func setupView(_ photo: FlickrPhoto) {
        if let url = photo.photoURL(.L) {
            self.imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder.png"))
        }
        
        self.ownerLabel.text = photo.ownerName
        self.descriptionTextView.text = photo.description
        self.viewsLabel.text = "\(photo.views)"
        self.navigationItem.title = photo.title
        
    }
}

