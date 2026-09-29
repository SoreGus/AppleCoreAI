import Foundation

#if canImport(CoreAI)
  import CoreAI
#endif

public actor CoreAIPreparer {
  public init() {}

  @available(iOS 27.0, macOS 27.0, *)
  public func specialize(
    _ artifact: CoreAIArtifact
  ) async throws -> Data {
    #if canImport(CoreAI)
      do {
        let model = try await AIModel.specialize(
          contentsOf: artifact.url,
          options: .default,
          cachePolicy: .persistent
        )
        return model.bookmarkData
      } catch {
        throw AppleCoreAIError.preparationFailed(error.localizedDescription)
      }
    #else
      throw AppleCoreAIError.unsupportedPlatform
    #endif
  }

  @available(iOS 27.0, macOS 27.0, *)
  public func deleteSpecialization(
    referencedBy bookmark: Data
  ) throws {
    #if canImport(CoreAI)
      do {
        try AIModelCache.deleteEntry(referencedBy: bookmark)
      } catch {
        throw AppleCoreAIError.preparationFailed(error.localizedDescription)
      }
    #else
      throw AppleCoreAIError.unsupportedPlatform
    #endif
  }
}
