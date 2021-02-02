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
    updateLocation()
      .store(in: &subscriptions)
  }
  
  deinit {
    subscriptions.removeAll()
  }
  
  func updateLocation() -> AnyCancellable {
    let useCase =  UpdateLocationUseCase(userID: "FBD639B5-78C1-4DD8-B0FB-D2E8626FCBB6",
                                         location: "Santiago",
                                         remoteAPI: MobileUserAmplifyAPI())
    return useCase.start()
  }
  
}

