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
  
  func updateLocation(userID: String, location: String) -> AnyCancellable {
    return Amplify.API
      .query(request: .get(MobileUser.self, byId: userID))
      .resultPublisher
      .tryMap { result -> MobileUser in
        //Cast Amplify publisher to AnyPublisher
        guard let mobileUser = try result.get() else { throw AmplifyError.unknown  }
        return mobileUser
      }
      .eraseToAnyPublisher()
      .map{$0}
      .map { mobileUser -> AnyCancellable in
        var mobileUser = mobileUser
        mobileUser.location = location
        return  Amplify.API.mutate(request: .update(mobileUser))
          .resultPublisher
          .sink { completion in
            if case let .failure(error) = completion {
              print("🔴 Failed to update location graphql \(error)")
            }
          }
          receiveValue: { result in
            switch result {
            case .success(let location):
              print("🟢 Successfully updated user's location: \(location)")
            case .failure(let graphQLError):
              print("Could not decode result: \(graphQLError)")
            }
          }
      }
      .retry(2)
      .sink(
        receiveCompletion: {_ in },
        receiveValue: { _ in }
      )
    
    
  }
  
  func updateDeviceTokenId(userID: String, newToken: String) -> AnyCancellable {
    return Amplify.API
      .query(request: .get(MobileUser.self, byId: userID))
      .resultPublisher
      .tryMap { result -> MobileUser in
        //Cast Amplify publisher to AnyPublisher
        guard let mobileUser = try result.get() else { throw AmplifyError.unknown  }
        return mobileUser
      }
      .eraseToAnyPublisher()
      .map{$0}
      .map { mobileUser -> AnyCancellable in
        var mobileUser = mobileUser
        mobileUser.deviceTokenId = newToken
        
        return Amplify.API.mutate(request: .update(mobileUser))
          .resultPublisher
          .sink { completion in
            if case let .failure(error) = completion {
              print("🔴 Failed to to update user's token ID \(error)")
            }
          }
          receiveValue: { result in
            switch result {
            case .success(let tokenID):
              print("🟢 Successfully updated user's device token: \(tokenID)")
            case .failure(let graphQLError):
              print("Could not decode result: \(graphQLError)")
            }
          }
      }
      .retry(2)
      .sink(
        receiveCompletion: {_ in },
        receiveValue: { _ in }
      )
  }
    
  enum AmplifyError: Error {
      case unknown
    }
  
//  func getMobileUser(withID id: String, completion: (MobileUser)->AnyCancellable) -> AnyCancellable {
//    return Amplify.API
//      .query(request: .get(MobileUser.self, byId: id))
//      .resultPublisher
//      .tryMap { result -> MobileUser in
//        //Cast Amplify publisher to AnyPublisher
//        guard let mobileUser = try result.get() else { throw AmplifyError.unknown  }
//        return mobileUser
//      }
//      .eraseToAnyPublisher()
//      .map{$0}
//      .map { mobileUser -> AnyCancellable in
//        completion(mobileUser)
//      }
//      .retry(2)
//      .sink(
//        receiveCompletion: {_ in },
//        receiveValue: { _ in }
//      )
//  }
  
  
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
  
}
