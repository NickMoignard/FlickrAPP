import Foundation
import Alamofire
import SwiftyJSON
import SDWebImage



/// Class to interact and return data from the RESTful Flickr API
class FlickrNetworkManager {
    fileprivate let api_key = "f0d860b368002ba704051a7b742166ee"
    fileprivate let secret = "d0176a1e2ac288b5"
    let dateFormatter = DateFormatter()
    var lastURL: URL? = nil

    /**
    Get images from Flickr for a given a search term
     - Parameter searchTerm : The term to search flickr with
     - Parameter completion : Completion handler for function
     - Parameter results : Flickr response data structure parsed from the json return by the API
    */
    public func searchFlickr(_ searchTerm: String, completion: @escaping (_ results: FlickrResponse?) -> Void) {
        if let url = createURL(method: .search, searchTerm: searchTerm, numResults: 100) {
            Alamofire.request(url).responseData {
                data in
                if let response = self.parseFlickrPhotosResponse(data) {
                    self.lastURL = url
                    completion(response)
                }
            }
        } else {
            completion(nil)
        }
    }
    
    /**
    Get the most recent photos uploaded to Flickr
     - Parameter completion : Completion handler for function
     - Parameter results : Flickr response data structure parsed from the json return by the API
    */
    public func getRecentPhotos(completion: @escaping (_ results: FlickrResponse?) -> Void ) {
        if let url = createURL() {
            Alamofire.request(url).responseData {
                data in
                if let response = self.parseFlickrPhotosResponse(data) {
                    self.lastURL = url
                    completion(response)
                }
            }
        }
    }
    
    /**
    Get next page of results from Flickr for the last API call
     - Parameter completion : Completion handler for function
     - Parameter results : Flickr response data structure parsed from the json return by the API
    */
    public func getNextPageOfResults(completion: @escaping (_ results: FlickrResponse?) -> Void ) {
        // Increment page number parameter in the last url sent to flickr and call API with it
        if let oldURL = self.lastURL, let url = self.incrementPageNumberInURL(oldURL) {
            Alamofire.request(url).responseData {
                data in
                if let response = self.parseFlickrPhotosResponse(data) {
                    self.lastURL = url
                    completion(response)
                }
            }
        } else {
            // Could not create url for next page of results
            completion(nil)
        }
    }
    
    // MARK: - HELPER METHODS
    
    /**
    Helper method to create a URL that will get the next page of results for a given URL
     - Parameter url: The URL to get next page of results for
     - Returns: URL with page number parameter incremented by 1
    */
    fileprivate func incrementPageNumberInURL(_ url: URL) -> URL? {
        var urlStringSuffix = url.absoluteString
        var urlStringPreffix = url.absoluteString
        var returnString = ""
        var pageNumberString = ""
        
        if let range = urlStringSuffix.range(of: "&page") {
            // Get index of the page number parameter in url string
            let i = range.upperBound
            
            urlStringPreffix.removeSubrange(i..<urlStringPreffix.endIndex)
            urlStringSuffix.removeSubrange(urlStringSuffix.startIndex...i)

            // Iterate over URL to determine number of digits in page number parameter
            for char in urlStringSuffix {
                if let digit = Int(String(char)) {
                    pageNumberString += "\(digit)"
                    urlStringSuffix.remove(at: urlStringSuffix.startIndex)
                } else {
                    if char == "&" {  // Collected each digit from page number parameter
                        
                        // Increment page number and put url sections back together
                        if let pageNum = Int(pageNumberString) {
                            returnString = urlStringPreffix + "=\(pageNum + 1)" + urlStringSuffix
                            if let returnURL = URL(string: returnString) {
                                return returnURL
                            }
                        }
                    } else {
                        // Page number parameter has value other than a number.
                        return nil
                    }
                }
            }
        }
        // Page number parameter not present in URL
        return nil
    }
    
