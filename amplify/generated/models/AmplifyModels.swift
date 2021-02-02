// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "fa8d11e7eded6cc118c6b838894d9305"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: MobileUser.self)
  }
}