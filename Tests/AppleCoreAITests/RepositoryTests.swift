import Foundation
import Testing

@testable import AppleCoreAI

@Test
func repositoryGroupsVariantsByModel() throws {
  let repository = makeRepository(
    entries: [
      makeEntry(variant: "ios", platforms: [.iOS]),
      makeEntry(variant: "macos", platforms: [.macOS]),
    ]
  )

  #expect(repository.models.count == 1)
  #expect(repository.models[0].identifier == "LVChordia")
  #expect(repository.models[0].variants.count == 2)
}

@Test
func explicitVariantSelectionWorks() throws {
  let repository = makeRepository(
    entries: [
      makeEntry(variant: "universal", platforms: [.iOS, .macOS])
    ]
  )

  let variant = try repository.variant(
    model: "LVChordia",
    variant: "universal"
  )

  #expect(variant.identifier == "universal")
  #expect(variant.modelIdentifier == "LVChordia")
}

@Test
func bestVariantPrefersPreparedArtifact() throws {
  let source = makeEntry(
    variant: "source",
    platforms: [.macOS]
  )
  let prepared = makeEntry(
    variant: "prepared",
    platforms: [.macOS],
    prepared: true
  )

  let repository = makeRepository(entries: [source, prepared])
  let variant = try repository.bestVariant(
    model: "LVChordia",
    for: .macOS
  )

  #expect(variant.identifier == "prepared")
}

private func makeRepository(
  entries: [CoreAIRepositoryArtifactEntry]
) -> CoreAIRepository {
  CoreAIRepository(
    identifier: "SoreGus/LVChordia-CoreAI",
    revision: "main",
    manifest: CoreAIRepositoryManifest(
      version: 1,
      updatedAt: "",
      artifacts: entries
    )
  )
}

private func makeEntry(
  variant: String,
  platforms: [CoreAIPlatform],
  prepared: Bool = false
) -> CoreAIRepositoryArtifactEntry {
  let artifact = CoreAIArtifactDescriptor(
    path: "LVChordia.aimodel",
    size: 0,
    sha256: SHA256.hexDigest(data: Data()),
    files: []
  )

  let preparedArtifact =
    prepared
    ? CoreAIArtifactDescriptor(
      path: "LVChordia.arm64.aimodelc",
      size: 0,
      sha256: SHA256.hexDigest(data: Data()),
      prepared: true,
      files: []
    )
    : nil

  return CoreAIRepositoryArtifactEntry(
    artifactName: "LVChordia",
    manifestPath: "manifest.json",
    variant: variant,
    modelKind: .generic,
    platforms: platforms,
    minimumOSVersions: [:],
    sourceRepository: nil,
    sourceRevision: nil,
    artifact: artifact,
    preparedArtifact: preparedArtifact
  )
}
