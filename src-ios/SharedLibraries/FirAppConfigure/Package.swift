// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "FirAppConfigure",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    .library(name: "FirAppConfigure", targets: ["FirAppConfigure"])
  ],
  dependencies: [
    .package(url: "https://github.com/akaffenberger/firebase-ios-sdk-xcframeworks.git", from: "12.7.0"),
    .package(url: "https://github.com/Quick/Nimble.git", from: "14.0.0"),
    .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
    .package(url: "https://github.com/uber/RIBs-iOS.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "FirAppConfigure",
      dependencies: [
        .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk-xcframeworks"),
        .product(name: "FirebaseAuth", package: "firebase-ios-sdk-xcframeworks"),
        .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk-xcframeworks"),
        .product(name: "FirebaseFirestore", package: "firebase-ios-sdk-xcframeworks"),
        .product(name: "FirebaseStorage", package: "firebase-ios-sdk-xcframeworks"),
        .product(name: "RIBs", package: "RIBs-iOS"),
      ]
    ),
    .testTarget(
      name: "FirAppConfigureTests",
      dependencies: [
        .product(name: "Nimble", package: "Nimble"),
        .product(name: "Quick", package: "Quick"),
        .target(name: "FirAppConfigure"),
      ]
    )
  ]
)
