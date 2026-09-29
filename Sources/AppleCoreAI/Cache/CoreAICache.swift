import Foundation

public actor CoreAICache {
  public let rootURL: URL
  private let fileManager: FileManager

  public init(
    rootURL: URL? = nil,
    fileManager: FileManager = .default
  ) {
    self.fileManager = fileManager

    if let rootURL {
      self.rootURL = rootURL
    } else {
      let base =
        fileManager.urls(
          for: .cachesDirectory,
          in: .userDomainMask
        ).first ?? fileManager.temporaryDirectory
      self.rootURL = base.appendingPathComponent(
        "AppleCoreAI",
        isDirectory: true
      )
    }
  }

  public func sourceRoot(
    for variant: CoreAIModelVariant
  ) -> URL {
    variantRoot(for: variant)
      .appendingPathComponent("source", isDirectory: true)
  }

  public func preparedRoot(
    for variant: CoreAIModelVariant
  ) -> URL {
    variantRoot(for: variant)
      .appendingPathComponent("prepared", isDirectory: true)
  }

  public func bookmarkURL(
    for variant: CoreAIModelVariant
  ) -> URL {
    preparedRoot(for: variant)
      .appendingPathComponent("specialization.bookmark")
  }

  public func bookmark(
    for variant: CoreAIModelVariant
  ) throws -> Data? {
    let url = bookmarkURL(for: variant)
    guard fileManager.fileExists(atPath: url.path) else {
      return nil
    }
    return try Data(contentsOf: url)
  }

  public func storeBookmark(
    _ data: Data,
    for variant: CoreAIModelVariant
  ) throws {
    let url = bookmarkURL(for: variant)
    try fileManager.createDirectory(
      at: url.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )
    try data.write(to: url, options: .atomic)
  }

  public func removeSource(
    for variant: CoreAIModelVariant
  ) throws {
    try removeIfPresent(sourceRoot(for: variant))
  }

  public func removePrepared(
    for variant: CoreAIModelVariant
  ) throws {
    try removeIfPresent(preparedRoot(for: variant))
  }

  public func removeAll(
    for variant: CoreAIModelVariant
  ) throws {
    try removeIfPresent(variantRoot(for: variant))
  }

  public func cleanup() throws {
    guard fileManager.fileExists(atPath: rootURL.path) else {
      return
    }

    let children = try fileManager.contentsOfDirectory(
      at: rootURL,
      includingPropertiesForKeys: [.isDirectoryKey]
    )

    for child in children where child.lastPathComponent.hasPrefix(".tmp-") {
      try? fileManager.removeItem(at: child)
    }
  }

  private func variantRoot(
    for variant: CoreAIModelVariant
  ) -> URL {
    rootURL
      .appendingPathComponent(sanitize(variant.repositoryIdentifier), isDirectory: true)
      .appendingPathComponent(sanitize(variant.revision), isDirectory: true)
      .appendingPathComponent(sanitize(variant.modelIdentifier), isDirectory: true)
      .appendingPathComponent(sanitize(variant.identifier), isDirectory: true)
  }

  private func removeIfPresent(
    _ url: URL
  ) throws {
    guard fileManager.fileExists(atPath: url.path) else {
      return
    }
    try fileManager.removeItem(at: url)
  }

  private func sanitize(
    _ value: String
  ) -> String {
    let allowed = CharacterSet.alphanumerics.union(
      CharacterSet(charactersIn: "-._")
    )
    return value.unicodeScalars.map {
      allowed.contains($0) ? Character(String($0)) : "_"
    }.reduce(into: "") { $0.append($1) }
  }
}
