import Foundation

public protocol CoreAIRepositoryRemote: Sendable {
  func repositoryManifest(
    repository: String,
    revision: String
  ) async throws -> CoreAIRepositoryManifest

  func artifactManifest(
    for variant: CoreAIModelVariant
  ) async throws -> CoreAIArtifactManifest

  func download(
    descriptor: CoreAIArtifactDescriptor,
    for variant: CoreAIModelVariant,
    to destinationRoot: URL,
    progress: @escaping @Sendable (CoreAIDownloadProgress) -> Void
  ) async throws
}
