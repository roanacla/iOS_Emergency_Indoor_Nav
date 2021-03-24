//
//  SafeRegions.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 2/26/21.
//

import Foundation
import CoreLocation

class SafeRegion {
  
  let location: CLLocation
  let name: String
  
  init(latitude: Double, longitude: Double, name: String) {
    self.location = CLLocation(latitude: latitude, longitude: longitude)
    self.name = name
  }
  
}
