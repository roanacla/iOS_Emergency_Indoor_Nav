// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "aa10e54c726e0520daab4d2a2c8c04c3"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Building.self)
    ModelRegistry.register(modelType: Edge.self)
    ModelRegistry.register(modelType: IoT.self)
    ModelRegistry.register(modelType: MobileUser.self)
  }
}