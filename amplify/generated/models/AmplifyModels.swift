// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "2562654ec1370e71bc0a9d498ce76fd8"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Building.self)
    ModelRegistry.register(modelType: Edge.self)
    ModelRegistry.register(modelType: IoT.self)
    ModelRegistry.register(modelType: MobileUser.self)
  }
}