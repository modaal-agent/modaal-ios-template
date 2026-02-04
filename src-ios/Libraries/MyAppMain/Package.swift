// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "MyAppMain",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(name: "MyAppMain", targets: ["MyAppMain"])
  ],
  dependencies: [
    // App-specific libraries
    .package(name: "Theming", path: "../Theming"),

    // Shared libraries
    .package(name: "RxExtensions", path: "../../SharedLibraries/RxExtensions"),
    .package(name: "SharedUtility", path: "../../SharedLibraries/SharedUtility"),
    .package(name: "SimpleTheming", path: "../../SharedLibraries/SimpleTheming"),
    .package(name: "Storage", path: "../../SharedLibraries/Storage"),

    // 3-rd party dependencies
    .package(url: "https://github.com/liamnichols/xcstrings-tool-plugin.git", from: "1.2.0"),
    .package(url: "https://github.com/modaal-agent/RxSwift.git", branch: "6_10_0_swift59_fix"),
    .package(url: "https://github.com/SwiftGen/SwiftGenPlugin.git", from: "6.6.2"),
    .package(url: "https://github.com/uber/RIBs-iOS.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "MyAppMain",
      dependencies: [
        // App-specific libraries
        .product(name: "Theming", package: "Theming"),

        // Shared libraries
        .product(name: "RxExtensions", package: "RxExtensions"),
        .product(name: "SharedUtility", package: "SharedUtility"),
        .product(name: "SimpleTheming", package: "SimpleTheming"),
        .product(name: "Storage", package: "Storage"),

        // 3-rd party dependencies
        .product(name: "RIBs", package: "RIBs-iOS"),
        .product(name: "RxCocoa", package: "RxSwift"),
        .product(name: "RxSwift", package: "RxSwift"),
      ],
      resources: [
        .process("Assets/Media.xcassets"),
        .process("Localizable.xcstrings"),
      ],
      plugins: [
        .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin"),
        .plugin(name: "XCStringsToolPlugin", package: "xcstrings-tool-plugin"),
      ],
    ),
    .testTarget(
      name: "MyAppMainTests",
      dependencies: [
        .product(name: "RxCocoa", package: "RxSwift"),
        .product(name: "RxSwift", package: "RxSwift"),
        .target(name: "MyAppMain"),
      ],
      plugins: [
      ],
    )
  ]
)
