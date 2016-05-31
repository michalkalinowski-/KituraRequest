//  Copyright (c) 29/05/16 Michał Kalinowski
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

import Foundation

// Patches to fix missing features of Swift Foundation

extension NSMutableURLRequest {
  #if os(Linux)
  private struct addedProperties {
    static var httpBody: NSData?
  }
  var httpBody: NSData? {
    get {
      return addedProperties.httpBody
    }
    set {
      addedProperties.httpBody = newValue
    }
  }
  #endif
}

extension NSURLComponents {
  class func safeInit(URL url: NSURL, resolvingAgainstBaseURL resolve: Bool) -> NSURLComponents? {
    #if os(Linux)
      return NSURLComponents(URL: url, resolvingAgainstBaseURL: resolve)
    #else
      return NSURLComponents(url: url, resolvingAgainstBaseURL: resolve)
    #endif
  }
  
  func safeGetURL() -> NSURL? {
    #if os(Linux)
      return self.URL
    #else
      return self.url
    #endif
  }
}

#if os(Linux)
  func convertValuesToAnyObject(_ d: [String: Any]?) -> [String: AnyObject]? {
    
    guard let d = d else {
      return nil
    }
    
    let nsdict = d.bridge()
    let backdict = nsdict.bridge() // looks hacky but produces [NSObject: AnyObject] hassle free
    
    var result: [String: AnyObject] = [:]
    for (key, value) in backdict {
      result[(key as! NSString).bridge()] = value
    }
    return result
  }
#endif


