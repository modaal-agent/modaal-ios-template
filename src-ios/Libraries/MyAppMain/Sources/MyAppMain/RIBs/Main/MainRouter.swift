// (c) Copyright Modaal.dev 2026

import CombineRIBs
import UIKit
import SharedUtility
import SimpleTheming

/// sourcery: CreateMock
protocol MainInteractable: Interactable {
  var router: MainRouting? { get set }
  var listener: MainListener? { get set }
}

/// sourcery: CreateMock
protocol MainViewControllable: ViewControllable {
}

final class MainRouter: ViewableRouter<MainInteractable, MainViewControllable>, MainRouting {

  let navigationController: NavigationControllable

  init(navigationController: NavigationControllable,
       viewController: MainViewControllable,
       interactor: MainInteractable) {

    self.navigationController = navigationController

    super.init(interactor: interactor, viewController: viewController)

    interactor.router = self
  }

  // MARK: - Router overrides

  override func didLoad() {
    super.didLoad()
  }
}
