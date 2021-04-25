//
//  GetUserUseCase.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 2/11/21.
//

import Foundation
import Combine

class GetMobileUserUseCase: UseCase {
  let userID: String
  let remoteAPI: MobileUserRemoteAPI
  
  init (userID: String,remoteAPI: MobileUserRemoteAPI) {
    self.userID = userID
    self.remoteAPI = remoteAPI
  }
  
  public func start(dispatchGroup: DispatchGroup? = nil, semaphore: DispatchSemaphore? = nil) -> AnyCancellable {
    return remoteAPI.getMobileUser(userID: userID)
  }
  
  public func startBroadcast() -> AnyPublisher<MobileUser?,Error> {
    return remoteAPI.getMobileUser(withID: userID)
  }
}

