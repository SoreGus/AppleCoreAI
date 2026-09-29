import Foundation

public struct CoreAIModelStatus: Sendable {
  public let isDownloaded: Bool
  public let isPrepared: Bool
  public let downloadedURL: URL?
  public let preparedURL: URL?
  public let downloadedSize: Int64?
  public let preparedSize: Int64?
  public let specializationBookmark: Data?

  public init(
    isDownloaded: Bool,
    isPrepared: Bool,
    downloadedURL: URL?,
    preparedURL: URL?,
    downloadedSize: Int64?,
    preparedSize: Int64?,
    specializationBookmark: Data?
  ) {
    self.isDownloaded = isDownloaded
    self.isPrepared = isPrepared
    self.downloadedURL = downloadedURL
    self.preparedURL = preparedURL
    self.downloadedSize = downloadedSize
    self.preparedSize = preparedSize
    self.specializationBookmark = specializationBookmark
  }
}
