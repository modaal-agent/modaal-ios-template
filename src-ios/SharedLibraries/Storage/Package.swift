// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "Storage",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(name: "Storage", targets: ["Storage"])
  ],
  dependencies: [
    .package(name: "FirAppConfigure", path: "../FirAppConfigure"),
    .package(name: "StringCodable", path: "../StringCodable"),

    .package(url: "https://github.com/Quick/Nimble.git", from: "14.0.0"),
    .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
    .package(url: "https://github.com/modaal-agent/CombineRIBs.git", branch: "main"),
  ],
  targets: [
    .target(
      name: "Storage",
      dependencies: [
        .product(name: "FirAppConfigure", package: "FirAppConfigure"),
        .product(name: "CombineRIBs", package: "CombineRIBs"),
        .product(name: "StringCodable", package: "StringCodable"),
      ],
      resources: [
      ],
      plugins: [
      ]
    ),
    .testTarget(
      name: "StorageTests",
      dependencies: [
        .product(name: "Nimble", package: "Nimble"),
        .product(name: "Quick", package: "Quick"),
        .target(name: "Storage"),
      ],
      plugins: [
      ]
    )
  ]
)
