import Foundation

public struct CoreAIArtifactFile: Codable, Hashable, Sendable {
  public let path: String
  public let size: Int64
  public let sha256: String
  public let kind: String?

  public init(
    path: String,
    size: Int64,
    sha256: String,
    kind: String? = nil
  ) {
    self.path = path
    self.size = size
    self.sha256 = sha256
    self.kind = kind
  }
}

public struct CoreAIArtifactDescriptor: Codable, Hashable, Sendable {
  public let path: String
  public let size: Int64
  public let sha256: String
  public let prepared: Bool
  public let files: [CoreAIArtifactFile]

  public init(
    path: String,
    size: Int64,
    sha256: String,
    prepared: Bool = false,
    files: [CoreAIArtifactFile] = []
  ) {
    self.path = path
    self.size = size
    self.sha256 = sha256
    self.prepared = prepared
    self.files = files
  }
}
