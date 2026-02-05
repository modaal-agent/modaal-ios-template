// swift-tools-version:5.9

// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import PackageDescription

let package = Package(
  name: "CloudStorage",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(name: "CloudStorage", targets: ["CloudStorage"])
  ],
  dependencies: [
    .package(name: "FirAppConfigure", path: "../FirAppConfigure"),

    .package(url: "https://github.com/Quick/Nimble.git", from: "14.0.0"),
    .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
    .package(url: "https://github.com/modaal-agent/CombineRIBs.git", from: "2.1.0"),
  ],
  targets: [
    .target(
      name: "CloudStorage",
      dependencies: [
        .product(name: "CombineRIBs", package: "CombineRIBs"),
        .product(name: "FirAppConfigure", package: "FirAppConfigure"),
      ],
      plugins: [
      ]
    ),
    .testTarget(
      name: "CloudStorageTests",
      dependencies: [
        .product(name: "Nimble", package: "Nimble"),
        .product(name: "Quick", package: "Quick"),
        .target(name: "CloudStorage"),
      ],
      plugins: [
      ]
    )
  ]
)
