import Foundation

public enum CoreAIModelKind: Hashable, Sendable {
  case generic
  case languageModel
  case vision
  case audio
  case other(String)

  public var rawValue: String {
    switch self {
    case .generic: "generic"
    case .languageModel: "languageModel"
    case .vision: "vision"
    case .audio: "audio"
    case .other(let value): value
    }
  }
}

extension CoreAIModelKind: Codable {
  public init(from decoder: Decoder) throws {
    let value = try decoder.singleValueContainer().decode(String.self)
    switch value {
    case "generic": self = .generic
    case "languageModel", "language_model": self = .languageModel
    case "vision": self = .vision
    case "audio": self = .audio
    default: self = .other(value)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
}
