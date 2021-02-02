//
//  MobileUserRemoteAPI.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 2/1/21.
//

import Foundation
import Combine

protocol MobileUserRemoteAPI {
  func create(userID: String) -> AnyCancellable
  func updateLocation(userID: String, location: String) -> AnyCancellable
}
