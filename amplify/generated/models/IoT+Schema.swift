// swiftlint:disable all
import Amplify
import Foundation

extension IoT {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case number
    case latitude
    case longitude
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let ioT = IoT.keys
    
    model.pluralName = "IoTS"
    
    model.fields(
      .id(),
      .field(ioT.name, is: .optional, ofType: .string),
      .field(ioT.number, is: .optional, ofType: .int),
      .field(ioT.latitude, is: .optional, ofType: .double),
      .field(ioT.longitude, is: .optional, ofType: .double)
    )
    }
}