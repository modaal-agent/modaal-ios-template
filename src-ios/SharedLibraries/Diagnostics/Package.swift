// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "Diagnostics",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    .library(name: "Diagnostics", targets: ["Diagnostics"])
  ],
  dependencies: [
    .package(url: "https://github.com/Quick/Nimble.git", from: "14.0.0"),
    .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
    .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.10.1"),
    .package(url: "https://github.com/uber/RIBs-iOS.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "Diagnostics",
      dependencies: [
        .product(name: "RIBs", package: "RIBs-iOS"),
      ],
      plugins: [
      ]
    ),
    .testTarget(
      name: "DiagnosticsTests",
      dependencies: [
        .product(name: "Nimble", package: "Nimble"),
        .product(name: "Quick", package: "Quick"),
        .product(name: "RxSwift", package: "RxSwift"),
        .target(name: "Diagnostics"),
      ],
      plugins: [
      ]
    )
  ]
)
