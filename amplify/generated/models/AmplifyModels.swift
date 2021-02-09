// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "dda6d2f229c55313c4aea1a90a2a0aff"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: MobileUser.self)
  }
}