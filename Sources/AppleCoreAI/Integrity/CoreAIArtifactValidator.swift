import Foundation

enum CoreAIArtifactValidator {
  static func validate(
    _ descriptor: CoreAIArtifactDescriptor,
    rootURL: URL,
    fileManager: FileManager = .default
  ) throws {
    for file in descriptor.files {
      let url = rootURL.appendingPathComponent(file.path)
      guard fileManager.fileExists(atPath: url.path) else {
        throw AppleCoreAIError.artifactNotFound(file.path)
      }

      let attributes = try fileManager.attributesOfItem(atPath: url.path)
      let size = (attributes[.size] as? NSNumber)?.int64Value ?? -1
      guard size == file.size else {
        throw AppleCoreAIError.checksumMismatch(path: file.path)
      }

      let digest = try SHA256.hexDigest(fileAt: url)
      guard digest.caseInsensitiveCompare(file.sha256) == .orderedSame else {
        throw AppleCoreAIError.checksumMismatch(path: file.path)
      }
    }

    guard descriptor.files.reduce(Int64(0), { $0 + $1.size }) == descriptor.size else {
      throw AppleCoreAIError.checksumMismatch(path: descriptor.path)
    }

    let aggregate = aggregateSHA256(descriptor.files)
    guard aggregate.caseInsensitiveCompare(descriptor.sha256) == .orderedSame else {
      throw AppleCoreAIError.checksumMismatch(path: descriptor.path)
    }
  }

  private static func aggregateSHA256(
    _ files: [CoreAIArtifactFile]
  ) -> String {
    var data = Data()

    for file in files.sorted(by: { $0.path < $1.path }) {
      data.append(Data(file.path.utf8))
      data.append(0)
      data.append(Data(String(file.size).utf8))
      data.append(0)
      data.append(Data(file.sha256.utf8))
      data.append(0x0a)
    }

    return SHA256.hexDigest(data: data)
  }
}
