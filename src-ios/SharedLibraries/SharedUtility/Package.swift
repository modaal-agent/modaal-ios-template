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
    .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.10.1"),
    .package(url: "https://github.com/SwiftGen/SwiftGenPlugin.git", from: "6.6.2"),
    .package(url: "https://github.com/uber/RIBs-iOS.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "SharedUtility",
      dependencies: [
        .product(name: "RxCocoa", package: "RxSwift"),
        .product(name: "RxSwift", package: "RxSwift"),
        .product(name: "RIBs", package: "RIBs-iOS"),
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
        .product(name: "RxBlocking", package: "RxSwift"),
        .product(name: "RxCocoa", package: "RxSwift"),
        .product(name: "RxSwift", package: "RxSwift"),
        .product(name: "RxTest", package: "RxSwift"),
        .target(name: "SharedUtility"),
      ],
      plugins: [
      ]
    )
  ]
)
