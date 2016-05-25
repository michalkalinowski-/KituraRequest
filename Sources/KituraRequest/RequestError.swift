//
//  RequestError.swift
//  KituraRequest
//
//  Created by Michał Kalinowski on 26/05/16.
//
//

enum RequestError: ErrorProtocol {
  case InvalidURL
  case NoSchemeProvided
  case NoHostProvided
  case NotImplemented
}