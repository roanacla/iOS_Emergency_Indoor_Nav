//
//  CreateUserUseCase.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 2/3/21.
//

import Foundation
import Combine

class CreateUserUseCase: UseCase {
  let userID: String
  let remoteAPI: MobileUserRemoteAPI
  
  init (userID: String,remoteAPI: MobileUserRemoteAPI) {
    self.userID = userID
    self.remoteAPI = remoteAPI
  }
  
  public func start() -> AnyCancellable {
    return remoteAPI.create(userID: userID)
  }
}
