// swift-tools-version:5.9
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
    .package(url: "https://https://github.com/modaal-agent/RxSwift.git", branch: "6_10_0_swift59_fix"),
  ],
  targets: [
    .target(
      name: "RxExtensions",
      dependencies: [
        .product(name: "RxCocoa", package: "RxSwift"),
        .product(name: "RxSwift", package: "RxSwift"),
      ],
      plugins: [
      ]
    ),
    .testTarget(
      name: "RxExtensionsTests",
      dependencies: [
        .product(name: "Nimble", package: "Nimble"),
        .product(name: "Quick", package: "Quick"),
        .product(name: "RxBlocking", package: "RxSwift"),
        .product(name: "RxCocoa", package: "RxSwift"),
        .product(name: "RxSwift", package: "RxSwift"),
        .product(name: "RxTest", package: "RxSwift"),
        .target(name: "RxExtensions"),
      ],
      plugins: [
      ]
    )
  ]
)
