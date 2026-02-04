//(c) Copyright Modaal.dev 2026

import Combine

/// sourcery: CreateMock
public protocol CloudStorageListResultProtocol {
  func prefixes() -> [CloudStorageReferencing]
  func items() -> [CloudStorageReferencing]
}

/// sourcery: CreateMock
public protocol CloudCollectionStoring {
  func listAll() -> AnyPublisher<CloudStorageListResultProtocol, Error>
}
