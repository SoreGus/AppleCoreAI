import Foundation

public struct CoreAIDownloadProgress: Sendable {
  public let completedBytes: Int64
  public let totalBytes: Int64

  public init(
    completedBytes: Int64,
    totalBytes: Int64
  ) {
    self.completedBytes = completedBytes
    self.totalBytes = totalBytes
  }

  public var fractionCompleted: Double {
    guard totalBytes > 0 else {
      return 0
    }
    return min(
      1,
      max(0, Double(completedBytes) / Double(totalBytes))
    )
  }
}
