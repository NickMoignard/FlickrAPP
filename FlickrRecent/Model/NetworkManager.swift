import Foundation
import Alamofire
import SwiftyJSON
import SDWebImage

fileprivate let api_key = "f0d860b368002ba704051a7b742166ee"
fileprivate let secret = "d0176a1e2ac288b5"

///
class FlickrNetworkManager {

    
    
    /**
    Get images from Flickr given a search term
     - Parameter searchTerm :
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
                    print("error")
                    completion(nil, NSError(domain: "DAD", code: 69, userInfo: nil) )
                }
            }
                
        } else {
            print("error")
        }
        

        
    }
    
    func downloadImageFromURL() {
        
    }
    
    // MARK: - HELPER METHODS
    
    /**
    */
    fileprivate func parseSearchResponse(_ data: DataResponse<Data>) -> [FlickrPhoto]? {
        var returnArray: [FlickrPhoto] = []
        if let data = data.data {
            let json = JSON(data:data)
            if let resultsDict = json["photos"].dictionary, let photosJSON = resultsDict["photo"], let photos = photosJSON.array {
                for photo in photos {
                    if let photoID = photo["id"].string,
                    let farm = photo["farm"].int,
                    let isFriend = photo["isfriend"].int,
                    let server = photo["server"].string,
                    let secret = photo["secret"].string,
                    let owner = photo["owner"].string,
                    let title = photo["title"].string {
                        returnArray.append(FlickrPhoto(photoID: photoID, farm: farm, server: server, secret: secret, isFriend: isFriend, owner: owner, title: title))
                    } else {
                        print("Error could not parse response")
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
    fileprivate func createURLForSearchTerm(_ searchTerm: String, numResults: FlickrResultsPerPage = FlickrResultsPerPage.twenty) -> URL? {
        var urlString = "https://api.flickr.com/services/rest/?"
        
        var params = baseParametersForFlickAPI(method: .search)
        params["text"] = escapeCharacters(searchTerm)
        params["per_page"] = FlickrResultsPerPage.twenty.rawValue
        
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
            "nojsoncallback": 1
        ]
        return params
    }
}


///
enum FlickrAPIMethods: String {
    case search = "flickr.photos.search"
}

///
enum FlickrResultsPerPage: Int {
    case twenty = 20
    case forty = 40
    case hundred = 100
}
