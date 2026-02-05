// swift-tools-version:5.9

// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

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
    .package(url: "https://github.com/modaal-agent/CombineRIBs.git", from: "2.1.0"),
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
        .product(name: "CombineRIBs", package: "CombineRIBs"),
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
