import Foundation
import UIKit

/// Loading more results footer class for Main CollectionView
class CollectionFooterView : UICollectionReusableView {

    @IBOutlet var refreshControlIndicator: UIActivityIndicatorView!
    
    public var isAnimatingFinal:Bool = false
    fileprivate var currentTransform: CGAffineTransform?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareInitialAnimation()
    }
    
    /**
    something
     - Parameter inTransform:
     - Parameter scaleFactor:
    */
    public func setTransform(inTransform: CGAffineTransform, scaleFactor: CGFloat) {
        if isAnimatingFinal { return }
        self.currentTransform = inTransform
        self.refreshControlIndicator?.transform = CGAffineTransform.init(scaleX: scaleFactor, y: scaleFactor)
    }
    
    /// Reset loading spinner animation
    public func prepareInitialAnimation() {
        self.isAnimatingFinal = false
        self.refreshControlIndicator?.stopAnimating()
        self.refreshControlIndicator?.transform = CGAffineTransform.init(scaleX: 0.0, y: 0.0)
    }
    
    
    /// Start animating the loading spinner
    public func startAnimate() {
        self.isAnimatingFinal = true
        self.refreshControlIndicator?.startAnimating()
    }
    
    
    /// Stop animating the loading spinner
    public func stopAnimate() {
        self.isAnimatingFinal = false
        self.refreshControlIndicator?.stopAnimating()
    }
    
    ///
    public func animateFinal() {
        if isAnimatingFinal { return }
        self.isAnimatingFinal = true
        UIView.animate(withDuration: 0.2) {
            self.refreshControlIndicator?.transform = CGAffineTransform.identity
        }
    }
}
