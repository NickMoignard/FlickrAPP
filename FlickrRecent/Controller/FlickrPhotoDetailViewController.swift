import UIKit

class FlickrPhotoDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var flickrPhoto: FlickrPhoto?
    
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        
        if let photo = flickrPhoto, let url = photo.photoURL(.L) {
            imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder.png"))
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
        }
    }

}

