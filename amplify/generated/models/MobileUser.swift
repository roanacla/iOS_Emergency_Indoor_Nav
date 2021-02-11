// swiftlint:disable all
import Amplify
import Foundation

public struct MobileUser: Model {
  public let id: String
  public var deviceTokenId: String?
  public var location: String?
  
  public init(id: String = UUID().uuidString,
      deviceTokenId: String? = nil,
      location: String? = nil) {
      self.id = id
      self.deviceTokenId = deviceTokenId
      self.location = location
  }
}
