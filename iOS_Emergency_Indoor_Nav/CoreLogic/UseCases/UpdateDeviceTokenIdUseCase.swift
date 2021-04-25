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
  let tokenID: String
  let remoteAPI: MobileUserRemoteAPI
  
  init (userID: String, tokenID: String, remoteAPI: MobileUserRemoteAPI) {
    self.userID = userID
    self.tokenID = tokenID
    self.remoteAPI = remoteAPI
  }
  
  public func start(dispatchGroup: DispatchGroup? = nil, semaphore: DispatchSemaphore? = nil) -> AnyCancellable {
    return remoteAPI.updateDeviceTokenId(userID: userID, newToken: tokenID, dispatchGroup: dispatchGroup, semaphore: semaphore)
  }
}
