//
//  IndoorMapViewController+LocationManagerDelegate.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 3/3/21.
//
import CoreLocation
import Foundation
import UIKit
import MapKit
import UserNotifications

//MARK: - LocationManager Delegate
extension IndoorMapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let currentLocation = locations.first else { return }
    self.currentLocation = currentLocation
    //    print("🗺 \(currentLocation.coordinate.latitude) \(currentLocation.coordinate.longitude)")
    //    print(currentLocation)
    //    guard let distanceInMeters = selectedPlace?.location.distance(from: currentLocation) else { return }
    //    let distance = Measurement(value: distanceInMeters, unit: UnitLength.meters).converted(to: .miles)
    //    locationDistance.text = "\(distance)"
    
  }
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if presentedViewController == nil {
//      display alert margin....
//      displaySafeMessage()
//      pushLocalNotification(for: region)
    }
  }
  
  func displaySafeMessage() {
    let alertController = UIAlertController(title: "You are safe now", message: "Plasese wait for first responder's instrucitons", preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK", style: .default) {
      [weak self] action in
      self?.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(alertAction)
    present(alertController, animated: false, completion: nil)
  }
  
  func pushLocalNotification(for region: CLRegion) {
    let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
    let content = UNMutableNotificationContent()
    content.title = "You are safe now"

    content.sound = UNNotificationSound.default
    

//      if let badge = badge, let number = Int(badge) {
//        content.badge = NSNumber(value: number)
//      }
    
    let identifier = UUID().uuidString
    let request = UNNotificationRequest(identifier: identifier,
                                        content: content,
                                        trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) {
      [weak self] error in
      
      guard let self = self else { return }

      if let error = error {
        print("🔴 Error displaying location notification")
      } else {
        DispatchQueue.main.async {
          self.navigationController?.popToRootViewController(
            animated: true)
        }
      }
    }
  }
  
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print(error.localizedDescription)
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      locationManager.startUpdatingLocation()
      activateLocationServices()
    }
    
  }
  
  private func activateLocationServices() {
    if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
      for safeRegion in safeRegions {
        let region = CLCircularRegion(center: safeRegion.location.coordinate, radius: 100.0, identifier: safeRegion.name)
        region.notifyOnEntry = true
        locationManager.startMonitoring(for: region)
//        mapView.addOverlay(MKCircle(center: safeRegion.location.coordinate, radius: 100.0)) //draw safety circle
      }
    }
    locationManager.startUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}
