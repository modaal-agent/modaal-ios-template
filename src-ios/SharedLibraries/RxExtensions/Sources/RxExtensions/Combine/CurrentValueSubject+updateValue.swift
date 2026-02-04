// (c) Copyright Modaal.dev 2026

import Combine

@available(iOS 13.0, *)
public extension CurrentValueSubject {
  func updateValue(_ update: (Output) -> (Output)) {
    value = update(value)
  }

  func updateValue(_ update: (inout Output) -> ()) {
    var value = self.value
    update(&value)
    self.value = value
  }
}
