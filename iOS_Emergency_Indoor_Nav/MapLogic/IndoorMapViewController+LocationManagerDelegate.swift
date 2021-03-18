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
      let alertController = UIAlertController(title: "You are safe now", message: "Plasese wait for first responder's instrucitons", preferredStyle: .alert)
      let alertAction = UIAlertAction(title: "OK", style: .default) {
        [weak self] action in
        self?.dismiss(animated: true, completion: nil)
      }
      alertController.addAction(alertAction)
      present(alertController, animated: false, completion: nil)
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
        let region = CLCircularRegion(center: safeRegion.location.coordinate, radius: 10.0, identifier: safeRegion.name)
        region.notifyOnEntry = true
        locationManager.startMonitoring(for: region)
        mapView.addOverlay(MKCircle(center: safeRegion.location.coordinate, radius: 10.0))
      }
    }
    locationManager.startUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}
