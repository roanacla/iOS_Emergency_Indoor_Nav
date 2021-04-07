// swiftlint:disable all
import Amplify
import Foundation

public struct IoT: Model {
  public let id: String
  public var name: String?
  public var number: Int?
  public var latitude: Double?
  public var longitude: Double?
  
  public init(id: String = UUID().uuidString,
      name: String? = nil,
      number: Int? = nil,
      latitude: Double? = nil,
      longitude: Double? = nil) {
      self.id = id
      self.name = name
      self.number = number
      self.latitude = latitude
      self.longitude = longitude
  }
}