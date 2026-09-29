# AppleCoreAI Design Notes

## Decisions

- `AppleCoreAI` is a Swift Package.
- It contains no UI.
- It does not replace Apple's `CoreAI` framework.
- It manages repository discovery, artifacts, variants, download, preparation, cache, and deletion.
- Hugging Face is the initial remote repository provider.
- The application should normally need only the Hugging Face repository identifier.
- `AppleCoreAIPython` owns export and publishing.
- `AppleCoreAIPython` manifest v2 is the artifact transport contract consumed by Swift.
- `coreai-repository.json` is the repository-level discovery catalog.
- `coreai-models` is not a mandatory base dependency.
- Runtime inference remains based on Apple `CoreAI` types.
- Model-specific preprocessing and inference helpers remain outside the base package.

## Manifest Contract

The Swift package consumes the current `AppleCoreAIPython` schema directly:

- repository catalog version 1 with flat artifact entries;
- artifact manifest version 2;
- lowercase platform identifiers (`ios`, `ipados`, `macos`);
- explicit minimum OS versions;
- source revision and optional source reference;
- source and optional prepared artifact descriptors;
- per-file sizes and SHA-256 hashes;
- aggregate package size and SHA-256.

The public Swift model API groups flat repository entries into models and variants without changing the transport schema.

## Preparation

Two prepared states are supported:

1. a prepared artifact published remotely and downloaded as a file or directory;
2. local Core AI specialization stored in `AIModelCache` and referenced by `AIModel.bookmarkData`.

A local specialization is not modeled as a synthetic filesystem URL. The bookmark is persisted by `AppleCoreAI` and can survive source deletion when Core AI uses a persistent cache policy.

## Cache Identity

Cache paths are deterministic from repository identifier, repository revision, model identifier, and variant identifier.

Downloaded source artifacts and prepared state are independent. Deleting one does not implicitly delete the other.

## Boundaries

```text
AppleCoreAIPython
        ↓
Hugging Face repository
        ↓
AppleCoreAI
        ↓
CoreAI
```

`AppleCoreAI` owns distribution and lifecycle. `CoreAI` owns specialization, runtime model loading, and inference.
