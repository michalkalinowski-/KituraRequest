import Foundation
import KituraNet

enum RequestMethod: String {
  case CONNECT, DELETE, GET, HEAD, OPTIONS, PATCH, POST, PUT, TRACE
}

/// Wrapper around NSURLRequest
/// TODO: Make an asynchronus version
class Request {
  var request: ClientRequest?
  var response: ClientResponse?
  var data: NSData?
  var error: ErrorProtocol?
  
  typealias ResponseArguments = (request: ClientRequest?, response: ClientResponse?, data: NSData?, error:ErrorProtocol?)
  typealias CompletionHandler = ResponseArguments -> Void
  
  init(method: RequestMethod,
       _ URL: String,
       parameters: [String: AnyObject]? = nil, // not implemented
       encoding: ParameterEncoding = .URL,     // not implemented
       headers: [String: String]? = nil) {
    
    do {
      var options: [ClientRequestOptions] = []
      options.append(.schema("")) // so that ClientRequest doesn't apend http
      options.append(.method(method.rawValue)) // set method of request
      
      var urlRequest = try formatURL(URL)
      try encoding.encode(&urlRequest, parameters: parameters)
      options.append(.hostname(urlRequest.url!.absoluteString)) // safe to force unwrap here
      
      // Create request
      let request = HTTP.request(options) {
        response in
        self.response = response
      }
      
      if let body = urlRequest.httpBody {
        request.write(from: body)
      }
      
      request.end()
      
      self.request = request
    } catch {
      self.request = nil
      self.error = error
    }
  }
  
  func response(_ completionHandler: CompletionHandler) {
    guard let response = response else {
      completionHandler((request, nil, nil, error))
      return
    }
    
    // TODO: This returns data that is not UTF8 encoded - fix it
    let data = NSMutableData()
    do {
      try response.read(into: data)
      completionHandler((request, response, data, error))
    } catch {
      print(error)
    }
  }
}

extension Request {
  func formatURL(_ URL: String) throws -> NSMutableURLRequest {
    // Regex to test validity of url:
    // _^(?:(?:https?|ftp)://)(?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})(?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})(?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\x{00a1}-\x{ffff}0-9]+-?)*[a-z\x{00a1}-\x{ffff}0-9]+)(?:\.(?:[a-z\x{00a1}-\x{ffff}0-9]+-?)*[a-z\x{00a1}-\x{ffff}0-9]+)*(?:\.(?:[a-z\x{00a1}-\x{ffff}]{2,})))(?::\d{2,5})?(?:/[^\s]*)?$_iuS
    // also check RFC 1808

    // or use NSURL:
    guard let validURL = NSURL(string: URL) else {
      throw RequestError.InvalidURL
    }
    
    // why scheme is not optional!??!
    guard validURL.scheme != "" else {
      throw RequestError.NoSchemeProvided
    }
    
    guard validURL.host != nil else {
      throw RequestError.NoHostProvided
    }
    
    return NSMutableURLRequest(url: validURL)
  }
}
