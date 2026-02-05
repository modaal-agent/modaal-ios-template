// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

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
