// (c) Copyright Modaal.dev 2026

import Foundation
import RxSwift
import RxRelay

extension BehaviorRelay {
  @inlinable
  public func updateValue(with closure: (inout Element) -> ()) {
    var value = self.value
    closure(&value)
    self.accept(value)
  }

  @inlinable
  public func updateValue(with closure: (inout Element) throws -> ()) rethrows {
    var value = self.value
    try closure(&value)
    self.accept(value)
  }
}

extension BehaviorSubject {
  @inlinable
  public func updateValue(with closure: (inout Element) -> ()) throws {
    var value = try self.value()
    closure(&value)
    self.onNext(value)
  }

  @inlinable
  public func updateValue(with closure: (inout Element) throws -> ()) throws {
    var value = try self.value()
    try closure(&value)
    self.onNext(value)
  }
}
