// (c) Copyright Modaal.dev 2026

import CombineRIBs
import Foundation
import SharedUtility
import SwiftUI

/// sourcery: CreateMock
protocol SplashRouting: ViewableRouting {
}

/// sourcery: CreateMock
protocol SplashPresentable: Presentable {
  var splashDidFinish: AnyActionHandler<Void>? { get set }
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

    // AnyActionHandler automatically captures self weakly
    presenter.splashDidFinish = AnyActionHandler(self) { interactor in
      interactor.listener?.splashDidComplete()
    }
  }
}
