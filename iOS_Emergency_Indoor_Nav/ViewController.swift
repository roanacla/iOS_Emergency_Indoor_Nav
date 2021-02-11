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
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 10) { // change 2 to desired number of seconds
      self.updateLocation()?
        .store(in: &self.subscriptions)
    }
  }
  
  deinit {
    subscriptions.removeAll()
  }
  
  func updateLocation() -> AnyCancellable? {
    let updateLocationUseCase = UpdateLocationUseCase(userID: UserDefaultsData.userID,
                                                      tokenID: UserDefaultsData.deviceTokenId,
                                                      location: "Colombia",
                                                      remoteAPI: MobileUserAmplifyAPI())
    
    return updateLocationUseCase.start()
  }
}

