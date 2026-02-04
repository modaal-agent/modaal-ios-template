// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "StringCodable",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    .library(name: "StringCodable", targets: ["StringCodable"])
  ],
  dependencies: [
    .package(url: "https://github.com/Quick/Nimble.git", from: "14.0.0"),
    .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
  ],
  targets: [
    .target(
      name: "StringCodable",
      dependencies: [
      ]
    ),
    .testTarget(
      name: "StringCodableTests",
      dependencies: [
        .product(name: "Nimble", package: "Nimble"),
        .product(name: "Quick", package: "Quick"),
        .target(name: "StringCodable"),
      ]
    )
  ]
)
