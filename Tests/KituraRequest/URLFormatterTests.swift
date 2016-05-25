//
//  URLFormatterTests.swift
//  KituraRequest
//
//  Created by Michał Kalinowski on 25/05/16.
//
//

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
    XCTAssertEqual(testRequest.error, NetworkingError.InvalidURL)
  }
  
  func testRequestWithURLWithoutSchemeReturnsError() {
    let URLWithoutScheme = "apple.com"
    let testRequest = Request(method: .GET, URLWithoutScheme)
    XCTAssertEqual(testRequest.error, NetworkingError.NoSchemeProvided)
  }
  
  func testRequestWithNoHostReturnsError() {
    let URLWithoutHost = "http://"
    let testRequest = Request(method: .GET, URLWithoutHost)
    XCTAssertEqual(testRequest.error, NetworkingError.NoHostProvided)
  }
  
  func testRequestWithNoHostAndQueryReturnsError() {
    let URLWithoutHost = "http://?asd=asd"
    let testRequest = Request(method: .GET, URLWithoutHost)
    XCTAssertEqual(testRequest.error, NetworkingError.NoHostProvided)
  }
  
}