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
import KituraNet

@testable import KituraRequest

class RequestTests: XCTestCase {
  
  var testRequest = KituraRequest.request(method: .POST,
                                          "https://google.com",
                                          parameters: ["asd":"asd"],
                                          encoding: .URL,
                                          headers: ["User-Agent":"Kitura-Server"]
  )
  
  func testRequestAssignsClientRequestURL() {
    XCTAssertEqual(testRequest.request?.url, "https://google.com?asd=asd")
  }
  
  func testRequestAssignClientRequestMethod() {
    XCTAssertEqual(testRequest.request?.method, "POST")
  }
  
  func testRequestAssignsClientRequestHeaders() {
    if let headers = testRequest.request?.headers {
      XCTAssertEqual(headers, ["User-Agent":"Kitura-Server"])
    } else {
      XCTFail()
    }
  }
}

extension RequestTests {
  static var allTests : [(String, RequestTests -> () throws -> Void)] {
    return [("testRequestAssignsClientRequestURL", testRequestAssignsClientRequestURL),
    ("testRequestAssignClientRequestMethod", testRequestAssignClientRequestMethod)]
  }
}