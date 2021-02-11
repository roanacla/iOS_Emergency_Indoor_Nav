//
//  MobileUserAPI.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 2/1/21.
//

import Foundation
import Amplify
import Combine

public struct MobileUserAmplifyAPI: MobileUserRemoteAPI {
  
  func create(userID: String, tokenID: String) -> AnyCancellable {
    var mobileUser = MobileUser(id: userID)
    mobileUser.deviceTokenId = tokenID
    let sink = Amplify.API.mutate(request: .create(mobileUser))
      .resultPublisher
      .sink { completion in
        if case let .failure(error) = completion {
          print("🔴 Failed to create mobileUser graphql \(error)")
        }
      }
      receiveValue: { result in
        switch result {
        case .success(let mobileUser):
          print("🟢 Successfully created the mobileUser : \(mobileUser)")
        case .failure(let graphQLError):
          print("Could not decode result: \(graphQLError)")
        }
      }
    return sink
  }
  
  func getMobileUser(userID: String) -> AnyCancellable {
    Amplify.API
      .query(request: .get(MobileUser.self, byId: userID))
      .resultPublisher
      .sink {
        if case let .failure(error) = $0 {
          print("🔴 Error while fetching MobileUser \(error)")
        }
      }
      receiveValue: { result in
        switch result {
        case .success(let mobileUser):
          guard let mobileUser = mobileUser else {
            print("🔴 This MobileUser doesn't exist")
            return
          }
          print("🟢 Successfully retrieved mobileUser: \(mobileUser)")
        case .failure(let error):
          print("Got failed result with \(error.errorDescription)")
        }
      }
  }
  
  func getMobileUser(withID id: String) -> AnyPublisher<MobileUser?,
                                                        Error> {
    let publisher = Amplify.API
      .query(request: .get(MobileUser.self, byId: id))
      .resultPublisher
      .tryMap { result -> MobileUser? in
        //Cast Amplify publisher to AnyPublisher
        guard let mobileUser = try result.get() else { return nil}
        return mobileUser
      }
      .eraseToAnyPublisher()
    
    return publisher
  }
  
  func updateLocation(userID: String, tokenID: String, location: String) -> AnyCancellable {
    let mobileUser = MobileUser(id: userID, deviceTokenId: tokenID, location: location)
    let sink = Amplify.API.mutate(request: .update(mobileUser))
      .resultPublisher
      .sink {
        if case let .failure(error) = $0 {
          print("🔴 Failed to update device's location \(error)")
        }
      }
      receiveValue: { result in
        switch result {
        case .success(let todo):
          print("🟢 Successfully updated device location: \(todo)")
        case .failure(let error):
          print("🔴 Got failed result updating device location \(error.errorDescription)")
        }
      }
    return sink
  }
  
  func updateDeviceTokenId(userID: String, newToken: String) -> AnyCancellable {
    let mobileUser = MobileUser(id: userID, deviceTokenId: newToken)
    let sink = Amplify.API.mutate(request: .update(mobileUser))
      .resultPublisher
      .sink {
        if case let .failure(error) = $0 {
          print("🔴 Failed to update device token \(error)")
        }
      }
      receiveValue: { result in
        switch result {
        case .success(let todo):
          print("🟢 Successfully updated device token: \(todo)")
        case .failure(let error):
          print("🔴 Got failed result updating device token \(error.errorDescription)")
        }
      }
    return sink
  }
    
  enum AmplifyError: Error {
      case unknown
    }
  
}
