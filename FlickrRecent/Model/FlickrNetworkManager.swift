import Foundation
import Alamofire
import SwiftyJSON
import SDWebImage

fileprivate let api_key = "f0d860b368002ba704051a7b742166ee"
fileprivate let secret = "d0176a1e2ac288b5"

///
class FlickrNetworkManager {
    
    let dateFormatter = DateFormatter()
    var lastURL: URL? = nil
    
    /**
    Get images from Flickr given a search term
     - Parameter searchTerm :"yyyy-MM-dd' 'HH:mm:ss"
     - Parameter completion :
     - Parameter results :
     - Parameter error :
    */
    func searchFlickr(_ searchTerm: String, completion: @escaping (_ results: FlickrResults?, _ error: NSError?) -> Void) {
        if let url = createURL(searchTerm: searchTerm) {
            Alamofire.request(url).responseData {
                data in
                
                if let photos = self.parseFlickrPhotosResponse(data) {
                    let searchResults = FlickrResults(searchTerm: searchTerm, searchResults: photos)
                    self.lastURL = url
                    completion(searchResults, nil)
                } else {
                    print("Error")
                    // TODO: - Error Handling
                    completion(nil, NSError(domain: "DAD", code: 69, userInfo: nil) )
                }
            }
        } else {
            print("eRror")
        }
    }
    
    // TODO: - Comment this
    func getRecentPhotos(completion: @escaping (_ results: FlickrResults?, _ error: NSError? ) -> Void ) {
        if let url = createURL() {
            Alamofire.request(url).responseData {
                data in
                
                if let photos = self.parseFlickrPhotosResponse(data) {
                    let results = FlickrResults(searchTerm: "Recents", searchResults: photos)

                    self.lastURL = url
                    self.getNextPageOfResults {
                        _, _ in
                        print("DADDY")
                    }
                    completion(results, nil)
                } else {
                    // TODO: - Error handling
                    completion(nil, NSError(domain: "Recent Photos", code: 420, userInfo: nil))
                }
            }
        }
    }
    
    func getNextPageOfResults(completion: @escaping (_ results: FlickrResults?, _ error: NSError? ) -> Void ) {
        if let oldURL = self.lastURL, let url = self.incrementPageNumberInURL(oldURL) {
            Alamofire.request(url).responseData {
                data in
                if let photos = self.parseFlickrPhotosResponse(data) {
                    let results = FlickrResults(searchTerm: "NextPage", searchResults: photos)
                    self.lastURL = url
                    completion(results, nil)
                } else {
                    // TODO: - Error handling
                    completion(nil, NSError(domain: "Recent Photos", code: 420, userInfo: nil))
                }
            }
        } else {
            // could not create url for next page of results
            completion(nil, NSError(domain: "Recent Photos", code: 420, userInfo: nil))
        }
    }
    
    // MARK: - HELPER METHODS
    
    
    
    // TODO: - TIDY AND COMMENT WHAT ABOUT MORE THAN ONE DIGIT!!!!
    fileprivate func incrementPageNumberInURL(_ url: URL) -> URL? {
        var urlString = url.absoluteString
        if let range = urlString.range(of: "page=") {
            let i = range.upperBound
            let pageNumChar = String( urlString.remove(at: urlString.index(i, offsetBy: 0)) )
            let nextPageNum = Int(pageNumChar)! + 1
            let nextPage = Character(String(nextPageNum))
            urlString.insert(nextPage, at: i)
            if let returnURL = URL(string: urlString) {
                return returnURL
            }
        }
        return nil
    }
    
    /**
    */
    fileprivate func parseFlickrPhotosResponse(_ data: DataResponse<Data>) -> [FlickrPhoto]? {
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        
        
        var returnArray: [FlickrPhoto] = []
        if let data = data.data {
            let json = JSON(data:data)
            if let resultsDict = json["photos"].dictionary, let photosJSON = resultsDict["photo"], let photos = photosJSON.array {
                for photo in photos {
                    
                    var flickrPhoto: FlickrPhoto
                    
                    if let photoID = photo["id"].string,
                        let farm = photo["farm"].int,
                        let server = photo["server"].string,
                        let secret = photo["secret"].string {
                        
                        flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, server: server, secret: secret)
                        
                        
                        if let viewsString = photo["views"].string, let views = Int(viewsString) {
                            flickrPhoto.views = views
                        }
                        
                        if let ownerName = photo["ownername"].string,
                            let title = photo["title"].string
                        {
                            flickrPhoto.ownerName = ownerName
                            flickrPhoto.title = title
                        }
                        
                        if let descriptionDict = photo["description"].dictionary,
                            let descriptionContent = descriptionDict["_content"],
                            let description = descriptionContent.string
                        {
                            flickrPhoto.description = description
                        }
                        
                        if let dateString = photo["datetaken"].string,
                            let dateTaken = dateFormatter.date(from: dateString)
                        {
                            flickrPhoto.dateTaken = dateTaken
                        }
                        
                        returnArray.append(flickrPhoto)
                        
                        
                    } else {
                        // FAIL LOUDLY
                    }
    
                }
                return returnArray
            }
        }
        return nil
    }

    /**
     Remove and replace characters from with URL escape characters
     - Parameter term: string to manipulate
     */
    fileprivate func escapeCharacters(_ term: String) -> String {
        guard let escapedTerm = term.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
                return ""
        }
        return escapedTerm
    }
    
    /**
     
     */

    
    fileprivate func createURL(searchTerm: String = "", numResults: Int = 50) -> URL? {
        let resultsPerPage = max(20, min(numResults, 500))
        var urlString = "https://api.flickr.com/services/rest/?"
        var params = baseParametersForFlickAPI(method: .recent)
        
        if (searchTerm != "") {
            params = baseParametersForFlickAPI(method: .search)
            params["text"] = escapeCharacters(searchTerm)
        }
        
        params["per_page"] = resultsPerPage
        
        for (key, val) in params {
            urlString += "&\(key)=\(val)"
        }
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        return url
    }
    
    /**
    
    */
    fileprivate func baseParametersForFlickAPI(method: FlickrAPIMethods) -> Parameters {
        
        let params: Parameters = [
            "page" : 1,
            "method" : method.rawValue,
            "api_key": api_key,
            "format" : "json",
            "nojsoncallback": 1,
            "extras" : escapeCharacters("owner_name, description, views, geo, date_taken")
        ]
        return params
    }
}

/// Struct to wrap search string and search results from the string
struct FlickrResults {
    let searchTerm : String
    
    // GETTER AND SETTER
    var searchResults : [FlickrPhoto]
}


///
enum FlickrAPIMethods: String {
    case search = "flickr.photos.search"
    case recent = "flickr.photos.getRecent"
}

