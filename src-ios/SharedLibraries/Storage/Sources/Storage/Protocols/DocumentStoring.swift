// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine

public enum MergeOption {
  case overwrite
  case merge
  case mergeFields([String])
}

/// sourcery: CreateMock
public protocol DocumentStoring {
  var documentId: String { get }

  // MARK: - Nested collections
  func collection(_ path: String) -> CollectionStoring

  // MARK: Data access

  /// sourcery: generictype = "T: Codable"
  /// sourcery: methodName = "getCodable"
  func get<T: Codable>(
    /// sourcery: annotatedGenericTypes = "{T.Type}"
    as type: T.Type) -> Result<T?, Error>

  func get() -> Result<[String: Any]?, Error>

  /// sourcery: generictype = "T: Codable"
  /// sourcery: methodName = "observeCodable"
  func observe<T: Codable>(
    /// sourcery: annotatedGenericTypes = "{T.Type}"
    as type: T.Type) -> AnyPublisher<T?, Error>

  func observe() -> AnyPublisher<[String: Any]?, Error>

  /// sourcery: generictype = "T: Codable"
  /// sourcery: methodName = "setDataCodable"
  func setData<T: Codable>(
    /// sourcery: annotatedGenericTypes = "{T}"
    _ data: T,
    mergeOption: Storage.MergeOption) -> AnyPublisher<Void, Error>

  func setData(
    _ data: [String: Any],
    mergeOption: Storage.MergeOption) -> AnyPublisher<Void, Error>

  func delete() -> AnyPublisher<Void, Error>
}

public extension DocumentStoring {
  func setData<T: Codable>(_ data: T, mergeOption: Storage.MergeOption = .overwrite) -> AnyPublisher<Void, Error> {
    setData(data, mergeOption: mergeOption)
  }

  func setData(_ data: [String: Any], mergeOption: Storage.MergeOption = .overwrite) -> AnyPublisher<Void, Error> {
    setData(data, mergeOption: mergeOption)
  }
}
