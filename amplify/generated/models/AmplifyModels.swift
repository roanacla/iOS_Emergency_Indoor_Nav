// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "ddef03c6ad020341a22b4c1788a64e8d"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Building.self)
    ModelRegistry.register(modelType: Edge.self)
    ModelRegistry.register(modelType: IoT.self)
    ModelRegistry.register(modelType: MobileUser.self)
  }
}