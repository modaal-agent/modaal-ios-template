//(c) Copyright Modaal.dev 2026

import Foundation

public extension Sequence {
  @inlinable
  func dictionary<Key, Value>(uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Key: Value] where Element == (Key, Value) {
    return try Dictionary(self, uniquingKeysWith: combine)
  }

  @inlinable
  func dictionary<Key, Value>() -> [Key: Value] where Element == (Key, Value) {
    return Dictionary(uniqueKeysWithValues: self)
  }
}
