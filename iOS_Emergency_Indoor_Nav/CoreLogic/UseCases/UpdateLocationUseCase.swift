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
  let mobileUser: MobileUser
  let remoteAPI: MobileUserRemoteAPI
  
  init (mobileUser: MobileUser, location: String, remoteAPI: MobileUserRemoteAPI) {
    self.mobileUser = mobileUser
    self.location = location
    self.remoteAPI = remoteAPI
  }
  
  public func start() -> AnyCancellable {
    return remoteAPI.updateLocation(mobileUser: mobileUser, location: location)
  }
}
