// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import CombineRIBs

/// sourcery: CreateMock
protocol SplashInteractable: Interactable {
}

final class SplashRouter: ViewableRouter<SplashInteractable, ViewControllable>, SplashRouting {

  override init(interactor: SplashInteractable, viewController: ViewControllable) {
    super.init(interactor: interactor, viewController: viewController)
  }
}
