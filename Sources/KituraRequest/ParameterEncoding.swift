//
//  File.swift
//  KituraRequest
//
//  Created by Michał Kalinowski on 26/05/16.
//
//

import Foundation

// Heavily inspired by Alamofire ParameterEncoding
// https://github.com/Alamofire/Alamofire/blob/master/Source/ParameterEncoding.swift

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