import Foundation
import HuggingFace

public actor HuggingFaceRepositoryClient: CoreAIRepositoryRemote {
  private let client: HubClient
  private let fileManager: FileManager

  public init(
    client: HubClient = .default,
    fileManager: FileManager = .default
  ) {
    self.client = client
    self.fileManager = fileManager
  }

  public func repositoryManifest(
    repository: String,
    revision: String
  ) async throws -> CoreAIRepositoryManifest {
    try await decodeRemoteJSON(
      repository: repository,
      revision: revision,
      path: "coreai-repository.json",
      as: CoreAIRepositoryManifest.self
    )
  }

  public func artifactManifest(
    for variant: CoreAIModelVariant
  ) async throws -> CoreAIArtifactManifest {
    try await decodeRemoteJSON(
      repository: variant.repositoryIdentifier,
      revision: variant.revision,
      path: variant.manifestPath,
      as: CoreAIArtifactManifest.self
    )
  }

  public func download(
    descriptor: CoreAIArtifactDescriptor,
    for variant: CoreAIModelVariant,
    to destinationRoot: URL,
    progress: @escaping @Sendable (CoreAIDownloadProgress) -> Void
  ) async throws {
    let temporary = fileManager.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)

    try fileManager.createDirectory(
      at: temporary,
      withIntermediateDirectories: true
    )
    defer {
      try? fileManager.removeItem(at: temporary)
    }

    let prefix = Self.parentPath(of: variant.manifestPath)
    let remotePaths =
      descriptor.files.isEmpty
      ? [Self.join(prefix, descriptor.path)]
      : descriptor.files.map { Self.join(prefix, $0.path) }

    do {
      let snapshot = try await client.downloadSnapshot(
        of: variant.repositoryIdentifier,
        kind: .model,
        to: temporary,
        revision: variant.revision,
        matching: remotePaths,
        progressHandler: { hubProgress in
          let total = descriptor.size
          let completed = Int64(
            Double(total) * hubProgress.fractionCompleted
          )
          progress(
            CoreAIDownloadProgress(
              completedBytes: completed,
              totalBytes: total
            )
          )
        }
      )

      let remoteRoot =
        prefix.isEmpty
        ? snapshot
        : snapshot.appendingPathComponent(prefix, isDirectory: true)

      try fileManager.createDirectory(
        at: destinationRoot,
        withIntermediateDirectories: true
      )

      for file in descriptor.files {
        let source = remoteRoot.appendingPathComponent(file.path)
        let destination = destinationRoot.appendingPathComponent(file.path)
        try fileManager.createDirectory(
          at: destination.deletingLastPathComponent(),
          withIntermediateDirectories: true
        )
        try Self.replaceItem(
          at: destination,
          with: source,
          fileManager: fileManager
        )
      }

      if descriptor.files.isEmpty {
        let source = remoteRoot.appendingPathComponent(descriptor.path)
        let destination = destinationRoot.appendingPathComponent(descriptor.path)
        try fileManager.createDirectory(
          at: destination.deletingLastPathComponent(),
          withIntermediateDirectories: true
        )
        try Self.replaceItem(
          at: destination,
          with: source,
          fileManager: fileManager
        )
      }

      progress(
        CoreAIDownloadProgress(
          completedBytes: descriptor.size,
          totalBytes: descriptor.size
        )
      )
    } catch {
      throw AppleCoreAIError.downloadFailed(error.localizedDescription)
    }
  }

  private func decodeRemoteJSON<Value: Decodable>(
    repository: String,
    revision: String,
    path: String,
    as type: Value.Type
  ) async throws -> Value {
    let temporary = fileManager.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)

    try fileManager.createDirectory(
      at: temporary,
      withIntermediateDirectories: true
    )
    defer {
      try? fileManager.removeItem(at: temporary)
    }

    do {
      let snapshot = try await client.downloadSnapshot(
        of: repository,
        kind: .model,
        to: temporary,
        revision: revision,
        matching: [path],
        progressHandler: { _ in }
      )

      let url = snapshot.appendingPathComponent(path)
      let data = try Data(contentsOf: url)
      return try JSONDecoder().decode(Value.self, from: data)
    } catch let error as DecodingError {
      throw AppleCoreAIError.manifestInvalid(String(describing: error))
    } catch {
      throw AppleCoreAIError.repositoryUnavailable(error.localizedDescription)
    }
  }

  private static func parentPath(of path: String) -> String {
    let value = (path as NSString).deletingLastPathComponent
    return value == "." ? "" : value
  }

  private static func join(_ lhs: String, _ rhs: String) -> String {
    guard !lhs.isEmpty else {
      return rhs
    }
    return lhs + "/" + rhs
  }

  private static func replaceItem(
    at destination: URL,
    with source: URL,
    fileManager: FileManager
  ) throws {
    if fileManager.fileExists(atPath: destination.path) {
      try fileManager.removeItem(at: destination)
    }
    try fileManager.copyItem(at: source, to: destination)
  }
}
