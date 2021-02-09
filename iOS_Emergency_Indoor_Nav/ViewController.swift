//
//  ViewController.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 1/27/21.
//

import UIKit
import Amplify
import Combine

class ViewController: UIViewController {
  
  private var subscriptions = Set<AnyCancellable>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //    createUser()
    //      .store(in: &subscriptions)
        updateLocation()
          .store(in: &subscriptions)
    //    updateToken()?
    //      .store(in: &subscriptions)
//    getMobileUser()?
//      .store(in: &subscriptions)
  }
  
  deinit {
    subscriptions.removeAll()
  }
  
  func createUser() -> AnyCancellable {
    let useCase = CreateUserUseCase(userID: UserDefaultsKeys.userID,
                                    remoteAPI: MobileUserAmplifyAPI())
    
    return useCase.start()
  }
  
  func updateLocation() -> AnyCancellable {

    
    let api = MobileUserAmplifyAPI()
    let mobileUserPublisher = api.getMobileUser(withID: UserDefaultsKeys.userID).map{$0}
    let test = mobileUserPublisher.map({ mobileUser -> AnyCancellable in
      let useCase = UpdateLocationUseCase(userID: mobileUser!.id,
                                          location: "Peru",
                                          remoteAPI: MobileUserAmplifyAPI())
      return useCase.start()
      
    })
    return test.sink(receiveCompletion: {_ in }
                     , receiveValue: { print($0) })
  }
  
  func updateToken() -> AnyCancellable? {
    guard let deviceTokenID = UserDefaults.standard.string(forKey: UserDefaultsKeys.deviceTokenId) else { return nil  }
    let useCase = UpdateDeviceTokenIdUseCase(userID: UserDefaultsKeys.userID,
                                             deviceTokenId: deviceTokenID,
                                             remoteAPI: MobileUserAmplifyAPI())
    
    return useCase.start()
  }
  
  
  
  func getMobileUser() -> AnyCancellable? {
    let amplifyAPI = MobileUserAmplifyAPI()
    let publisher = amplifyAPI.getMobileUser(withID: UserDefaultsKeys.userID)

    return publisher
      .sink(receiveCompletion: { result in
        switch result {
        case .finished:
          print("Yes")

        default:
          print("Something is wrong")
        }
      }, receiveValue: { result in
        guard let result = result else { return }
        print("🟢")
        print(result)
      })
  }
}

