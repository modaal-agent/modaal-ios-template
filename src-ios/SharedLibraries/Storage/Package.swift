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
    .package(url: "https://https://github.com/modaal-agent/RxSwift.git", branch: "6_10_0_swift59_fix"),
    .package(url: "https://github.com/uber/RIBs-iOS.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "Storage",
      dependencies: [
        .product(name: "FirAppConfigure", package: "FirAppConfigure"),
        .product(name: "RIBs", package: "RIBs-iOS"),
        .product(name: "RxSwift", package: "RxSwift"),
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
        .product(name: "RxBlocking", package: "RxSwift"),
        .product(name: "RxSwift", package: "RxSwift"),
        .product(name: "RxTest", package: "RxSwift"),
        .target(name: "Storage"),
      ],
      plugins: [
      ]
    )
  ]
)
