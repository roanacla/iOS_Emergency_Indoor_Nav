// swiftlint:disable all
import Amplify
import Foundation

extension Building {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case isInEmergency
    case emergencyDescription
    case edges
    case mobileUsers
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let building = Building.keys
    
    model.pluralName = "Buildings"
    
    model.fields(
      .id(),
      .field(building.isInEmergency, is: .optional, ofType: .bool),
      .field(building.emergencyDescription, is: .optional, ofType: .string),
      .hasMany(building.edges, is: .optional, ofType: Edge.self, associatedWith: Edge.keys.buildingId),
      .hasMany(building.mobileUsers, is: .optional, ofType: MobileUser.self, associatedWith: MobileUser.keys.buildingId)
    )
    }
}