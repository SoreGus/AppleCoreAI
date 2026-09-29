import Foundation

public struct CoreAIRepositoryManifest: Codable, Sendable {
  public let version: Int
  public let updatedAt: String
  public let artifacts: [CoreAIRepositoryArtifactEntry]

  enum CodingKeys: String, CodingKey {
    case version
    case updatedAt = "updated_at"
    case artifacts
  }

  public init(
    version: Int,
    updatedAt: String,
    artifacts: [CoreAIRepositoryArtifactEntry]
  ) {
    self.version = version
    self.updatedAt = updatedAt
    self.artifacts = artifacts
  }
}

public struct CoreAIRepositoryArtifactEntry: Codable, Hashable, Sendable {
  public let artifactName: String
  public let manifestPath: String
  public let variant: String?
  public let modelKind: CoreAIModelKind
  public let platforms: [CoreAIPlatform]
  public let minimumOSVersions: [String: String]
  public let sourceRepository: String?
  public let sourceRevision: String?
  public let artifact: CoreAIArtifactDescriptor?
  public let preparedArtifact: CoreAIArtifactDescriptor?

  enum CodingKeys: String, CodingKey {
    case artifactName = "artifact_name"
    case manifestPath = "manifest_path"
    case variant
    case modelKind = "model_kind"
    case platforms
    case minimumOSVersions = "minimum_os_versions"
    case sourceRepository = "source_repository"
    case sourceRevision = "source_revision"
    case artifact
    case preparedArtifact = "prepared_artifact"
  }
}
