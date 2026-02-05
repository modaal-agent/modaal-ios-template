// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "SharedUtility",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(name: "SharedUtility", targets: ["SharedUtility"])
  ],
  dependencies: [
    .package(url: "https://github.com/liamnichols/xcstrings-tool-plugin.git", from: "1.2.0"),
    .package(url: "https://github.com/Quick/Nimble.git", from: "14.0.0"),
    .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
    .package(url: "https://github.com/SwiftGen/SwiftGenPlugin.git", from: "6.6.2"),
    .package(url: "https://github.com/modaal-agent/CombineRIBs.git", from: "2.1.0"),
  ],
  targets: [
    .target(
      name: "SharedUtility",
      dependencies: [
        .product(name: "CombineRIBs", package: "CombineRIBs"),
      ],
      resources: [
      ],
      plugins: [
        .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin"),
        .plugin(name: "XCStringsToolPlugin", package: "xcstrings-tool-plugin"),
      ]
    ),
    .testTarget(
      name: "SharedUtilityTests",
      dependencies: [
        .product(name: "Nimble", package: "Nimble"),
        .product(name: "Quick", package: "Quick"),
        .target(name: "SharedUtility"),
      ],
      plugins: [
      ]
    )
  ]
)
