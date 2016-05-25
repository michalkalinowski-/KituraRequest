//
//  File.swift
//  KituraRequest
//
//  Created by Michał Kalinowski on 26/05/16.
//
//

import Foundation

enum ParameterEncoding {
  case URL
  case JSON
  case Custom
  
  func encode(_ URL: inout NSURL, parameters: [String: AnyObject]?) throws -> (query: String?, body: NSData?) {
    guard parameters != nil else {
      return (nil, nil)
    }
    throw RequestError.NotImplemented
  }
}