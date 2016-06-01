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

public enum ParameterEncodingError: ErrorProtocol {
  case CouldNotCreateComponentsFromURL
  case CouldNotCreateURLFromComponents
}

public enum ParameterEncoding {
  case URL
  case JSON
  case Custom
  
  func encode(_ request: inout NSMutableURLRequest, parameters: [String: AnyObject]?) throws {
    
    guard let parameters = parameters where !parameters.isEmpty else {
      return
    }
    
    switch self {
    case .URL:
      guard let components = NSURLComponents.safeInit(URL: request.url!, resolvingAgainstBaseURL: false) else {
        throw ParameterEncodingError.CouldNotCreateComponentsFromURL // this should never happen
      }
      
      components.query = getQueryComponents(fromDictionary: parameters)
      
      guard let newURL = components.safeGetURL() else {
        throw ParameterEncodingError.CouldNotCreateComponentsFromURL // this should never happen
      }
      request.url = newURL
      
    case .JSON:
      let options = NSJSONWritingOptions()
      // need to convert to NSDictionary as Dictionary(struct) is not AnyObject(instance of class only)
      #if os(Linux)
        let safe_parameters = parameters._bridgeToObject() // don't try to print!!!
      #else
        let safe_parameters = parameters as NSDictionary
      #endif
      let data = try NSJSONSerialization.data(withJSONObject: safe_parameters, options: options)
      request.httpBody = data
      // set content type to application/json
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    default:
      throw RequestError.NotImplemented
    }
  }
}

extension ParameterEncoding {
  typealias QueryComponents = [(String, String)]
  
  private func getQueryComponent(_ key: String, _ value: AnyObject) -> QueryComponents {
    var queryComponents: QueryComponents = []
    
    switch value {
    case let d as [String: AnyObject]:
      for (k, v) in d {
        queryComponents += getQueryComponent("\(key)[\(k)]", v)
      }
    case let d as NSDictionary:
    #if os(Linux)
      let convertedD = d.bridge() // [NSObject : AnyObject]
      for (k, v) in convertedD {
        if let kk = k as? NSString {
          queryComponents += getQueryComponent("\(key)[\(kk.bridge())]", v)
        } // else consider throw or something
      }
    #else
      break
    #endif
    case let a as [AnyObject]:
      for value in a {
        queryComponents += getQueryComponent(key + "[]", value)
      }
    
    case let a as NSArray:
    #if os(Linux)
      for value in a.bridge() {
        queryComponents += getQueryComponent(key + "[]", value)
      }
    #else
      break
    #endif
    default:
      queryComponents.append((key, "\(value)"))
    }
    return queryComponents
  }
  
  func getQueryComponents(fromDictionary dict: [String: AnyObject]) -> String {
    var query: [(String,String)] = []
    
    for element in dict {
      query += getQueryComponent(element.0, element.1)
    }
    
    return (query.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
  }
}