// (c) Copyright Modaal.dev 2026

import CombineRIBs
import UIKit

/// sourcery: CreateMock
protocol MainRouting: ViewableRouting {
}

/// sourcery: CreateMock
protocol MainListener: AnyObject {
}

protocol MainPresentable: Presentable {
}

final class MainInteractor: PresentableInteractor<MainPresentable>, MainInteractable {

  weak var router: MainRouting?
  weak var listener: MainListener?

  override init(presenter: MainPresentable) {
    super.init(presenter: presenter)
  }

  override func didBecomeActive() {
    super.didBecomeActive()
  }

  override func willResignActive() {
    super.willResignActive()
  }
}
