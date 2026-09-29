import Foundation
import Testing

@testable import AppleCoreAI

@Test
func sha256MatchesKnownVector() {
  let digest = SHA256.hexDigest(
    data: Data("abc".utf8)
  )

  #expect(
    digest == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
  )
}

@Test
func artifactValidatorUsesPythonAggregateContract() throws {
  let root = FileManager.default.temporaryDirectory
    .appendingPathComponent(UUID().uuidString, isDirectory: true)
  defer {
    try? FileManager.default.removeItem(at: root)
  }

  let fileURL =
    root
    .appendingPathComponent("Model.aimodel", isDirectory: true)
    .appendingPathComponent("main.hash")

  try FileManager.default.createDirectory(
    at: fileURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
  )

  let contents = Data("hello".utf8)
  try contents.write(to: fileURL)

  let file = CoreAIArtifactFile(
    path: "Model.aimodel/main.hash",
    size: Int64(contents.count),
    sha256: SHA256.hexDigest(data: contents),
    kind: "aimodel"
  )

  var aggregateData = Data()
  aggregateData.append(Data(file.path.utf8))
  aggregateData.append(0)
  aggregateData.append(Data(String(file.size).utf8))
  aggregateData.append(0)
  aggregateData.append(Data(file.sha256.utf8))
  aggregateData.append(0x0a)

  let descriptor = CoreAIArtifactDescriptor(
    path: "Model.aimodel",
    size: file.size,
    sha256: SHA256.hexDigest(data: aggregateData),
    files: [file]
  )

  try CoreAIArtifactValidator.validate(
    descriptor,
    rootURL: root
  )
}
