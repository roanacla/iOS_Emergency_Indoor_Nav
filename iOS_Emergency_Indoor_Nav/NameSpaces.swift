//
//  NameSpaces.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 2/2/21.
//

import Foundation

enum UserDefaultsKeys {
  private static let userUniqueID: String = {
    let userID = UUID().uuidString
    UserDefaults.standard.setValue(userID, forKey: "UserID")
    return userID
  }()
  static let userID = UserDefaults.standard.string(forKey: "UserID") ?? userUniqueID
  static let deviceTokenId = "DeviceTokenID"
}
