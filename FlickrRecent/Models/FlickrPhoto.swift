import UIKit

/// Data Structure for photos returned from the Flickr API
struct FlickrPhoto {
    
    // MARK: Data Members
    let photoID: String,
        farm: Int,
        server: String,
        secret: String
    
    var isFriend: Int,
        ownerID: String,
        title: String,
        isFamily: Int,
        description: String,
        dateTaken: Date?,
        ownerName: String,
        views: Int,
        latitude: Float,
        longitude: Float,
        isPublic: Int
    
    // MARK: Methods
    init (photoID: String, farm: Int, server: String, secret: String, dateTaken: Date? = nil, isFriend: Int = 0, ownerID: String = "", title: String = "", isFamily: Int = 0, description: String = "", ownerName: String = "", views: Int = 0, latitude: Float = 0.0, longitude: Float = 0.0, isPublic: Int = 1) {
        self.photoID = photoID
        self.farm = farm
        self.server = server
        self.secret = secret
        self.isFriend = isFriend
        self.ownerID = ownerID
        self.title = title
        self.isFamily = isFamily
        self.description = description
        self.dateTaken = dateTaken
        self.ownerName = ownerName
        self.views = views
        self.latitude = latitude
        self.longitude = longitude
        self.isPublic = isPublic
    }
    
    /**
    Create URL to download flickr photo
     - Parameter size: The size of image to download. Defaults to small size (240 px max length).
     - Returns: URL of flickr photo
    */
    public func photoURL(_ size: FlickrImageSize =  .S) -> URL? {
        if let url = URL(string: "https://farm\(self.farm).staticflickr.com/\(self.server)/\(self.photoID)_\(self.secret)_\(size.rawValue).jpg") {
            return url
        }
        return nil
    }
    
    
    /**
    Convert the Flickr Photo's date taken object to a string for displaying to a user
     - Returns: the photos date of capture as a string
    */
    public func dateTakenString() -> String? {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        
        if let dateTaken = dateTaken {
            return formatter.string(from: dateTaken)
        } else {
            return nil
        }
        
    }
}
