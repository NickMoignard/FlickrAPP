import UIKit


struct FlickrPhoto {
    
    let photoID: String,
        farm: Int,
        server: String,
        secret: String,
        isFriend: Int,
        owner: String,
        title: String

    
    let networkManager = FlickrNetworkManager()
    
    init (photoID:String,farm:Int, server:String, secret:String, isFriend: Int = 0, owner: String = "", title:String = "") {
        self.photoID = photoID
        self.farm = farm
        self.server = server
        self.secret = secret
        self.isFriend = isFriend
        self.owner = owner
        self.title = title
    }
    
    func downloadImage(_ size: FlickrImageSize =  .medium, completion: (UIImage?, NSError?) -> Void) {
         
    }
    
    // MARK: - HELPER METHODS
    
    /**
    Create URL to download flickr photo
     - Parameter size: The size of image to download. Defaults to medium.
     - Returns : URL of flickr photo
    */
    func photoURL(_ size: FlickrImageSize =  .medium) -> URL? {
        if let url = URL(string: "https://farm\(self.farm).staticflickr.com/\(self.server)/\(self.photoID)_\(self.secret)_\(size.rawValue).jpg") {
            return url
        }
        return nil
    }
    
}

// TODO: fill in different sizes
enum FlickrImageSize: String {
    case medium = "m"
    case large = "b"
}

/*
class FlickrPhoto : Equatable {
  var thumbnail : UIImage?
  var largeImage : UIImage?
  let photoID : String
  let farm : Int
  let server : String
  let secret : String
  
  init (photoID:String,farm:Int, server:String, secret:String) {
    self.photoID = photoID
    self.farm = farm
    self.server = server
    self.secret = secret
  }
  
  func flickrImageURL(_ size:String = "m") -> URL? {
    if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg") {
      return url
    }
    return nil
  }
  
  func loadLargeImage(_ completion: @escaping (_ flickrPhoto:FlickrPhoto, _ error: NSError?) -> Void) {
    guard let loadURL = flickrImageURL("b") else {
      DispatchQueue.main.async {
        completion(self, nil)
      }
      return
    }
    
    let loadRequest = URLRequest(url:loadURL)
    
    URLSession.shared.dataTask(with: loadRequest, completionHandler: { (data, response, error) in
      if let error = error {
        DispatchQueue.main.async {
          completion(self, error as NSError?)
        }
        return
      }
      
      guard let data = data else {
        DispatchQueue.main.async {
          completion(self, nil)
        }
        return
      }
      
      let returnedImage = UIImage(data: data)
      self.largeImage = returnedImage
      DispatchQueue.main.async {
        completion(self, nil)
      }
    }).resume()
  }
  
  func sizeToFillWidthOfSize(_ size:CGSize) -> CGSize {
    
    guard let thumbnail = thumbnail else {
      return size
    }
    
    let imageSize = thumbnail.size
    var returnSize = size
    
    let aspectRatio = imageSize.width / imageSize.height
    
    returnSize.height = returnSize.width / aspectRatio
    
    if returnSize.height > size.height {
      returnSize.height = size.height
      returnSize.width = size.height * aspectRatio
    }
    
    return returnSize
  }
  
}

func == (lhs: FlickrPhoto, rhs: FlickrPhoto) -> Bool {
  return lhs.photoID == rhs.photoID
}
*/
