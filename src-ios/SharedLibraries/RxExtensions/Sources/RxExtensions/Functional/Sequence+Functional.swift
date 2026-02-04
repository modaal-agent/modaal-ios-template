// (c) Copyright Modaal.dev 2026

import Foundation

public extension Sequence where Element: OptionalType {
  @inlinable
  func compact() -> [Element.Wrapped] {
    return compactMap { $0.flatMap { $0 } }
  }
}

public extension Sequence where Element: Sequence {
  @inlinable
  func flatten() -> [Element.Element] {
    flatMap { $0 }
  }
}
