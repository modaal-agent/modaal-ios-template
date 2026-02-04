// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "Theming",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(name: "Theming", targets: ["Theming"])
  ],
  dependencies: [
    .package(name: "SimpleTheming", path: "../../SharedLibraries/SimpleTheming"),

    .package(url: "https://github.com/Quick/Nimble.git", from: "14.0.0"),
    .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
  ],
  targets: [
    .target(
      name: "Theming",
      dependencies: [
        .product(name: "SimpleTheming", package: "SimpleTheming"),
      ],
      resources: [
        .process("Fonts"),
      ]
    ),
    .testTarget(
      name: "ThemingTests",
      dependencies: [
        .product(name: "Nimble", package: "Nimble"),
        .product(name: "Quick", package: "Quick"),
        .target(name: "Theming"),
      ]
    )
  ]
)
