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

enum ParameterEncoding {
  case URL
  case JSON
  case Custom
  
  func encode(_ request: inout NSMutableURLRequest, parameters: [String: AnyObject]?) throws {
    
    guard let parameters = parameters else {
      return
    }
    
    switch self {
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