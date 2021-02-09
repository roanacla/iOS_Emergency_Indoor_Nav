//
//  UpdateLocationUseCase.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 2/1/21.
//

import Foundation
import Combine

public class UpdateLocationUseCase: UseCase {
  let location: String
  let userID: String
  let remoteAPI: MobileUserRemoteAPI
  
  init (userID: String, location: String, remoteAPI: MobileUserRemoteAPI) {
    self.userID = userID
    self.location = location
    self.remoteAPI = remoteAPI
  }
  
  public func start() -> AnyCancellable {
    _ = remoteAPI.getMobileUser(withID: userID)
    return remoteAPI.updateLocation(userID: userID, location: location)
  }
}
