//
//  MobileUserAPI.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 2/1/21.
//

import Foundation
import Amplify
import Combine

extension GraphQLRequest {
  static func updateMobileUserLocation(id: String, location: String) -> GraphQLRequest<JSONValue> {
    let document = """
        mutation updateMobileUserLocation($id: ID!, $location: String!) {
          updateMobileUser(input: {id: $id, location: $location}) {
            location
          }
        }
        """
    return GraphQLRequest<JSONValue>(document: document,
                                     variables: ["id": id,
                                                 "location": location],
                                     responseType: JSONValue.self)
  }
  
  static func updateMobileUserToken(id: String, token: String) -> GraphQLRequest<JSONValue> {
    let document = """
      mutation updateMobileUserToken($id: ID!, $token: String!) {
        updateMobileUser(input: {id: $id, deviceTokenId: $token}) {
          deviceTokenId
        }
      }
      """
    return GraphQLRequest<JSONValue>(document: document,
                                     variables: ["id": id,
                                                 "token": token],
                                     responseType: JSONValue.self)
  }
  
  static func updateMobileUserCoordinate(id: String, latitude: Double, longitude: Double) -> GraphQLRequest<JSONValue> {
    let document = """
      mutation updateMobileUserCoordinate($id: ID!, $latitude: Float!, $longitude: Float!) {
        updateMobileUser(input: {id: $id, latitude: $latitude, longitude: $longitude}) {
          id
          latitude
          longitude
          buildingId
        }
      }
      """
    return GraphQLRequest<JSONValue>(document: document,
                                     variables: ["id": id,
                                                 "latitude": latitude,
                                                 "longitude": longitude],
                                     responseType: JSONValue.self)
  }
}

public struct MobileUserAmplifyAPI: MobileUserRemoteAPI {
  
  func create(userID: String, dispatchGroup: DispatchGroup? = nil, semaphore: DispatchSemaphore? = nil) -> AnyCancellable {
    semaphore?.wait()
    dispatchGroup?.enter()
    let mobileUser = MobileUser(id: userID, buildingId: "id001") //Todo: The building id should be mutated when the user enters a building, not during creation.
    let sink = Amplify.API.mutate(request: .create(mobileUser))
      .resultPublisher
      .sink { completion in
        if case let .failure(error) = completion {
          print("🔴 Failed to create mobileUser graphql \(error)")
        }
        dispatchGroup?.leave()
        semaphore?.signal()
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
  
  func updateLocation(userID: String, location: String, dispatchGroup: DispatchGroup? = nil, semaphore: DispatchSemaphore? = nil) -> AnyCancellable {
    semaphore?.wait()
    dispatchGroup?.enter()
    return Amplify.API.mutate(request: .updateMobileUserLocation(id: userID, location: location))
      .resultPublisher
      .sink {
        if case let .failure(error) = $0 {
          print("🔴 Failed to update device's location \(error)")
        }
        dispatchGroup?.leave()
        semaphore?.signal()
      }
      receiveValue: { result in
        switch result {
        case .success(let todo):
          print("🟢 Successfully updated device location: \(todo)")
        case .failure(let error):
          print("🔴 Got failed result updating device location \(error.errorDescription)")
        }
      }
  }
  
  func updateDeviceTokenId(userID: String, newToken: String, dispatchGroup: DispatchGroup? = nil, semaphore: DispatchSemaphore? = nil) -> AnyCancellable {
    semaphore?.wait()
    dispatchGroup?.enter()
    let sink = Amplify.API.mutate(request: .updateMobileUserToken(id: userID, token: newToken))
      .resultPublisher
      .sink {
        if case let .failure(error) = $0 {
          print("🔴 Failed to update device token \(error)")
        }
        dispatchGroup?.leave()
        semaphore?.signal()
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
  
  func updateCoordinates(userID: String, latitude: Double, longitude: Double) -> AnyCancellable {
    let sink = Amplify.API.mutate(request: .updateMobileUserCoordinate(id: userID, latitude: latitude, longitude: longitude))
      .resultPublisher
      .sink {
        if case let .failure(error) = $0 {
          print("🔴 Failed to update device coordinate \(error)")
        }
      }
      receiveValue: { result in
        switch result {
        case .success(let todo):
          print("🟢 Successfully updated device coordinate: \(todo)")
        case .failure(let error):
          print("🔴 Got failed result updating device coordinate \(error.errorDescription)")
        }
      }
    return sink
  }
    
  enum AmplifyError: Error {
      case unknown
    }
  
}
