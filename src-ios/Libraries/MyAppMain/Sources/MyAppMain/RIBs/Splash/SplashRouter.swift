// (c) Copyright Modaal.dev 2026

import CombineRIBs

/// sourcery: CreateMock
protocol SplashInteractable: Interactable {
}

final class SplashRouter: ViewableRouter<SplashInteractable, ViewControllable>, SplashRouting {

  override init(interactor: SplashInteractable, viewController: ViewControllable) {
    super.init(interactor: interactor, viewController: viewController)
  }
}
