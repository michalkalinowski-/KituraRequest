//  Copyright (c) 26/05/16 Michał Kalinowski
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software
//  is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import Foundation
import KituraNet

public enum RequestMethod: String {
  case CONNECT, DELETE, GET, HEAD, OPTIONS, PATCH, POST, PUT, TRACE
}

/// Wrapper around NSURLRequest
/// TODO: Make an asynchronus version
public class Request {
  var request: ClientRequest?
  var response: ClientResponse?
  var data: NSData?
  var error: ErrorProtocol?
  
  public typealias ResponseArguments = (request: ClientRequest?, response: ClientResponse?, data: NSData?, error:ErrorProtocol?)
  public typealias CompletionHandler = ResponseArguments -> Void
  
  public init(method: RequestMethod,
             _ URL: String,
             parameters: [String: AnyObject]? = nil,
             encoding: ParameterEncoding = .URL,
             headers: [String: String]? = nil) {
    
    do {
      var options: [ClientRequest.Options] = []
      options.append(.schema("")) // so that ClientRequest doesn't apend http
      options.append(.method(method.rawValue)) // set method of request
      
      // headers
      if let headers = headers {
        options.append(.headers(headers))
      }
      
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
      
      self.request = request
    } catch {
      self.request = nil
      self.error = error
    }
  }
  
  public func response(_ completionHandler: CompletionHandler) {
    guard let response = response else {
      completionHandler((request, nil, nil, error))
      return
    }
    
    let data = NSMutableData()
    do {
      try response.read(into: data)
      completionHandler((request, response, data, error))
    } catch {
      print(error)
    }
  }
  
  func submit() {
    request?.end()
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
    
    #if os(Linux)
      guard validURL.scheme != nil else {
        throw RequestError.NoSchemeProvided
      }
    #else
      // why scheme is not optional on OSX!??!
      guard validURL.scheme != "" else {
        throw RequestError.NoSchemeProvided
      }
    #endif
    
    guard validURL.host != nil else {
      throw RequestError.NoHostProvided
    }
    
    return NSMutableURLRequest(url: validURL)
  }
}
