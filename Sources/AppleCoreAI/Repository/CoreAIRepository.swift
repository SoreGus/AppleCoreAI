import Foundation

public struct CoreAIRepository: Sendable {
  public let identifier: String
  public let revision: String
  public let manifest: CoreAIRepositoryManifest

  public init(
    identifier: String,
    revision: String = "main",
    manifest: CoreAIRepositoryManifest
  ) {
    self.identifier = identifier
    self.revision = revision
    self.manifest = manifest
  }

  public init(
    huggingFace identifier: String,
    revision: String = "main"
  ) async throws {
    let remote = HuggingFaceRepositoryClient()
    let manifest = try await remote.repositoryManifest(
      repository: identifier,
      revision: revision
    )
    self.init(
      identifier: identifier,
      revision: revision,
      manifest: manifest
    )
  }

  public var models: [CoreAIModelDescriptor] {
    let variants = manifest.artifacts.map {
      CoreAIModelVariant(
        repositoryIdentifier: identifier,
        revision: revision,
        entry: $0
      )
    }

    return Dictionary(grouping: variants, by: \.modelIdentifier)
      .map { identifier, variants in
        CoreAIModelDescriptor(
          identifier: identifier,
          kind: variants.first?.kind ?? .generic,
          variants: variants.sorted { $0.identifier < $1.identifier }
        )
      }
      .sorted { $0.identifier < $1.identifier }
  }

  public func variant(
    model: String,
    variant: String
  ) throws -> CoreAIModelVariant {
    guard let model = models.first(where: { $0.identifier == model }) else {
      throw AppleCoreAIError.modelNotFound(model)
    }

    guard let value = model.variants.first(where: { $0.identifier == variant }) else {
      throw AppleCoreAIError.variantNotFound(variant)
    }

    return value
  }

  public func bestVariant(
    model modelIdentifier: String? = nil,
    for platform: CoreAIPlatform = .currentDevice
  ) throws -> CoreAIModelVariant {
    let candidates: [CoreAIModelVariant]

    if let modelIdentifier {
      guard let model = models.first(where: { $0.identifier == modelIdentifier }) else {
        throw AppleCoreAIError.modelNotFound(modelIdentifier)
      }
      candidates = model.variants
    } else {
      guard models.count == 1 else {
        throw AppleCoreAIError.ambiguousModelSelection
      }
      candidates = models[0].variants
    }

    let compatible = candidates.filter { $0.isCompatible(with: platform) }
    guard !compatible.isEmpty else {
      throw AppleCoreAIError.incompatiblePlatform
    }

    return compatible.sorted { lhs, rhs in
      let lhsPrepared = lhs.preparedArtifact != nil
      let rhsPrepared = rhs.preparedArtifact != nil
      if lhsPrepared != rhsPrepared {
        return lhsPrepared && !rhsPrepared
      }

      let lhsExact = lhs.platforms.contains(platform)
      let rhsExact = rhs.platforms.contains(platform)
      if lhsExact != rhsExact {
        return lhsExact && !rhsExact
      }

      return lhs.identifier < rhs.identifier
    }.first!
  }
}
