//
//  MobileUserRemoteAPI.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 2/1/21.
//

import Foundation
import Combine


protocol MobileUserRemoteAPI {
  //Subscriptions
  func create(userID: String, dispatchGroup: DispatchGroup?, semaphore: DispatchSemaphore?) -> AnyCancellable
  func getMobileUser(userID: String) -> AnyCancellable
  func updateLocation(userID: String, location: String, dispatchGroup: DispatchGroup?, semaphore: DispatchSemaphore?) -> AnyCancellable
  func updateDeviceTokenId(userID: String, newToken: String, dispatchGroup: DispatchGroup?, semaphore: DispatchSemaphore?) -> AnyCancellable
  
  //Publishers
  func getMobileUser(withID id: String) -> AnyPublisher<MobileUser?,Error>
}
