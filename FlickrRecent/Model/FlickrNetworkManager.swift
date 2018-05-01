import Foundation
import Alamofire
import SwiftyJSON
import SDWebImage

fileprivate let api_key = "f0d860b368002ba704051a7b742166ee"
fileprivate let secret = "d0176a1e2ac288b5"

///
class FlickrNetworkManager {

     let dateFormatter = DateFormatter()
    
    
    /**
    Get images from Flickr given a search term
     - Parameter searchTerm :"yyyy-MM-dd' 'HH:mm:ss"
     - Parameter completion :
     - Parameter results :
     - Parameter error :
    */
    func searchFlickr(_ searchTerm: String, completion: @escaping (_ results: FlickrSearchResults?, _ error: NSError?) -> Void) {
        
        if let url = createURLForSearchTerm(searchTerm) {
            Alamofire.request(url).responseData {
                data in
                
                if let photos = self.parseSearchResponse(data) {
                    let searchResults = FlickrSearchResults(searchTerm: searchTerm, searchResults: photos)
                    
                    completion(searchResults, nil)
                } else {
                    print("Error")
                    completion(nil, NSError(domain: "DAD", code: 69, userInfo: nil) )
                }
            }
                
        } else {
            print("eRror")
        }
        

        
    }
    
    func downloadImageFromURL() {
        
    }
    
    // MARK: - HELPER METHODS
    
    /**
    */
    fileprivate func parseSearchResponse(_ data: DataResponse<Data>) -> [FlickrPhoto]? {
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        
        
        var returnArray: [FlickrPhoto] = []
        if let data = data.data {
            let json = JSON(data:data)
            if let resultsDict = json["photos"].dictionary, let photosJSON = resultsDict["photo"], let photos = photosJSON.array {
                for photo in photos {
                    
                    if let ownerName = photo["ownername"].string {
                        
                    } else {
                        print("Couldn't parse owner name")
                    }
                    
                    
                    if let photoID = photo["id"].string,
                    let farm = photo["farm"].int,
                    let server = photo["server"].string,
                    let secret = photo["secret"].string,
                    let title = photo["title"].string,
                    let descriptionDict = photo["description"].dictionary,
                    let descriptionContent = descriptionDict["_content"],
                    let description = descriptionContent.string,
                    let dateString = photo["datetaken"].string,
                    let dateTaken = dateFormatter.date(from: dateString)
                    {
                        
                        let flickrPhoto: FlickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, server: server, secret: secret, dateTaken: dateTaken, title: title, description: description)
                        
                        returnArray.append(flickrPhoto)
                    } else {
                        print("Optional Chain Failed")
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
    fileprivate func createURLForSearchTerm(_ searchTerm: String, numResults: Int = 50) -> URL? {
        let resultsPerPage = max(20, min(numResults, 500))
        
        
        var urlString = "https://api.flickr.com/services/rest/?"
        
        var params = baseParametersForFlickAPI(method: .search)
        params["text"] = escapeCharacters(searchTerm)
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
struct FlickrSearchResults {
    let searchTerm : String
    let searchResults : [FlickrPhoto]
}


///
enum FlickrAPIMethods: String {
    case search = "flickr.photos.search"
    case recent = "flickr.photos.getRecent"
}

