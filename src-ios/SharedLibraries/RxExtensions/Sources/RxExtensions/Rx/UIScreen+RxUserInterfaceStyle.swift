// (c) Copyright Modaal.dev 2026

import UIKit
import RxCocoa
import RxSwift

public extension Reactive where Base == UIScreen {
  @available(iOS 13.0, *)
  func userInterfaceStyle() -> Observable<UIUserInterfaceStyle> {
    let selector = #selector(UIScreen.traitCollectionDidChange(_:))
    return methodInvoked(selector)
      .flatMap { (args) -> Observable<UIUserInterfaceStyle> in
        return Observable.just(UITraitCollection.current.userInterfaceStyle)
      }
      .startWith(UITraitCollection.current.userInterfaceStyle)
  }
}
