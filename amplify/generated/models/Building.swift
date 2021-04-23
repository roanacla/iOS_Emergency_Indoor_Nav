// swiftlint:disable all
import Amplify
import Foundation

public struct Building: Model {
  public let id: String
  public var isInEmergency: Bool?
  public var emergencyDescription: String?
  public var edges: List<Edge>?
  public var mobileUsers: List<MobileUser>?
  
  public init(id: String = UUID().uuidString,
      isInEmergency: Bool? = nil,
      emergencyDescription: String? = nil,
      edges: List<Edge>? = [],
      mobileUsers: List<MobileUser>? = []) {
      self.id = id
      self.isInEmergency = isInEmergency
      self.emergencyDescription = emergencyDescription
      self.edges = edges
      self.mobileUsers = mobileUsers
  }
}