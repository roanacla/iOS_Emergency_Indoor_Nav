// swiftlint:disable all
import Amplify
import Foundation

public struct Building: Model {
  public let id: String
  public var edges: List<Edge>?
  public var mobileUsers: List<MobileUser>?
  
  public init(id: String = UUID().uuidString,
      edges: List<Edge>? = [],
      mobileUsers: List<MobileUser>? = []) {
      self.id = id
      self.edges = edges
      self.mobileUsers = mobileUsers
  }
}