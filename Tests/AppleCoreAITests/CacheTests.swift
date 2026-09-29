import Foundation
import Testing

@testable import AppleCoreAI

@Test
func cacheIdentityIsDeterministic() async {
  let root = FileManager.default.temporaryDirectory
    .appendingPathComponent(UUID().uuidString, isDirectory: true)
  defer {
    try? FileManager.default.removeItem(at: root)
  }

  let cache = CoreAICache(rootURL: root)
  let variant = makeVariant()

  let first = await cache.sourceRoot(for: variant)
  let second = await cache.sourceRoot(for: variant)

  #expect(first == second)
  #expect(first.path.contains("SoreGus_LVChordia-CoreAI"))
  #expect(first.path.contains("LVChordia"))
}

private func makeVariant() -> CoreAIModelVariant {
  let entry = CoreAIRepositoryArtifactEntry(
    artifactName: "LVChordia",
    manifestPath: "manifest.json",
    variant: "universal",
    modelKind: .generic,
    platforms: [.iOS, .macOS],
    minimumOSVersions: [:],
    sourceRepository: nil,
    sourceRevision: nil,
    artifact: nil,
    preparedArtifact: nil
  )

  return CoreAIModelVariant(
    repositoryIdentifier: "SoreGus/LVChordia-CoreAI",
    revision: "main",
    entry: entry
  )
}
