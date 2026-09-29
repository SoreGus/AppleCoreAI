import Foundation

public struct CoreAIArtifact: Sendable {
  public let repositoryIdentifier: String
  public let revision: String
  public let modelIdentifier: String
  public let variantIdentifier: String
  public let descriptor: CoreAIArtifactDescriptor
  public let rootURL: URL

  public init(
    repositoryIdentifier: String,
    revision: String,
    modelIdentifier: String,
    variantIdentifier: String,
    descriptor: CoreAIArtifactDescriptor,
    rootURL: URL
  ) {
    self.repositoryIdentifier = repositoryIdentifier
    self.revision = revision
    self.modelIdentifier = modelIdentifier
    self.variantIdentifier = variantIdentifier
    self.descriptor = descriptor
    self.rootURL = rootURL
  }

  public var url: URL {
    rootURL.appendingPathComponent(descriptor.path)
  }
}

public enum PreparedCoreAIArtifactStorage: Sendable {
  case downloaded(URL)
  case specializationBookmark(Data)
}

public struct PreparedCoreAIArtifact: Sendable {
  public let repositoryIdentifier: String
  public let revision: String
  public let modelIdentifier: String
  public let variantIdentifier: String
  public let descriptor: CoreAIArtifactDescriptor?
  public let storage: PreparedCoreAIArtifactStorage

  public init(
    repositoryIdentifier: String,
    revision: String,
    modelIdentifier: String,
    variantIdentifier: String,
    descriptor: CoreAIArtifactDescriptor?,
    storage: PreparedCoreAIArtifactStorage
  ) {
    self.repositoryIdentifier = repositoryIdentifier
    self.revision = revision
    self.modelIdentifier = modelIdentifier
    self.variantIdentifier = variantIdentifier
    self.descriptor = descriptor
    self.storage = storage
  }

  public var url: URL? {
    if case .downloaded(let url) = storage {
      return url
    }
    return nil
  }

  public var bookmarkData: Data? {
    if case .specializationBookmark(let data) = storage {
      return data
    }
    return nil
  }
}
