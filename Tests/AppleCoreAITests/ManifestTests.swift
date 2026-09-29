import Foundation
import Testing

@testable import AppleCoreAI

@Test
func repositoryManifestDecodesAppleCoreAIPythonCatalog() throws {
  let data = Data(
    """
    {
      "version": 1,
      "updated_at": "2026-09-29T19:55:36+00:00",
      "artifacts": [
        {
          "artifact_name": "LVChordia",
          "manifest_path": "manifest.json",
          "variant": "five-model-ensemble-probability-fusion",
          "model_kind": "generic",
          "platforms": ["ios", "macos"],
          "minimum_os_versions": {
            "ios": "27.0",
            "macos": "27.0"
          },
          "source_repository": "https://example.com/research",
          "source_revision": "aa6841bacbfd740fae2b2aee860ddc85e5339ff4",
          "artifact": {
            "path": "LVChordia.aimodel",
            "size": 32,
            "sha256": "abc",
            "prepared": false,
            "files": []
          },
          "prepared_artifact": null
        }
      ]
    }
    """.utf8
  )

  let manifest = try JSONDecoder().decode(
    CoreAIRepositoryManifest.self,
    from: data
  )

  #expect(manifest.version == 1)
  #expect(manifest.artifacts.count == 1)
  #expect(manifest.artifacts[0].artifactName == "LVChordia")
  #expect(manifest.artifacts[0].platforms == [.iOS, .macOS])
  #expect(manifest.artifacts[0].sourceRevision == "aa6841bacbfd740fae2b2aee860ddc85e5339ff4")
}

@Test
func artifactManifestDecodesVersionTwo() throws {
  let data = Data(
    """
    {
      "version": 2,
      "created_at": "2026-09-29T19:55:36+00:00",
      "artifact_name": "LVChordia",
      "source_model": "LV-Chordia",
      "source_repository": "https://example.com/research",
      "source_revision": "aa6841bacbfd740fae2b2aee860ddc85e5339ff4",
      "source_reference": "master",
      "variant": "five-model-ensemble-probability-fusion",
      "model_kind": "generic",
      "platforms": ["ios", "macos"],
      "minimum_os_versions": {
        "ios": "27.0",
        "macos": "27.0"
      },
      "coreai_tooling_version": "0.4.3",
      "torch_version": "2.14.0",
      "inputs": [],
      "outputs": [],
      "artifact": {
        "path": "LVChordia.aimodel",
        "size": 32,
        "sha256": "abc",
        "prepared": false,
        "files": []
      },
      "prepared_artifact": null,
      "files": [],
      "metadata": {}
    }
    """.utf8
  )

  let manifest = try JSONDecoder().decode(
    CoreAIArtifactManifest.self,
    from: data
  )

  #expect(manifest.version == 2)
  #expect(manifest.sourceReference == "master")
  #expect(manifest.coreAIToolingVersion == "0.4.3")
  #expect(manifest.artifact?.path == "LVChordia.aimodel")
}
