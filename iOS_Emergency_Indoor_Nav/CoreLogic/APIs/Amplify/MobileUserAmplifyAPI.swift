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
    let mobileUser = MobileUser(id: userID , location: location)
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
}
