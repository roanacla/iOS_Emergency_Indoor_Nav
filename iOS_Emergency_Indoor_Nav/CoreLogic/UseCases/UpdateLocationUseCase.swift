//
//  UpdateLocationUseCase.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 2/1/21.
//

import Foundation
import Combine

public class UpdateLocationUseCase: UseCase {
  let userID: String
  let tokenID: String
  let location: String
  let remoteAPI: MobileUserRemoteAPI
  
  init (userID: String, tokenID: String, location: String, remoteAPI: MobileUserRemoteAPI) {
    self.userID = userID
    self.tokenID = tokenID
    self.location = location
    self.remoteAPI = remoteAPI
  }
  
  public func start() -> AnyCancellable {
    return remoteAPI.updateLocation(userID: userID, location: location)
  }
}
