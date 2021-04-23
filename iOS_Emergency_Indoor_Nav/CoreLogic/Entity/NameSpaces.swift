//
//  NameSpaces.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 2/2/21.
//

import Foundation

enum UserDefaultsKeys {
  static let userID = "UserID"
  static let deviceTokenID = "DeviceTokenID"
}

enum UserDefaultsData {
  private static let userUniqueID: String = {
    let userID = UUID().uuidString
    UserDefaults.standard.setValue(userID, forKey: UserDefaultsKeys.userID)
    return userID
  }()
  static let userID = UserDefaults.standard.string(forKey: UserDefaultsKeys.userID) ?? userUniqueID
  static let deviceTokenId = UserDefaults.standard.string(forKey: UserDefaultsKeys.deviceTokenID) ?? ""
}

