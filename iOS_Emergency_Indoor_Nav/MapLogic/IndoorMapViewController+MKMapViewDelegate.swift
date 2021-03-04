//
//  IndoorMapViewController+MKMapViewDelegate.swift
//  iOS_Emergency_Indoor_Nav
//
//  Created by Roger Navarro on 3/3/21.
//

import Foundation
import MapKit


extension IndoorMapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let shape = overlay as? (MKShape & MKGeoJSONObject),
          let feature = currentLevelFeatures.first( where: { $0.geometry.contains( where: { $0 == shape  }) }) else {
      if overlay is MKPolygon {
        let polyLine = MKPolylineRenderer(overlay: overlay)
        polyLine.strokeColor = UIColor.darkGray
        polyLine.lineWidth = 4.0
        return polyLine
      } else {
        
        return MKOverlayRenderer(overlay: overlay)
      }
    }
    
    let renderer: MKOverlayPathRenderer
    switch overlay {
    case is MKMultiPolygon:
      renderer = MKMultiPolygonRenderer(overlay: overlay)
    case is MKPolygon:
      renderer = MKPolygonRenderer(overlay: overlay)
    case is MKMultiPolyline:
      renderer = MKMultiPolylineRenderer(overlay: overlay)
    case is MKPolyline:
      renderer = MKPolylineRenderer(overlay: overlay)
    default:
      return MKOverlayRenderer(overlay: overlay)
    }
    
    // Configure the overlay renderer's display properties in feature-specific ways.
    feature.configure(overlayRenderer: renderer)
    
    return renderer
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      return nil
    }
    
    if let stylableFeature = annotation as? StylableFeature {
      if stylableFeature is Occupant {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: labelAnnotationViewIdentifier, for: annotation)
        stylableFeature.configure(annotationView: annotationView)
        return annotationView
      } else {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointAnnotationViewIdentifier, for: annotation)
        stylableFeature.configure(annotationView: annotationView)
        return annotationView
      }
    }
    
    return nil
  }
  
  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    guard let venue = self.venue, let location = userLocation.location else {
      return
    }
    
    // Display location only if the user is inside this venue.
    var isUserInsideVenue = false
    let userMapPoint = MKMapPoint(location.coordinate)
    for geometry in venue.geometry {
      guard let overlay = geometry as? MKOverlay else {
        continue
      }
      
      if overlay.boundingMapRect.contains(userMapPoint) {
        isUserInsideVenue = true
        break
      }
    }
    
    guard isUserInsideVenue else {
      return
    }
    
    // If the device knows which level the user is physically on, automatically switch to that level.
    if let ordinal = location.floor?.level {
      showFeaturesForOrdinal(ordinal)
    }
  }
  
  func showFeaturesForOrdinal(_ ordinal: Int) {
    guard self.venue != nil else {
      return
    }
    
    // Clear out the previously-displayed level's geometry
    self.currentLevelFeatures.removeAll()
    self.mapView.removeOverlays(self.currentLevelOverlays)
    self.mapView.removeAnnotations(self.currentLevelAnnotations)
    self.currentLevelAnnotations.removeAll()
    self.currentLevelOverlays.removeAll()
    
    // Display the level's footprint, unit footprints, opening geometry, and occupant annotations
    if let levels = self.venue?.levelsByOrdinal[ordinal] {
      for level in levels {
        self.currentLevelFeatures.append(level)
        self.currentLevelFeatures += level.units
        self.currentLevelFeatures += level.openings
        
        let occupants = level.units.flatMap({ $0.occupants })
        let amenities = level.units.flatMap({ $0.amenities })
        self.currentLevelAnnotations += occupants
        self.currentLevelAnnotations += amenities
      }
    }
    
    let currentLevelGeometry = self.currentLevelFeatures.flatMap({ $0.geometry })
    self.currentLevelOverlays = currentLevelGeometry.compactMap({ $0 as? MKOverlay })
    
    // Add the current level's geometry to the map
    self.mapView.addOverlays(self.currentLevelOverlays)
    self.mapView.addAnnotations(self.currentLevelAnnotations)
  }
  
  func setupLevelPicker() {
    // Use the level's short name for a level picker item display name
    self.levelPicker.levelNames = self.levels.map {
      if let shortName = $0.properties.shortName.bestLocalizedValue {
        return shortName
      } else {
        return "\($0.properties.ordinal)"
      }
    }
    
    // Begin by displaying the level-specific information for Ordinal 0 (which is not necessarily the first level in the list).
    // $0.properties.ordinal:
    // C = 1
    // P = 0
    // LL = -1
    if let baseLevel = levels.first(where: { $0.properties.ordinal == 1 }) {
      levelPicker.selectedIndex = self.levels.firstIndex(of: baseLevel)!
    }
  }
}
