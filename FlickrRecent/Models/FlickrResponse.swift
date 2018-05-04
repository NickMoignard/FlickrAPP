import Foundation

/// Data Structure to house responses from the Flickr API
struct FlickrResponse {
    var photos: [FlickrPhoto]?
    var totalResults: Int?
    var status: String
    var error: FlickrError?
    
    init(status: String, photos: [FlickrPhoto]? = nil, totalResults: Int? = nil, error: FlickrError? = nil) {
        self.status = status
        self.photos = photos
        self.totalResults = totalResults
        self.error = error
    }
}
