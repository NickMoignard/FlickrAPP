import Foundation

/// Data Structure for FlickAPI errors
struct FlickrError {
    let code: Int,
    message: String,
    type: FlickrErrorType
    
    init(code: Int, message: String) {
        self.code = code
        self.message = message
        
        // Set error type in order for easy error handling with switch statements
        if let type = FlickrErrorType(rawValue: code) {
            self.type = type
        } else {
            self.type = .unknown
        }
    }
}

/// The Different Error responses from the Flickr API
enum FlickrErrorType: Int {
    ///    When performing an 'all tags' search, you may not specify more than 20 tags to join together.
    case tooManyTags = 1
    ///    A user_id was passed which did not match a valid flickr user.
    case unknownUser = 2
    ///    To perform a search with no parameters (to get the latest public photos, please use flickr.photos.getRecent instead).
    case parameterless = 3
    ///    The logged in user (if any) does not have permission to view the pool for this group.
    case noPermissionToViewPool = 4
    ///    The user id passed did not match a Flickr user.
    case userDeleted = 5
    ///    The Flickr API search databases are temporarily unavailable.
    case searchAPIUnavailable = 10
    ///   The query styntax for the machine_tags argument did not validate.
    case noValidMachineTags = 11
    ///    The maximum number of machine tags in a single query was exceeded.
    case tooMantMachineTags = 12
    ///    The call tried to use the contacts parameter with no user ID or a user ID other than that of the authenticated user.
    case notSearchingCurrentUsersContacts = 17
    ///    The request contained contradictory arguments.
    case illogicalArguments = 18
    ///    The API key passed was not valid or has expired.
    case invalidAPIKey = 100
    ///    The requested service is temporarily unavailable.
    case serviceCurrentlyUnavailable = 105
    ///    The requested operation failed due to a temporary issue.
    case writeOperationFailed = 106
    ///    The requested response format was not found.
    case formatNotFound = 111
    ///    The requested method was not found.
    case methodNotFound = 112
    ///    The SOAP envelope send in the request could not be parsed.
    case invalidSOAPenvelope = 114
    ///    The XML-RPC request document could not be parsed.
    case invalidXMLRPCMethod = 115
    ///    One or more arguments contained a URL that has been used for abuse on Flickr.
    case badURL = 116
    /// Unknown Error Code
    case unknown = 999999
}
