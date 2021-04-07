// swiftlint:disable all
import Amplify
import Foundation

extension Building {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
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
      .hasMany(building.edges, is: .optional, ofType: Edge.self, associatedWith: Edge.keys.building),
      .hasMany(building.mobileUsers, is: .optional, ofType: MobileUser.self, associatedWith: MobileUser.keys.buildingId)
    )
    }
}