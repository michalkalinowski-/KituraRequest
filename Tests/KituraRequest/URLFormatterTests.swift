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