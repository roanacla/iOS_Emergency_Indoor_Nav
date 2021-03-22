// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "925ca280e84c2a4d755d191eef05b9e4"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: MobileUser.self)
  }
}