//
//  Original work Copyright (c) 2014-2016 Alamofire Software Foundation (http://alamofire.org/)
//  Modified work Copyright (c) 26/05/16 Michał Kalinowski
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

enum ParameterEncodingError: ErrorProtocol {
  case CouldNotCreateComponentsFromURL
  case CouldNotCreateURLFromComponents
}

enum ParameterEncoding {
  case URL
  case JSON
  case Custom
  
  func encode(_ request: inout NSMutableURLRequest, parameters: [String: AnyObject]?) throws {
    
    guard let parameters = parameters where !parameters.isEmpty else {
      return
    }
    
    switch self {
    case .URL:
      guard let components = NSURLComponents(url: request.url!, resolvingAgainstBaseURL: false) else {
        throw ParameterEncodingError.CouldNotCreateComponentsFromURL // this should never happen
      }
      components.query = NSDictionary(dictionary: parameters).toQueryString()
      
      guard let newURL = components.url else {
        throw ParameterEncodingError.CouldNotCreateComponentsFromURL // this should never happen
      }
      request.url = newURL
      
    case .JSON:
      let options = NSJSONWritingOptions()
      let data = try NSJSONSerialization.data(withJSONObject: parameters, options: options)
      request.httpBody = data
      // set content type to application/json
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    default:
      throw RequestError.NotImplemented
    }
  }
}

private extension NSDictionary {
  func toQueryString() -> String {
    typealias QueryComponents = [(String, String)]
    
    func getQueryComponent(_ key: String, _ value: AnyObject) -> QueryComponents {
      var queryComponents: QueryComponents = []
      
      switch value {
      case let d as [String: AnyObject]:
        for (k, v) in d {
          queryComponents += getQueryComponent("\(key)[\(k)]", v)
        }
      case let a as [AnyObject]:
        for value in a {
          queryComponents += getQueryComponent(key + "[]", value)
        }
      default:
        queryComponents.append((key, "\(value)"))
      }
      return queryComponents
    }

    var query: [(String,String)] = []
    
    for element in self {
      query += getQueryComponent(element.0 as! String, element.1)
    }
    
    return (query.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
  }
}