/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The main view controller.
 */

import UIKit
import CoreLocation
import MapKit
import Combine
import Amplify

class IndoorMapViewController: UIViewController, LevelPickerDelegate {
  //MARK: - IBOutlets
  @IBOutlet var mapView: MKMapView!
  let locationManager = CLLocationManager()
  @IBOutlet var levelPicker: LevelPickerView!
  
  //MARK: - Properties
  var currentLocation: CLLocation?
  var safeRegions: [SafeRegion] = []
  var beaconsDict: [String: Beacon] = [:]
  private var subscriptions = Set<AnyCancellable>()
  
  var venue: Venue?
  var levels: [Level] = []
  var currentLevelFeatures = [StylableFeature]()
  var currentLevelOverlays = [MKOverlay]()
  var currentLevelAnnotations = [MKAnnotation]()
  let pointAnnotationViewIdentifier = "PointAnnotationView"
  let labelAnnotationViewIdentifier = "LabelAnnotationView"
  
  // MARK: - View life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //TODO: Use just to pin locations - Delete for production
//    let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(IndoorMapViewController.handleLongPress(_:)))
//    longPressRecogniser.minimumPressDuration = 1.0
//    mapView.addGestureRecognizer(longPressRecogniser)
    
    // Request location authorization so the user's current location can be displayed on the map
    locationManager.requestWhenInUseAuthorization()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.requestLocation()
    
    self.mapView.delegate = self
    self.mapView.register(PointAnnotationView.self, forAnnotationViewWithReuseIdentifier: pointAnnotationViewIdentifier)
    self.mapView.register(LabelAnnotationView.self, forAnnotationViewWithReuseIdentifier: labelAnnotationViewIdentifier)
    
    // Decode the IMDF data. In this case, IMDF data is stored locally in the current bundle.
    let imdfDirectory = Bundle.main.resourceURL!.appendingPathComponent("IMDFData")
    do {
      let imdfDecoder = IMDFDecoder()
      venue = try imdfDecoder.decode(imdfDirectory)
    } catch let error {
      print(error)
    }
    
    // You might have multiple levels per ordinal. A selected level picker item displays all levels with the same ordinal.
    if let levelsByOrdinal = self.venue?.levelsByOrdinal {
      let levels = levelsByOrdinal.mapValues { (levels: [Level]) -> [Level] in
        // Choose indoor level over outdoor level
        if let level = levels.first(where: { $0.properties.outdoor == false }) {
          return [level]
        } else {
          return [levels.first!]
        }
      }.flatMap({ $0.value })
      
      // Sort levels by their ordinal numbers
      self.levels = levels.sorted(by: { $0.properties.ordinal > $1.properties.ordinal })
    }
    
    // Set the map view's region to enclose the venue
    if let venue = venue, let venueOverlay = venue.geometry[0] as? MKOverlay {
      self.mapView.setVisibleMapRect(venueOverlay.boundingMapRect, edgePadding:
                                      UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: false)
    }
    
    // Display a default level at start, for example a level with ordinal 0
    showFeaturesForOrdinal(0)
    
    // Setup the level picker with the shortName of each level
    setupLevelPicker()
    
    drawSafeArea()
    loadSafeRegions()
    loadBeacons()
    //TODO: The async bellow causes an error the first time, handle that. 
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // change 2 to desired number of seconds
      self.updateLocation()?
        .store(in: &self.subscriptions)
    }
    
  }
  
  //TODO: Use just to pin locations - Delete for production
//  @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
//      if gestureRecognizer.state != .began { return }
//
//      let touchPoint = gestureRecognizer.location(in: mapView)
//      let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
//    print("🧭")
//      print(touchMapCoordinate)
//    let newPin = MKPointAnnotation()
//    newPin.coordinate = touchMapCoordinate
//    mapView.addAnnotation(newPin)
//  }
  
  deinit {
    subscriptions.removeAll()
  }
  
  //MARK: - IBActions
  @IBAction func showRoute(_ sender: Any) {
    loadDirections(path: [])
  }
  
  //MARK: - Functions
  
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
  
  func loadDirections(path: [String]) { //e.i. ["W-10", "W-12", "W-15", "W-16"]
    guard !path.isEmpty else { return }
    var points: [CLLocationCoordinate2D] = []
    
    for node in path {
      if let beacon = beaconsDict[node] {
        points.append(CLLocationCoordinate2DMake(beacon.location.coordinate.latitude,
                                                 beacon.location.coordinate.longitude))
      }
    }
    
    let polygon = MKPolyline(coordinates: &points, count: points.count)
    mapView.addOverlay(polygon)
 
  }
  
  func drawSafeArea() {
    var points: [CLLocationCoordinate2D] = []
    
    points.append(CLLocationCoordinate2DMake(37.32995498762128, -121.88921548426148))
    points.append(CLLocationCoordinate2DMake(37.33013520698357, -121.88883930444716))
    points.append(CLLocationCoordinate2DMake(37.33036074717399, -121.88900962471959))
    points.append(CLLocationCoordinate2DMake(37.33018212793003, -121.88938647508618))
    
    let safeAreaPolygon = MKPolygon(coordinates: &points, count: points.count)  
    mapView.addOverlay(safeAreaPolygon)
  }
  
  func updateLocation() -> AnyCancellable? {
    guard let beacon = beaconsDict.randomElement() else { return nil }
    let updateLocationUseCase = UpdateLocationUseCase(userID: UserDefaultsData.userID,
                                                      tokenID: UserDefaultsData.deviceTokenId,
                                                      location: beacon.value.name,
                                                      remoteAPI: MobileUserAmplifyAPI())

    return updateLocationUseCase.start()
  }
  
  // MARK: - LevelPickerDelegate
  
  func selectedLevelDidChange(selectedIndex: Int) {
    precondition(selectedIndex >= 0 && selectedIndex < self.levels.count)
    let selectedLevel = self.levels[selectedIndex]
    showFeaturesForOrdinal(selectedLevel.properties.ordinal)
  }
}
