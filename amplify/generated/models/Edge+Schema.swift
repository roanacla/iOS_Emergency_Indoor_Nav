// swiftlint:disable all
import Amplify
import Foundation

extension Edge {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case buildingId
    case sourceIoTId
    case sourceIoT
    case destinationIoTId
    case destinationIoT
    case isActive
    case canBeDeactivated
    case name
    case latitude
    case longitude
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let edge = Edge.keys
    
    model.pluralName = "Edges"
    
    model.fields(
      .id(),
      .field(edge.buildingId, is: .required, ofType: .string),
      .field(edge.sourceIoTId, is: .required, ofType: .string),
      .hasOne(edge.sourceIoT, is: .optional, ofType: IoT.self, associatedWith: IoT.keys.id),
      .field(edge.destinationIoTId, is: .required, ofType: .string),
      .hasOne(edge.destinationIoT, is: .optional, ofType: IoT.self, associatedWith: IoT.keys.id),
      .field(edge.isActive, is: .required, ofType: .bool),
      .field(edge.canBeDeactivated, is: .required, ofType: .bool),
      .field(edge.name, is: .optional, ofType: .string),
      .field(edge.latitude, is: .optional, ofType: .double),
      .field(edge.longitude, is: .optional, ofType: .double)
    )
    }
}