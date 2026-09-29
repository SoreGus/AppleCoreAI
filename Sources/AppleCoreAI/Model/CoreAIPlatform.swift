import Foundation

public enum CoreAIPlatform: String, Codable, CaseIterable, Hashable, Sendable {
  case iOS = "ios"
  case iPadOS = "ipados"
  case macOS = "macos"

  public static var currentDevice: CoreAIPlatform {
    #if os(macOS)
      .macOS
    #elseif os(iOS)
      .iOS
    #else
      .macOS
    #endif
  }

  public static var currentOSVersion: OperatingSystemVersion {
    ProcessInfo.processInfo.operatingSystemVersion
  }

  func satisfies(minimum version: String?) -> Bool {
    guard let version else {
      return true
    }

    let components =
      version
      .split(separator: ".")
      .compactMap { Int($0) }

    let required = OperatingSystemVersion(
      majorVersion: components.indices.contains(0) ? components[0] : 0,
      minorVersion: components.indices.contains(1) ? components[1] : 0,
      patchVersion: components.indices.contains(2) ? components[2] : 0
    )

    return Self.currentOSVersion >= required
  }
}

extension OperatingSystemVersion {
  fileprivate static func >= (
    lhs: OperatingSystemVersion,
    rhs: OperatingSystemVersion
  ) -> Bool {
    if lhs.majorVersion != rhs.majorVersion {
      return lhs.majorVersion > rhs.majorVersion
    }
    if lhs.minorVersion != rhs.minorVersion {
      return lhs.minorVersion > rhs.minorVersion
    }
    return lhs.patchVersion >= rhs.patchVersion
  }
}
