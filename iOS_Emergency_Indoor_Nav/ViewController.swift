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
        updateLocation()?
          .store(in: &subscriptions)
  }
  
  deinit {
    subscriptions.removeAll()
  }
  
  func updateLocation() -> AnyCancellable? {

    
    let remoteAPI = MobileUserAmplifyAPI()
    let subscription =
      remoteAPI
      .getMobileUser(withID: UserDefaultsData.userID)
      .map{$0}
      .map{ mobileUser -> AnyCancellable? in
        guard let mobileUser = mobileUser else { return nil }
        let useCase = UpdateLocationUseCase(mobileUser: mobileUser,
                                            location: "Peru",
                                            remoteAPI: remoteAPI)
        return useCase.start()
        
      }
      .sink(
        receiveCompletion: {_ in },
        receiveValue: { print($0) }
      )
    
    return subscription
  }
}

