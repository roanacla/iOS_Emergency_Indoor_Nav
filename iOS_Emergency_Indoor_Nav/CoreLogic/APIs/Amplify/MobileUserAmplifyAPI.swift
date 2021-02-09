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
  
  func create(userID: String) -> AnyCancellable {
    let mobileUser = MobileUser(id: userID)
    let sink = Amplify.API.mutate(request: .create(mobileUser))
      .resultPublisher
      .sink { completion in
        if case let .failure(error) = completion {
          print("Failed to create graphql \(error)")
        }
      }
      receiveValue: { result in
        switch result {
        case .success(let todo):
          print("Successfully created the todo: \(todo)")
        case .failure(let graphQLError):
          print("Could not decode result: \(graphQLError)")
        }
      }
    return sink
  }
  
  func updateLocation(userID: String, location: String) -> AnyCancellable{
    var mobileUser = MobileUser(id: userID, location: location)
    mobileUser.location = location
    let sink = Amplify.API.mutate(request: .update(mobileUser))
      .resultPublisher
      .sink { completion in
        if case let .failure(error) = completion {
          print("Failed to create graphql \(error)")
        }
      }
      receiveValue: { result in
        switch result {
        case .success(let todo):
          print("Successfully created a mobileUser: \(todo)")
        case .failure(let graphQLError):
          print("Could not decode result: \(graphQLError)")
        }
      }
    return sink
  }
  
  func updateDeviceTokenId(userID: String, deviceTokenId: String) -> AnyCancellable {
    
    var mobileUser = MobileUser(id: userID)
    mobileUser.deviceTokenId = deviceTokenId
    let sink = Amplify.API.mutate(request: .update(mobileUser))
      .resultPublisher
      .sink { completion in
        if case let .failure(error) = completion {
          print("Failed to create graphql \(error)")
        }
      }
      receiveValue: { result in
        switch result {
        case .success(let todo):
          print("Successfully created a mobileUser: \(todo)")
        case .failure(let graphQLError):
          print("Could not decode result: \(graphQLError)")
        }
      }
    return sink
  }
  
  
  
  func getMobileUser(withID id: String) -> AnyPublisher<MobileUser?,
                                                        Error> {
    
    let ans = Amplify.API
      .query(request: .get(MobileUser.self, byId: id))
      .resultPublisher
      .tryMap { result -> MobileUser? in
        
        guard let mobileUser = try result.get() else { return nil}
        return mobileUser
      }
      
      .eraseToAnyPublisher()
    
    return ans
//      .sink {
//        if case let .failure(error) = $0 {
//          print("Got failed event with error \(error)")
//        }
//      }
//      receiveValue: { result in
//        switch result {
//        case .success(let mobileUser):
//          guard let mobileUser = mobileUser else {
//            print("Could not find todo")
//            return
//          }
//          print("Successfully retrieved todo: \(mobileUser)")
//          print(mobileUser)
//        case .failure(let error):
//          print("Got failed result with \(error.errorDescription)")
//        }
//      }
      
  }
  
}
