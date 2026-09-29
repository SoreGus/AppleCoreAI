import Foundation

public struct CoreAIModelVariant: Hashable, Sendable {
  public let repositoryIdentifier: String
  public let revision: String
  public let modelIdentifier: String
  public let identifier: String
  public let kind: CoreAIModelKind
  public let platforms: Set<CoreAIPlatform>
  public let minimumOSVersions: [String: String]
  public let manifestPath: String
  public let sourceRepository: String?
  public let sourceRevision: String?
  public let artifact: CoreAIArtifactDescriptor?
  public let preparedArtifact: CoreAIArtifactDescriptor?

  init(
    repositoryIdentifier: String,
    revision: String,
    entry: CoreAIRepositoryArtifactEntry
  ) {
    self.repositoryIdentifier = repositoryIdentifier
    self.revision = revision
    self.modelIdentifier = entry.artifactName
    self.identifier = entry.variant ?? "default"
    self.kind = entry.modelKind
    self.platforms = Set(entry.platforms)
    self.minimumOSVersions = entry.minimumOSVersions
    self.manifestPath = entry.manifestPath
    self.sourceRepository = entry.sourceRepository
    self.sourceRevision = entry.sourceRevision
    self.artifact = entry.artifact
    self.preparedArtifact = entry.preparedArtifact
  }

  public func isCompatible(
    with platform: CoreAIPlatform
  ) -> Bool {
    let platformMatch =
      platforms.isEmpty
      || platforms.contains(platform)
      || (platform == .iPadOS && platforms.contains(.iOS))

    guard platformMatch else {
      return false
    }

    let key = platform.rawValue
    let fallbackKey = platform == .iPadOS ? CoreAIPlatform.iOS.rawValue : key
    let minimumVersion = minimumOSVersions[key] ?? minimumOSVersions[fallbackKey]
    return platform.satisfies(minimum: minimumVersion)
  }
}

public struct CoreAIModelDescriptor: Hashable, Sendable {
  public let identifier: String
  public let kind: CoreAIModelKind
  public let variants: [CoreAIModelVariant]

  public init(
    identifier: String,
    kind: CoreAIModelKind,
    variants: [CoreAIModelVariant]
  ) {
    self.identifier = identifier
    self.kind = kind
    self.variants = variants
  }
}