    /**
    Helper method to parse json response from the Flickr API
     - Parameter data: The response from the HTTP request
     - Returns: An easily interactable FlickrResponse object
    */
    fileprivate func parseFlickrPhotosResponse(_ data: DataResponse<Data>) -> FlickrResponse? {
        // Set format for dates returned from Flick API
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        
        if let data = data.data {
            let json = JSON(data:data)
            
            // Uncomment to view json return from API call
            // print(json)
            
            if let status = json["stat"].string {
                if status == "ok" {
                    var returnNumResults = 0
                    var returnPhotos: [FlickrPhoto] = []
                    
                    if let resultsDict = json["photos"].dictionary, let photosJSON = resultsDict["photo"], let photos = photosJSON.array {
                        
                        // Get total number of photos returned from flickr
                        // Search & Recents methods respond with different total types in the json (String for Search and Integer for Recents)
                        if let totalResults = resultsDict["total"], let numResults = totalResults.int {
                            returnNumResults = numResults
                        }
                        if let totalJSON = resultsDict["total"], let numResultsString = totalJSON.string, let numResults = Int(numResultsString) {
                                returnNumResults = numResults
                        }
                        
                        // Pull data from JSON
                        for photo in photos {
                            var flickrPhoto: FlickrPhoto
                            
                            // Required data for flickr  photo URL creation
                            if let photoID = photo["id"].string,
                                let farm = photo["farm"].int,
                                let server = photo["server"].string,
                                let secret = photo["secret"].string {
                                
                                flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, server: server, secret: secret)
                                
                                // Flickr photo metadata
                                if let viewsString = photo["views"].string, let views = Int(viewsString) {
                                    flickrPhoto.views = views
                                }
                                if let ownerName = photo["ownername"].string,
                                    let title = photo["title"].string {
                                    flickrPhoto.ownerName = ownerName
                                    flickrPhoto.title = title
                                }
                                if let descriptionDict = photo["description"].dictionary,
                                    let descriptionContent = descriptionDict["_content"],
                                    let description = descriptionContent.string {
                                    flickrPhoto.description = description
                                }
                                if let dateString = photo["datetaken"].string,
                                    let dateTaken = dateFormatter.date(from: dateString) {
                                    flickrPhoto.dateTaken = dateTaken
                                }
                                
                                returnPhotos.append(flickrPhoto)
                            } else {
                                // Couldn't parse required information to download photo from flickr
                                return nil
                            }
                        }
                        return FlickrResponse(status: status, photos: returnPhotos, totalResults: returnNumResults)
                    }
                } else {
                    if let code = json["code"].int, let message = json["message"].string {
                        let flickrError =  FlickrError(code: code, message: message)
                        return FlickrResponse(status: status, error: flickrError)
                    }
                }
            }
        }
        // Couldn't access response data
        return nil
    }

    /**
     Remove and replace characters from URL with escape characters
     - Parameter term: string to manipulate
     - Returns: A URL compatable string
     */
    fileprivate func escapeCharacters(_ term: String) -> String {
        guard let escapedTerm = term.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
                return ""
        }
        return escapedTerm
    }
    
    /**
     Helper Method for creating URL's that conform to the Flickr API
     - Parameter method: The Flickr API Method to call
     - Parameter searchTerm: Term to search Flickr with
     - Parameter numResults: The number of results per page for flickr to send back
     - Returns: A URL that conforms to the RESTful Flickr API, nil if URL could not be created
     */
    fileprivate func createURL(method: FlickrAPIMethod = .recent, searchTerm: String = "", numResults: Int = 50) -> URL? {
        /// The Flickr API has a min, max results per page of 20 & 500
        let resultsPerPage = max(20, min(numResults, 500))
        
        var urlString = "https://api.flickr.com/services/rest/?"
        var params: Parameters = [
            "page" : 1,
            "method" : method.rawValue,
            "api_key": api_key,
            "format" : "json",
            "nojsoncallback": 1,
            "extras" : escapeCharacters("owner_name, description, views, geo, date_taken"),
            "per_page": resultsPerPage
        ]
        
        // Set search term for a search url
        if (method == .search) {
            if (searchTerm == "") {
                return nil
            }
            params["text"] = escapeCharacters(searchTerm)
        }
        
        // Add parameters to URL string
        for (key, val) in params {
            urlString += "&\(key)=\(val)"
        }
        
        guard let url = URL(string: urlString) else {
            // Couldn't create url from string
            return nil
        }
        return url
    }
}

// Mark: - Enumerations

/// Various callable methods supported by the Flickr API
enum FlickrAPIMethod: String {
    case search = "flickr.photos.search"
    case recent = "flickr.photos.getRecent"
}

/// Various sizes of photos supported by the Flickr API
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


