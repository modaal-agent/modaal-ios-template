// (c) Copyright Modaal.dev 2026

/// sourcery: CreateMock
public protocol Storing {

  // MARK: - Generic document store
  func document(_ path: String) -> DocumentStoring
  func collection(_ path: String) -> CollectionStoring
}
