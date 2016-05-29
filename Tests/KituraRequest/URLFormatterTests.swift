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
import KituraNet

@testable import KituraRequest

class URLFormatterTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  func testRequestWithInvalidReturnsError() {
    let invalidURL = "http://💩.com"
    let testRequest = Request(method: .GET, invalidURL)
    XCTAssertEqual(testRequest.error as? RequestError, RequestError.InvalidURL)
  }
  
  func testRequestWithURLWithoutSchemeReturnsError() {
    let URLWithoutScheme = "apple.com"
    let testRequest = Request(method: .GET, URLWithoutScheme)
    XCTAssertEqual(testRequest.error as? RequestError, RequestError.NoSchemeProvided)
  }
  
  func testRequestWithNoHostReturnsError() {
    let URLWithoutHost = "http://"
    let testRequest = Request(method: .GET, URLWithoutHost)
    XCTAssertEqual(testRequest.error as? RequestError, RequestError.NoHostProvided)
  }
  
  func testRequestWithNoHostAndQueryReturnsError() {
    let URLWithoutHost = "http://?asd=asd"
    let testRequest = Request(method: .GET, URLWithoutHost)
    XCTAssertEqual(testRequest.error as? RequestError, RequestError.NoHostProvided)
  }
  
  func testValidURLCreatesValidClientRequest() {
    let validURL = "https://66o.tech"
    let testRequest = Request(method: .GET, validURL)
    
    XCTAssertEqual(testRequest.request?.url, validURL)
  }
}

extension URLFormatterTests {
  static var allTests : [(String, (URLFormatterTests) -> () throws -> Void)] {
    return [
             ("testRequestWithInvalidReturnsError", testRequestWithInvalidReturnsError),
             ("testRequestWithURLWithoutSchemeReturnsError", testRequestWithURLWithoutSchemeReturnsError),
             ("testRequestWithNoHostReturnsError", testRequestWithNoHostReturnsError),
             ("testRequestWithNoHostAndQueryReturnsError", testRequestWithNoHostAndQueryReturnsError),
             ("testValidURLCreatesValidClientRequest", testValidURLCreatesValidClientRequest)
    ]
  }
}