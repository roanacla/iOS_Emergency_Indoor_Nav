// swiftlint:disable all
import Amplify
import Foundation

public struct Edge: Model {
  public let id: String
  public var buildingId: String
  public var sourceIoTId: String
  public var sourceIoT: IoT?
  public var destinationIoTId: String
  public var destinationIoT: IoT?
  public var isActive: Bool
  public var canBeDeactivated: Bool
  public var name: String?
  public var latitude: Double?
  public var longitude: Double?
  
  public init(id: String = UUID().uuidString,
      buildingId: String,
      sourceIoTId: String,
      sourceIoT: IoT? = nil,
      destinationIoTId: String,
      destinationIoT: IoT? = nil,
      isActive: Bool,
      canBeDeactivated: Bool,
      name: String? = nil,
      latitude: Double? = nil,
      longitude: Double? = nil) {
      self.id = id
      self.buildingId = buildingId
      self.sourceIoTId = sourceIoTId
      self.sourceIoT = sourceIoT
      self.destinationIoTId = destinationIoTId
      self.destinationIoT = destinationIoT
      self.isActive = isActive
      self.canBeDeactivated = canBeDeactivated
      self.name = name
      self.latitude = latitude
      self.longitude = longitude
  }
}