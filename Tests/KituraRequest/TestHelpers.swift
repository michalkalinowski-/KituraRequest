//
//  TestHelpers.swift
//  KituraRequest
//
//  Created by Michał Kalinowski on 26/05/16.
//
//

import Foundation
import KituraNet

// copy paste of KituraNet Client Request initialiser
// used to test if final URL is ok
func urlFromClientRequestOptions(options: [ClientRequestOptions]) -> String {
  
  var theSchema = "http://"
  var hostName = "localhost"
  var path = "/"
  var port: Int16? = nil
  var userName: String?
  var password: String?
  
  for option in options  {
    switch(option) {
      
    case .schema(let schema):
      theSchema = schema
    case .hostname(let host):
      hostName = host
    case .port(let thePort):
      port = thePort
    case .path(let thePath):
      path = thePath
    case .username(let u):
      userName = u
    case .password(let p):
      password = p
      //      case .maxRedirects(let maxRedirects):
      //        self.maxRedirects = maxRedirects
      //      case .disableSSLVerification:
    //        self.disableSSLVerification = true
    default:
      break
    }
  }
  
  // Adding support for Basic HTTP authentication
  var authenticationClause = ""
  if let userName = userName, password = password {
    authenticationClause = "\(userName):\(password)@"
  }
  
  
  var portClause = ""
  if  let port = port  {
    portClause = ":\(String(port))"
  }
  
  return "\(theSchema)\(authenticationClause)\(hostName)\(portClause)\(path)"
}
