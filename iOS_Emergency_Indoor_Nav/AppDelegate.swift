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
  let dispatchGroup = DispatchGroup()
  let semaphore: DispatchSemaphore? = DispatchSemaphore(value: 1)
  
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
    
    #if targetEnvironment(simulator) // Simulator doesn't have notifications, thus updates data from here
    UserDefaults.standard.setValue(UUID().uuidString, forKey: UserDefaultsKeys.deviceTokenID)
    self.updateUserData()
    #endif
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
    self.updateUserData()
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
    guard let vc = rootViewController as? IndoorMapViewController else { return }
    guard let code = Int(userInfo["actionCode"] as! String) else { return }
    switch code {
    case 0:
      guard let notification = userInfo["shortestPath"] as? String else { return }
      let jsonData = notification.data(using: .utf8)!
      let decoder = JSONDecoder()
      var path: [String] = []
      path = try! decoder.decode([String].self, from: jsonData)
      vc.startSafeMode(path: path)
    case 1:
      vc.displayWaitForRescueMessage()
    case 2:
      vc.displayGetCloseToTheWindows()
    default:
      break
    }

    completionHandler()
  }
  
}


extension AppDelegate {
  
  func updateUserData() {
    DispatchQueue.global(qos: .userInitiated).async(group: dispatchGroup) {
      if UserDefaults.standard.value(forKey: UserDefaultsKeys.userID) == nil {
        self.createUserSubs()
          .store(in: &self.subscriptions)
      }
      self.updateLocation()?
        .store(in: &self.subscriptions)
      self.updateToken()
        .store(in: &self.subscriptions)
    }
  }
  
  func createUserSubs() -> AnyCancellable {
    
    let useCase = CreateUserUseCase(userID: UserDefaultsData.userID,
                                    remoteAPI: MobileUserAmplifyAPI())
    return useCase.start(dispatchGroup: dispatchGroup, semaphore: semaphore)
  }
  
  func updateToken() -> AnyCancellable {
    let useCase = UpdateDeviceTokenIdUseCase(userID: UserDefaultsData.userID,
                                             //deviceTokenId updated in didRegisterForRemoteNotificationsWithDeviceToken
                                             tokenID: UserDefaultsData.deviceTokenId,
                                             remoteAPI: MobileUserAmplifyAPI())
    return useCase.start(dispatchGroup: dispatchGroup, semaphore: semaphore)
  }
  
  
  func updateLocation() -> AnyCancellable? {
    guard var beacon = beaconsDict.randomElement() else { return nil }
    #if DEBUG
    while beacon.value.name == "W-16" {
      beacon = beaconsDict.randomElement()!
    }
    #endif
    let updateLocationUseCase = UpdateLocationUseCase(userID: UserDefaultsData.userID,
                                                      tokenID: UserDefaultsData.deviceTokenId,
                                                      location: beacon.value.name,
                                                      remoteAPI: MobileUserAmplifyAPI())
    return updateLocationUseCase.start(dispatchGroup: dispatchGroup, semaphore: semaphore)
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

