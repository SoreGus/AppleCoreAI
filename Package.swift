// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "AppleCoreAI",
  platforms: [
    .iOS("27.0"),
    .macOS("27.0"),
  ],
  products: [
    .library(
      name: "AppleCoreAI",
      targets: ["AppleCoreAI"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/huggingface/swift-huggingface.git",
      from: "0.9.0"
    )
  ],
  targets: [
    .target(
      name: "AppleCoreAI",
      dependencies: [
        .product(
          name: "HuggingFace",
          package: "swift-huggingface"
        )
      ]
    ),
    .testTarget(
      name: "AppleCoreAITests",
      dependencies: ["AppleCoreAI"]
    ),
  ]
)
