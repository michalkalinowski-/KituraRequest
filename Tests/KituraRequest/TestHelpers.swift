//
//  TestHelpers.swift
//  KituraRequest
//
//  Created by Michał Kalinowski on 26/05/16.
//
//

import Foundation
import KituraNet

func dataToString(_ data: NSData?) -> NSString? {
  return data != nil ? NSString(data: data!, encoding: NSUTF8StringEncoding) : nil
}
