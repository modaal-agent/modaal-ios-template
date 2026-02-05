// swift-tools-version:5.9

// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import PackageDescription

let package = Package(
  name: "RxExtensions",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    .library(name: "RxExtensions", targets: ["RxExtensions"])
  ],
  dependencies: [
    .package(url: "https://github.com/Quick/Nimble.git", from: "14.0.0"),
    .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
  ],
  targets: [
    .target(
      name: "RxExtensions",
      dependencies: [
      ],
      plugins: [
      ]
    ),
    .testTarget(
      name: "RxExtensionsTests",
      dependencies: [
        .product(name: "Nimble", package: "Nimble"),
        .product(name: "Quick", package: "Quick"),
        .target(name: "RxExtensions"),
      ],
      plugins: [
      ]
    )
  ]
)
