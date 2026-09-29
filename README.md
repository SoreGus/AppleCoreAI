# AppleCoreAI

Swift tooling for discovering, downloading, validating, preparing, caching, and managing Apple Core AI model artifacts.

`AppleCoreAI` does not replace Apple's `CoreAI` framework. It manages model distribution and lifecycle and hands the resulting artifact or specialization bookmark to the official Apple runtime.

## Requirements

- Swift 6.2+
- Xcode 27+
- iOS 17+
- macOS 14+

Core AI specialization and runtime-specific operations require iOS 27+ or macOS 27+. Repository discovery, manifests, Hugging Face downloads, integrity validation, and cache management remain available on the package baseline.
- Metal Toolchain when running Core AI models

## Installation

Add `AppleCoreAI` as a Swift Package dependency and import:

```swift
import AppleCoreAI
```

The package uses the official Hugging Face Swift client for Hub access.

## Repository Contract

`AppleCoreAI` consumes the files published by `AppleCoreAIPython`:

```text
coreai-repository.json
└── artifact entry
    └── manifest_path
        └── manifest.json
            ├── .aimodel artifact
            └── optional prepared artifact
```

The repository catalog is used for discovery and the artifact manifest is used for detailed artifact metadata and validation.

## Discover a Repository

```swift
let repository = try await CoreAIRepository(
    huggingFace: "SoreGus/LVChordia-CoreAI"
)
```

For a repository containing one model:

```swift
let variant = try repository.bestVariant(
    for: .currentDevice
)
```

For repositories containing multiple models:

```swift
let variant = try repository.bestVariant(
    model: "LVChordia",
    for: .currentDevice
)
```

Explicit selection is also available:

```swift
let variant = try repository.variant(
    model: "LVChordia",
    variant: "five-model-ensemble-probability-fusion"
)
```

## Download

```swift
let manager = CoreAIModelManager()

let artifact = try await manager.download(
    variant,
    progress: { progress in
        print(progress.fractionCompleted)
    }
)
```

Downloads are cached and validated using the file sizes and SHA-256 values published by `AppleCoreAIPython`.

## Preparation

`prepareIfNeeded` prefers a prepared artifact published by the repository. If none is available, it downloads the source `.aimodel` and specializes it locally with Apple Core AI.

```swift
let prepared = try await manager.prepareIfNeeded(
    variant,
    retentionPolicy: .keepSource
)
```

Local specialization is represented by `AIModel.bookmarkData`, because Core AI owns the specialized cache entry. A remotely published prepared artifact is represented by its downloaded URL.

```swift
switch prepared.storage {
case .downloaded(let url):
    let model = try await AIModel(contentsOf: url)

case .specializationBookmark(let bookmark):
    let model = try AIModel(resolvingBookmark: bookmark)
}
```

Use `.deleteSourceAfterPreparation` when storage matters. Local specialization uses a persistent Core AI cache entry so it can be restored from the saved bookmark after the source artifact is removed.

## Status

```swift
let status = try await manager.status(
    for: variant
)

print(status.isDownloaded)
print(status.isPrepared)
```

Status is derived from the repository metadata and the package-owned cache. Applications do not need SwiftData, UserDefaults, or a separate model database for artifact lifecycle state.

## Deletion

```swift
try await manager.deleteDownloaded(
    for: variant
)

try await manager.deletePrepared(
    for: variant
)

try await manager.deleteAll(
    for: variant
)
```

Downloaded source artifacts and prepared state are managed independently.

## Cache

By default, artifacts are stored below the application's caches directory under `AppleCoreAI`.

A custom cache can be supplied:

```swift
let cache = CoreAICache(
    rootURL: customCacheURL
)

let manager = CoreAIModelManager(
    cache: cache
)
```

Cache identity is deterministic from:

- Hugging Face repository identifier;
- repository revision;
- model identifier;
- variant identifier.

## Authentication

Hugging Face authentication is handled by `swift-huggingface`. Its default `HubClient` supports the standard Hugging Face token locations and environment variables.

## Scope

`AppleCoreAI` contains no UI and no model-specific preprocessing or inference logic.

It is responsible for:

- repository discovery;
- repository and artifact manifests;
- model and variant selection;
- platform and minimum OS compatibility;
- downloads and progress;
- SHA-256 integrity validation;
- cache management;
- prepared artifact discovery;
- local Core AI specialization;
- retention policy;
- status, deletion, cleanup, and offline cache reuse.

Apple `CoreAI` remains responsible for model loading and inference.

## Development

Run tests with:

```bash
swift test
```

Core AI specialization requires Apple SDKs and therefore must be exercised on macOS/iOS 27 with Xcode 27 or newer.

## References

- Apple Core AI documentation
- Apple `coreai-models`
- Hugging Face `swift-huggingface`
- `AppleCoreAIPython` manifest v2 and repository catalog contract
