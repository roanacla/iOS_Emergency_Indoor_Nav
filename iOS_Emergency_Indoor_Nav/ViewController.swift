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
    // Do any additional setup after loading the view.
//    createMobileUser().store(in: &subscriptions)
    _ = createMobileUser()
//    createTodo()
  }
  
  deinit {
    subscriptions.removeAll()
  }
  
  func createMobileUser() -> AnyCancellable {
    let mobileUser = MobileUser(id: UUID().description , location: "Test") //(name: "my first todo", description: "todo description")
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
              print("Successfully created a mobileUser: \(todo)")
          case .failure(let graphQLError):
              print("Could not decode result: \(graphQLError)")
          }
      }
      return sink
  }
  
}

