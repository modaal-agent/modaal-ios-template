// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "SimpleTheming",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(name: "SimpleTheming", targets: ["SimpleTheming"])
  ],
  dependencies: [
    .package(url: "https://github.com/Quick/Nimble.git", from: "14.0.0"),
    .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
  ],
  targets: [
    .target(
      name: "SimpleTheming",
      dependencies: [
      ]
    ),
    .testTarget(
      name: "SimpleThemingTests",
      dependencies: [
        .product(name: "Nimble", package: "Nimble"),
        .product(name: "Quick", package: "Quick"),
        .target(name: "SimpleTheming"),
      ]
    )
  ]
)
