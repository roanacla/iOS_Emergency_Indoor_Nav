// swiftlint:disable all
import Amplify
import Foundation

public struct MobileUser: Model {
  public let id: String
  public var location: String?
  
  public init(id: String = UUID().uuidString,
      location: String? = nil) {
      self.id = id
      self.location = location
  }
}