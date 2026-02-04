//(c) Copyright Modaal.dev 2026

import Foundation

/// sourcery: CreateMock
public protocol CloudStorageReferencing: CloudCollectionStoring, CloudFileStoring {
  var fullPath: String { get }
  var name: String { get }
  var bucket: String { get }

  func child(path: String) -> CloudStorageReferencing
  func parent() -> CloudStorageReferencing?
  func root() -> CloudStorageReferencing
}
