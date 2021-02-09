//
//  UpdateDeviceTokenIdUseCase.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 2/2/21.
//

import Foundation
import Combine

class UpdateDeviceTokenIdUseCase: UseCase {
  let userID: String
  let deviceTokenId: String
  let remoteAPI: MobileUserRemoteAPI
  
  init (userID: String, deviceTokenId: String, remoteAPI: MobileUserRemoteAPI) {
    self.userID = userID
    self.deviceTokenId = deviceTokenId
    self.remoteAPI = remoteAPI
  }
  
  public func start() -> AnyCancellable {
    return remoteAPI.updateDeviceTokenId(userID: userID, deviceTokenId: deviceTokenId)
  }
}
