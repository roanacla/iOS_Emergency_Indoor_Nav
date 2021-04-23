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
  
  //MARK: - Properties
  var subscriptions = Set<AnyCancellable>()
  var safeRegions: [SafeRegion] = []
  var beaconsDict: [String: Beacon] = [:]
  
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
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.badge, .sound, .alert]) {
      [weak self] granted, error in
      guard granted else { return }
      
      center.delegate = self
      DispatchQueue.main.async {
        application.registerForRemoteNotifications()
      }
    }
    
    loadSafeRegions()
    loadBeacons()
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
    
    //Always update token in local device
    UserDefaults.standard.set(token, forKey: UserDefaultsKeys.deviceTokenID)
    
    //Create user or update token in provider
    if UserDefaults.standard.value(forKey: UserDefaultsKeys.userID) == nil {
      self.createUserSubs()
        .store(in: &subscriptions)
    } else {
      self.updateToken()
        .store(in: &subscriptions)
      self.updateLocation()?
        .store(in: &subscriptions)
    }
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  
  
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
    @escaping (UNNotificationPresentationOptions) -> Void) {
    
    completionHandler([.banner, .sound, .badge])
  }
  
  
  

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void) {
    guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
      return
    }
    
    let userInfo = response.notification.request.content.userInfo
    if let notification = userInfo["shortestPath"] as? String {
      let jsonData = notification.data(using: .utf8)!
      let decoder = JSONDecoder()
      let remoteCommands = try! decoder.decode(RemoteCommands.self, from: jsonData)
      if let vc = rootViewController as? IndoorMapViewController {
        vc.startSafeMode(path: remoteCommands.shortestPath)
      }
    }

    completionHandler()
  }
  
}


extension AppDelegate {
  
  func createUserSubs() -> AnyCancellable {
    let useCase = CreateUserUseCase(userID: UserDefaultsData.userID,
                                    tokenID: UserDefaultsData.deviceTokenId,
                                    remoteAPI: MobileUserAmplifyAPI())
    return useCase.start()
  }
  
  func updateToken() -> AnyCancellable {
    let useCase = UpdateDeviceTokenIdUseCase(userID: UserDefaultsData.userID,
                                             tokenID: UserDefaultsData.deviceTokenId,
                                             remoteAPI: MobileUserAmplifyAPI())
    return useCase.start()
  }
  
  
  func updateLocation() -> AnyCancellable? {
    guard let beacon = beaconsDict.randomElement() else { return nil }
//    let beacon = beaconsDict.filter({$0.key == "W-16"}).first!
    let updateLocationUseCase = UpdateLocationUseCase(userID: UserDefaultsData.userID,
                                                      tokenID: UserDefaultsData.deviceTokenId,
                                                      location: beacon.value.name,
                                                      remoteAPI: MobileUserAmplifyAPI())

    return updateLocationUseCase.start()
  }
  
  func loadBeacons() {
    guard let entries = loadPlist(for: "Beacons") else { fatalError("Unable to load data") }
    
    for property in entries {
      guard let name = property["Name"] as? String,
            let latitude = property["Latitude"] as? NSNumber,
            let longitude = property["Longitude"] as? NSNumber else { fatalError("Error reading data") }
      
      let beacon = Beacon(name: name, latitude: latitude.doubleValue, longitude: longitude.doubleValue)
      beaconsDict[beacon.name] = beacon
    }
  }
  
  func loadSafeRegions() {
    guard let entries = loadPlist(for: "SafeRegions") else { fatalError("Unable to load data") }
    
    for property in entries {
      guard let name = property["Name"] as? String,
            let latitude = property["Latitude"] as? NSNumber,
            let longitude = property["Longitude"] as? NSNumber else { fatalError("Error reading data") }

      let safeRegion = SafeRegion(latitude: latitude.doubleValue, longitude: longitude.doubleValue, name: name)
      safeRegions.append(safeRegion)
    }
  }
  
  private func loadPlist(for filename: String) -> [[String: Any]]? {
    guard let plistUrl = Bundle.main.url(forResource: filename, withExtension: "plist"),
      let plistData = try? Data(contentsOf: plistUrl) else { return nil }
    var placedEntries: [[String: Any]]? = nil
    
    do {
      placedEntries = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [[String: Any]]
    } catch {
      print("error reading plist")
    }
    return placedEntries
  }
  
}

