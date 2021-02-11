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
    let updateLocationUseCase = UpdateLocationUseCase(userID: UserDefaultsData.userID,
                                                      location: "Colombia",
                                                      remoteAPI: MobileUserAmplifyAPI())
    
    return updateLocationUseCase.start()
  }
}

