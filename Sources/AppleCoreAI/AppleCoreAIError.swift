import Foundation

public enum AppleCoreAIError: Error, Sendable {
  case repositoryUnavailable(String)
  case manifestInvalid(String)
  case modelNotFound(String)
  case variantNotFound(String)
  case ambiguousModelSelection
  case incompatiblePlatform
  case downloadFailed(String)
  case checksumMismatch(path: String)
  case preparationFailed(String)
  case artifactNotFound(String)
  case unsupportedPlatform
}
