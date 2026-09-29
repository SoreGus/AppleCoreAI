import Foundation

public struct CoreAIArtifactManifest: Codable, Sendable {
  public let version: Int
  public let createdAt: String
  public let artifactName: String
  public let sourceModel: String?
  public let sourceRepository: String?
  public let sourceRevision: String?
  public let sourceReference: String?
  public let variant: String?
  public let modelKind: CoreAIModelKind
  public let platforms: [CoreAIPlatform]
  public let minimumOSVersions: [String: String]
  public let coreAIToolingVersion: String?
  public let torchVersion: String?
  public let artifact: CoreAIArtifactDescriptor?
  public let preparedArtifact: CoreAIArtifactDescriptor?
  public let files: [CoreAIArtifactFile]

  enum CodingKeys: String, CodingKey {
    case version
    case createdAt = "created_at"
    case artifactName = "artifact_name"
    case sourceModel = "source_model"
    case sourceRepository = "source_repository"
    case sourceRevision = "source_revision"
    case sourceReference = "source_reference"
    case variant
    case modelKind = "model_kind"
    case platforms
    case minimumOSVersions = "minimum_os_versions"
    case coreAIToolingVersion = "coreai_tooling_version"
    case torchVersion = "torch_version"
    case artifact
    case preparedArtifact = "prepared_artifact"
    case files
  }
}
