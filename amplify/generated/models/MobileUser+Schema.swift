// swiftlint:disable all
import Amplify
import Foundation

extension MobileUser {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case deviceTokenId
    case location
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let mobileUser = MobileUser.keys
    
    model.pluralName = "MobileUsers"
    
    model.fields(
      .id(),
      .field(mobileUser.deviceTokenId, is: .optional, ofType: .string),
      .field(mobileUser.location, is: .optional, ofType: .string)
    )
    }
}