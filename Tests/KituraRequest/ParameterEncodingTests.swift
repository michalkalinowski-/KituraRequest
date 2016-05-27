//
//  ParameterEncodingTests.swift
//  KituraRequest
//
//  Created by Michał Kalinowski on 27/05/16.
//
//

import XCTest
@testable import KituraRequest

class ParameterEncodingTests: XCTestCase {
  let url = NSURL(string: "https://66o.tech")!
  
  func testJSONParameterEncodingWhenNilPassedAsParameters() {
    var urlRequest = NSMutableURLRequest(url: url)
    
    do {
      try ParameterEncoding.JSON.encode(&urlRequest, parameters: nil)
      XCTAssertNil(urlRequest.httpBody)
    } catch {
      XCTFail()
    }
  }
  
  func testJSONParameterEncodingWhenEmptyPassed() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      try ParameterEncoding.JSON.encode(&urlRequest, parameters: [:])
      XCTAssertNil(urlRequest.httpBody)
    } catch {
      XCTFail()
    }
  }
  
  func testJSONParameterEncodingSetsHeaders() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      try ParameterEncoding.JSON.encode(&urlRequest, parameters: ["p1":1])
      XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
    } catch {
      XCTFail()
    }
  }
  
  func testJSONParametersEncodingSetsBody() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      try ParameterEncoding.JSON.encode(&urlRequest, parameters: ["p1":1, "p2": 3.2, "p3":"string"])
      let body = dataToString(urlRequest.httpBody)
      XCTAssertEqual(body, "{\"p1\":1,\"p2\":3.2,\"p3\":\"string\"}")
    } catch {
      XCTFail()
    }
  }
  
  func dataToString(_ data: NSData?) -> NSString? {
    return data != nil ? NSString(data: data!, encoding: NSUTF8StringEncoding) : nil
  }
}
