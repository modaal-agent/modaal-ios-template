// (c) Copyright Modaal.dev 2026

import Foundation
import RIBs
import RxSwift
import SwiftUI

/// sourcery: CreateMock
protocol SplashRouting: ViewableRouting {
}

/// sourcery: CreateMock
protocol SplashPresentable: Presentable {
  var splashDidFinish: AnyObserver<Void>? { get set }
}

/// sourcery: CreateMock
protocol SplashListener: AnyObject {
  func splashDidComplete()
}

final class SplashInteractor: PresentableInteractor<SplashPresentable>, SplashInteractable {

  weak var router: SplashRouting?
  weak var listener: SplashListener?

  override init(presenter: SplashPresentable)
  {
    super.init(presenter: presenter)

    presenter.splashDidFinish = AnyObserver { [weak self] _ in
      guard let self else { return }
      listener?.splashDidComplete()
    }
  }
}
