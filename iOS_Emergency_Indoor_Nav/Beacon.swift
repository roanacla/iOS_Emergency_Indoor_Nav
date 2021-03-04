//
//  Beacon.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 3/3/21.
//

import Foundation
import CoreLocation

struct Beacon {
  var name: String
  let location: CLLocation
  
  init(name: String, latitude: Double, longitude: Double) {
    self.location = CLLocation(latitude: latitude, longitude: longitude)
    self.name = name
  }
}
