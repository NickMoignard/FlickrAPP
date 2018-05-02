import UIKit

struct FlickrPhoto {
    
    let photoID: String,
        farm: Int,
        server: String,
        secret: String
    
    var isFriend: Int,
        ownerID: String,
        title: String,
        isFamily: Int,
        description: String,
        dateTaken: Date,
        ownerName: String,
        views: Int,
        latitude: Float,
        longitude: Float,
        isPublic: Int
    
    
    let networkManager = FlickrNetworkManager()
    
    init (photoID: String, farm: Int, server: String, secret: String, dateTaken: Date = Date(), isFriend: Int = 0, ownerID: String = "", title: String = "", isFamily: Int = 0, description: String = "", ownerName: String = "", views: Int = 0, latitude: Float = 0.0, longitude: Float = 0.0, isPublic: Int = 1) {
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
     - Returns : URL of flickr photo
     
     "id": "26951308767", "owner": "145240996@N07", "secret": "54a791555c", "server": "864", "farm": 1, "title": "Taiwan 2018", "ispublic": 1, "isfriend": 0, "isfamily": 0,
     "description": { "_content": "" }, "datetaken": "2018-04-27 16:56:54", "datetakengranularity": 0, "datetakenunknown": 0, "ownername": "galaxy07092003", "views": 0, "latitude": 0, "longitude": 0, "accuracy": 0, "context": 0 },
     
    */
    func photoURL(_ size: FlickrImageSize =  .S) -> URL? {
        if let url = URL(string: "https://farm\(self.farm).staticflickr.com/\(self.server)/\(self.photoID)_\(self.secret)_\(size.rawValue).jpg") {
            return url
        }
        return nil
    }
    
}

enum FlickrImageSize: String {
    case smallSquare = "s"
    case largeSquare = "q"
    case thumbnail = "t"
    case XXS = "m"
    case S = "n"
    case M = "z"
    case L = "c"
    case XL = "b"
    case XXL = "h"
    case XXXL = "k"
    case original = "o"
}

