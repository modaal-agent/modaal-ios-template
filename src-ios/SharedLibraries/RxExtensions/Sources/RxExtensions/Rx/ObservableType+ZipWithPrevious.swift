// (c) Copyright Modaal.dev 2026

import RxSwift

extension ObservableType {
  public func zipWithPrevious() -> Observable<(Element, Element?)> {
    return Observable.zip(
      self,
      concat(self).map { $0 }.startWith(nil)
    )
  }
}

extension ObservableType where Element: OptionalType {
  public func zipWithPreviousOptional() -> Observable<(Element.Wrapped?, Element.Wrapped?)> {
    return Observable.zip(
      self.map { $0.flatMap { $0 } },
      concat(self).map { $0.flatMap { $0 } }.startWith(nil)
    )
  }
}
