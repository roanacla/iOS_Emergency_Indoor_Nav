//
//  AppDelegate.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 1/27/21.
//

import UIKit
import Amplify
import AmplifyPlugins
import UserNotifications
import Combine

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var subscriptions = Set<AnyCancellable>()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    //Configures the communication with AWS resources
    do {
      Amplify.Logging.logLevel = .verbose
      try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: AmplifyModels()))
      try Amplify.configure()
    } catch {
      print("An error occurred setting up Amplify: \(error)")
    }
    
    //Request authorization with APNS (Apple Push Notifications)
    if UserDefaults.standard.value(forKey: UserDefaultsKeys.userID) == nil {
      self.createUserSubs()
        .store(in: &subscriptions)
    }
    UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {granted, error in
      guard granted else { return }
      DispatchQueue.main.async {
        application.registerForRemoteNotifications()
      }
    })
        
    return true
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.reduce("", { $0 + String(format: "%02x", $1) })
    UserDefaults.standard.set(token, forKey: UserDefaultsKeys.deviceTokenID)
    self.updateTokenSubs()
      .store(in: &subscriptions)
  }
  
  
}

extension AppDelegate {
  
  func createUserSubs() -> AnyCancellable {
    let useCase = CreateUserUseCase(userID: UserDefaultsData.userID,
                                    remoteAPI: MobileUserAmplifyAPI())
    return useCase.start()
  }
  
  func updateTokenSubs() -> AnyCancellable {
    
    let useCase = UpdateDeviceTokenIdUseCase(userID: UserDefaultsData.userID,
                                             tokenID: UserDefaultsData.deviceTokenId,
                                             remoteAPI: MobileUserAmplifyAPI())
    return useCase.start()
  }
}

