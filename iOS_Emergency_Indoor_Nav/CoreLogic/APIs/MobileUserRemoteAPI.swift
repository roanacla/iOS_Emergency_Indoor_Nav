//
//  MobileUserRemoteAPI.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 2/1/21.
//

import Foundation
import Combine

enum APIError: Error {
    case ohNo
}

protocol MobileUserRemoteAPI {
  func create(userID: String) -> AnyCancellable
  func updateLocation(userID: String, location: String) -> AnyCancellable
  func updateDeviceTokenId(userID: String, deviceTokenId: String) -> AnyCancellable
//  func getMobileUser(withID id: String) -> AnyCancellable
  func getMobileUser(withID id: String) -> AnyPublisher<MobileUser?,Error>
}
