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

import XCTest
import Foundation
@testable import KituraRequest

class ParameterEncodingTests: XCTestCase {
  let url = NSURL(string: "https://66o.tech")!
  
  // JSON encoding
  
  func testJSONParameterEncodingWhenNilPassedAsParameters() {
    var urlRequest = NSMutableURLRequest(url: url)
    
    do {
      #if os(Linux)
        try ParameterEncoding.JSON.encode(&urlRequest, parameters: convertValuesToAnyObject(nil))
      #else
        try ParameterEncoding.JSON.encode(&urlRequest, parameters: nil)
      #endif
      XCTAssertNil(urlRequest.httpBody)
    } catch {
      XCTFail()
    }
  }
  
  func testJSONParameterEncodingWhenEmptyPassed() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        try ParameterEncoding.JSON.encode(&urlRequest, parameters: convertValuesToAnyObject([:]))
      #else
        try ParameterEncoding.JSON.encode(&urlRequest, parameters: [:])
      #endif
      try ParameterEncoding.JSON.encode(&urlRequest, parameters: [:])
      XCTAssertNil(urlRequest.httpBody)
    } catch {
      XCTFail()
    }
  }
  
  func testJSONParameterEncodingSetsHeaders() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        try ParameterEncoding.JSON.encode(&urlRequest, parameters: convertValuesToAnyObject(["p1":1]))
      #else
        try ParameterEncoding.JSON.encode(&urlRequest, parameters: ["p1":1])
      #endif
      XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
    } catch {
      XCTFail()
    }
  }
  
  func testJSONParametersEncodingSetsBody() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        try ParameterEncoding.JSON.encode(&urlRequest, parameters: convertValuesToAnyObject(["p1":1]))
      #else
        try ParameterEncoding.JSON.encode(&urlRequest, parameters: ["p1":1])
      #endif
      let body = dataToString(urlRequest.httpBody)
      XCTAssertEqual(body, "{\"p1\":1}")
    } catch {
      XCTFail()
    }
  }
  
  // URL Encoding
  
  func testURLParametersEncodingWithNilParameters() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        try ParameterEncoding.URL.encode(&urlRequest, parameters: convertValuesToAnyObject(nil))
      #else
        try ParameterEncoding.URL.encode(&urlRequest, parameters: nil)
      #endif
      XCTAssertEqual(urlRequest.url?.absoluteURL, url.absoluteURL)
    } catch {
      XCTFail()
    }
  }
  
  func testURLParametersEncodingWithEmptyParameters() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        try ParameterEncoding.URL.encode(&urlRequest, parameters: convertValuesToAnyObject([:]))
      #else
        try ParameterEncoding.URL.encode(&urlRequest, parameters: [:])
      #endif
      XCTAssertEqual(urlRequest.url?.absoluteString, url.absoluteString)
    } catch {
      XCTFail()
    }
  }
  
  func testURLParametersEncodingWithSimpleParameters() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        try ParameterEncoding.URL.encode(&urlRequest, parameters: convertValuesToAnyObject(["a":1, "b":2]))
      #else
        try ParameterEncoding.URL.encode(&urlRequest, parameters: ["a":1, "b":2])
      #endif
      XCTAssertEqual(urlRequest.url?.query, "b=2&a=1") // this may be brittle
    } catch {
      XCTFail()
    }
  }
  
  func testURLParametersEncodingWithArray() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        try ParameterEncoding.URL.encode(&urlRequest, parameters: convertValuesToAnyObject(["a":[1, 2]]))
      #else
        try ParameterEncoding.URL.encode(&urlRequest, parameters: ["a":[1, 2]])
      #endif
      XCTAssertEqual(urlRequest.url?.query, "a%5B%5D=1&a%5B%5D=2") // this may be brittle
    } catch {
      XCTFail()
    }
  }
  
  func testURLParametersEncodingWithDictionary() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        let nestedDict: [String: Any] = ["b" : 1]
        try ParameterEncoding.URL.encode(&urlRequest, parameters: convertValuesToAnyObject(["a" : nestedDict]))
      #else
        try ParameterEncoding.URL.encode(&urlRequest, parameters: ["a" : ["b" : 1]])
      #endif
      XCTAssertEqual(urlRequest.url?.query, "a%5Bb%5D=1") // this may be brittle
    } catch {
      XCTFail()
    }
  }
  
  func testURLParametersEncodingWithArrayNestedInDict() {
    var urlRequest = NSMutableURLRequest(url: url)
    do {
      #if os(Linux)
        let nestedDict: [String: Any] = ["b" : [1, 2]]
        try ParameterEncoding.URL.encode(&urlRequest, parameters: convertValuesToAnyObject(["a" : nestedDict]))
      #else
        try ParameterEncoding.URL.encode(&urlRequest, parameters: ["a" : ["b" : [1, 2]]])
      #endif
      XCTAssertEqual(urlRequest.url?.query, "a%5Bb%5D%5B%5D=1&a%5Bb%5D%5B%5D=2") // this may be brittle
    } catch {
      XCTFail()
    }
  }
}

extension ParameterEncodingTests {
  static var allTests : [(String, ParameterEncodingTests -> () throws -> Void)] {
    return [
             ("testJSONParameterEncodingWhenNilPassedAsParameters", testJSONParameterEncodingWhenNilPassedAsParameters),
             ("testJSONParameterEncodingWhenEmptyPassed", testJSONParameterEncodingWhenEmptyPassed),
             ("testJSONParameterEncodingSetsHeaders", testJSONParameterEncodingSetsHeaders),
             ("testJSONParametersEncodingSetsBody", testJSONParametersEncodingSetsBody),
             ("testURLParametersEncodingWithNilParameters", testURLParametersEncodingWithNilParameters),
             ("testURLParametersEncodingWithEmptyParameters",
              testURLParametersEncodingWithEmptyParameters),
             ("testURLParametersEncodingWithSimpleParameters",
              testURLParametersEncodingWithSimpleParameters),
             ("testURLParametersEncodingWithArray",testURLParametersEncodingWithArray),
             ("testURLParametersEncodingWithDictionary", testURLParametersEncodingWithDictionary),
             ("testURLParametersEncodingWithArrayNestedInDict", testURLParametersEncodingWithArrayNestedInDict)
    ]
  }
}