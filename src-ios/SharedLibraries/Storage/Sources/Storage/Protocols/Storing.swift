// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

/// sourcery: CreateMock
public protocol Storing {

  // MARK: - Generic document store
  func document(_ path: String) -> DocumentStoring
  func collection(_ path: String) -> CollectionStoring
}
