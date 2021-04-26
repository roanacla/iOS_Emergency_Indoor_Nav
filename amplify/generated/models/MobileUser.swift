// swiftlint:disable all
import Amplify
import Foundation

public struct MobileUser: Model {
  public let id: String
  public var deviceTokenId: String?
  public var location: String?
  public var latitude: Double?
  public var longitude: Double?
  public var buildingId: String
  
  public init(id: String = UUID().uuidString,
      deviceTokenId: String? = nil,
      location: String? = nil,
      latitude: Double? = nil,
      longitude: Double? = nil,
      buildingId: String) {
      self.id = id
      self.deviceTokenId = deviceTokenId
      self.location = location
      self.latitude = latitude
      self.longitude = longitude
      self.buildingId = buildingId
  }
}