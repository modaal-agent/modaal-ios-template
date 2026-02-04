//(c) Copyright Modaal.dev 2026

import Combine
import RxSwift

@available(iOS 13.0, *)
public extension Cancellable {
  func asDisposable() -> Disposable {
    Disposables.create(with: cancel)
  }
}

@available(iOS 13.0, *)
public extension Disposable {
  func asCancellable() -> Cancellable {
    AnyCancellable(dispose)
  }
}
