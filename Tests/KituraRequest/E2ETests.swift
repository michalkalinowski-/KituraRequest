//
//  E2ETests.swift
//  KituraRequest
//
//  Created by Michał Kalinowski on 28/05/16.
//
//

import XCTest
@testable import KituraRequest

class E2ETests: XCTestCase {
  
  func testRequestReturnsData() {
    _ = Request(method: .GET, "https://httpbin.org/html")
      .response {
        _, _, data, _ in
        if let data = data {
          print(String(data: data, encoding: NSUTF8StringEncoding))
        } else {
          XCTFail("No data returned")
        }
    }
    XCTAssertTrue(true)
  }

}
