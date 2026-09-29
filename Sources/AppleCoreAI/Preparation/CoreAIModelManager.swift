import Foundation

public actor CoreAIModelManager {
  private let remote: any CoreAIRepositoryRemote
  private let cache: CoreAICache
  private let preparer: CoreAIPreparer
  private let fileManager: FileManager

  public init(
    remote: any CoreAIRepositoryRemote = HuggingFaceRepositoryClient(),
    cache: CoreAICache = CoreAICache(),
    preparer: CoreAIPreparer = CoreAIPreparer(),
    fileManager: FileManager = .default
  ) {
    self.remote = remote
    self.cache = cache
    self.preparer = preparer
    self.fileManager = fileManager
  }

  public func status(
    for variant: CoreAIModelVariant
  ) async throws -> CoreAIModelStatus {
    let sourceRoot = await cache.sourceRoot(for: variant)
    let preparedRoot = await cache.preparedRoot(for: variant)
    let bookmark = try await cache.bookmark(for: variant)

    let downloadedURL = variant.artifact.map {
      sourceRoot.appendingPathComponent($0.path)
    }
    let preparedURL = variant.preparedArtifact.map {
      preparedRoot.appendingPathComponent($0.path)
    }

    let isDownloaded =
      downloadedURL.map {
        fileManager.fileExists(atPath: $0.path)
      } ?? false

    let hasPreparedDownload =
      preparedURL.map {
        fileManager.fileExists(atPath: $0.path)
      } ?? false

    return CoreAIModelStatus(
      isDownloaded: isDownloaded,
      isPrepared: hasPreparedDownload || bookmark != nil,
      downloadedURL: isDownloaded ? downloadedURL : nil,
      preparedURL: hasPreparedDownload ? preparedURL : nil,
      downloadedSize: isDownloaded ? variant.artifact?.size : nil,
      preparedSize: hasPreparedDownload ? variant.preparedArtifact?.size : nil,
      specializationBookmark: bookmark
    )
  }

  public func download(
    _ variant: CoreAIModelVariant,
    progress: @escaping @Sendable (CoreAIDownloadProgress) -> Void = { _ in }
  ) async throws -> CoreAIArtifact {
    guard let descriptor = variant.artifact else {
      throw AppleCoreAIError.artifactNotFound(variant.identifier)
    }

    let root = await cache.sourceRoot(for: variant)
    let existing = CoreAIArtifact(
      repositoryIdentifier: variant.repositoryIdentifier,
      revision: variant.revision,
      modelIdentifier: variant.modelIdentifier,
      variantIdentifier: variant.identifier,
      descriptor: descriptor,
      rootURL: root
    )

    if fileManager.fileExists(atPath: existing.url.path) {
      do {
        try CoreAIArtifactValidator.validate(descriptor, rootURL: root)
        progress(
          CoreAIDownloadProgress(
            completedBytes: descriptor.size,
            totalBytes: descriptor.size
          )
        )
        return existing
      } catch {
        try? await cache.removeSource(for: variant)
      }
    }

    let manifest = try await remote.artifactManifest(for: variant)
    guard manifest.version >= 2 else {
      throw AppleCoreAIError.manifestInvalid(
        "Artifact manifest v2 or newer is required."
      )
    }

    try await remote.download(
      descriptor: descriptor,
      for: variant,
      to: root,
      progress: progress
    )

    try CoreAIArtifactValidator.validate(descriptor, rootURL: root)
    return existing
  }

  public func downloadPrepared(
    _ variant: CoreAIModelVariant,
    progress: @escaping @Sendable (CoreAIDownloadProgress) -> Void = { _ in }
  ) async throws -> PreparedCoreAIArtifact {
    guard let descriptor = variant.preparedArtifact else {
      throw AppleCoreAIError.artifactNotFound(
        "No prepared artifact is published for \(variant.identifier)."
      )
    }

    let root = await cache.preparedRoot(for: variant)
    let url = root.appendingPathComponent(descriptor.path)

    if !fileManager.fileExists(atPath: url.path) {
      try await remote.download(
        descriptor: descriptor,
        for: variant,
        to: root,
        progress: progress
      )
    }

    try CoreAIArtifactValidator.validate(descriptor, rootURL: root)

    return PreparedCoreAIArtifact(
      repositoryIdentifier: variant.repositoryIdentifier,
      revision: variant.revision,
      modelIdentifier: variant.modelIdentifier,
      variantIdentifier: variant.identifier,
      descriptor: descriptor,
      storage: .downloaded(url)
    )
  }

  public func prepare(
    _ artifact: CoreAIArtifact,
    for variant: CoreAIModelVariant,
    retentionPolicy: CoreAIPreparationRetentionPolicy = .keepSource
  ) async throws -> PreparedCoreAIArtifact {
    let bookmark = try await preparer.specialize(artifact)
    try await cache.storeBookmark(bookmark, for: variant)

    if retentionPolicy == .deleteSourceAfterPreparation {
      try await cache.removeSource(for: variant)
    }

    return PreparedCoreAIArtifact(
      repositoryIdentifier: variant.repositoryIdentifier,
      revision: variant.revision,
      modelIdentifier: variant.modelIdentifier,
      variantIdentifier: variant.identifier,
      descriptor: nil,
      storage: .specializationBookmark(bookmark)
    )
  }

  public func prepareIfNeeded(
    _ variant: CoreAIModelVariant,
    retentionPolicy: CoreAIPreparationRetentionPolicy = .keepSource,
    progress: @escaping @Sendable (CoreAIDownloadProgress) -> Void = { _ in }
  ) async throws -> PreparedCoreAIArtifact {
    if let bookmark = try await cache.bookmark(for: variant) {
      return PreparedCoreAIArtifact(
        repositoryIdentifier: variant.repositoryIdentifier,
        revision: variant.revision,
        modelIdentifier: variant.modelIdentifier,
        variantIdentifier: variant.identifier,
        descriptor: nil,
        storage: .specializationBookmark(bookmark)
      )
    }

    if variant.preparedArtifact != nil {
      return try await downloadPrepared(
        variant,
        progress: progress
      )
    }

    let artifact = try await download(
      variant,
      progress: progress
    )

    return try await prepare(
      artifact,
      for: variant,
      retentionPolicy: retentionPolicy
    )
  }

  public func deleteDownloaded(
    for variant: CoreAIModelVariant
  ) async throws {
    try await cache.removeSource(for: variant)
  }

  public func deletePrepared(
    for variant: CoreAIModelVariant
  ) async throws {
    if let bookmark = try await cache.bookmark(for: variant) {
      try await preparer.deleteSpecialization(referencedBy: bookmark)
    }
    try await cache.removePrepared(for: variant)
  }

  public func deleteAll(
    for variant: CoreAIModelVariant
  ) async throws {
    if let bookmark = try await cache.bookmark(for: variant) {
      try await preparer.deleteSpecialization(referencedBy: bookmark)
    }
    try await cache.removeAll(for: variant)
  }

  public func cleanup() async throws {
    try await cache.cleanup()
  }
}
