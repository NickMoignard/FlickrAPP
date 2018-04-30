//
//  NetworkManager.swift
//  FlickrRecent
//
//  Created by Alice Newman on 29/4/18.
//  Copyright © 2018 Nicholas Moignard. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

fileprivate let api_key = ""

class FlickrNetworkManager {
    init() {
        
    }
    
    
    /// Get images from Flickr given a search term
    func searchFlickr(_ searchTerm: String, completionHandler: @escaping (_ results: FlickrSearchResults, _ error: NSError?) -> Void) {
     
        
        
        
        
    }
    
    fileprivate func escapeCharacters(_ term: String) -> String {
        guard let escapedTerm = term.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
                return ""
        }
        return escapedTerm
    }
    
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

enum FlickrAPIMethods: String {
    case search = "flickr.photos.search"
}

enum FlickrResultsPerPage: Int {
    case twenty = 20
    case forty = 40
    case hundred = 100
}
