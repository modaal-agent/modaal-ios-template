// (c) Copyright Modaal.dev 2026

import RxSwift

extension Disposable {
  @inlinable
  @discardableResult
  public func insert(into compositeDisposable: CompositeDisposable) -> CompositeDisposable.DisposeKey? {
    return compositeDisposable.insert(self)
  }
}
