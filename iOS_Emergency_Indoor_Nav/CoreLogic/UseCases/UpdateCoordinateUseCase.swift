//
//  File.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 4/26/21.
//

import Foundation
import Combine

public class UpdateCoordinateUseCase: UseCase {
  let userID: String
  let latitude: Double
  let longitude: Double
  let remoteAPI: MobileUserRemoteAPI
  
  init (userID: String, latitude: Double, longitude: Double, remoteAPI: MobileUserRemoteAPI) {
    self.userID = userID
    self.latitude = latitude
    self.longitude = longitude
    self.remoteAPI = remoteAPI
  }
  
  public func start(dispatchGroup: DispatchGroup? = nil, semaphore: DispatchSemaphore? = nil) -> AnyCancellable {
    return remoteAPI.updateCoordinates(userID: userID, latitude: latitude, longitude: longitude)
  }
}
