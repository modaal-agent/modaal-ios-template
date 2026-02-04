// (c) Copyright Modaal.dev 2026

import RIBs
import SimpleTheming
import SwiftUI

/// sourcery: CreateMock
protocol SplashDependency: Dependency {
  var themeProvider: ThemeProviding { get }
}

final class SplashComponent: Component<SplashDependency> {
  var themeProvider: ThemeProviding { dependency.themeProvider }
}

// MARK: - Builder

/// sourcery: CreateMock
protocol SplashBuildable: Buildable {
  func build(withListener listener: SplashListener) -> SplashRouting
}

final class SplashBuilder: Builder<SplashDependency>, SplashBuildable {

  override init(dependency: SplashDependency) {
    super.init(dependency: dependency)
  }

  func build(withListener listener: SplashListener) -> SplashRouting {
    let component = SplashComponent(dependency: dependency)
    let viewController = SplashViewController(
      themeProvider: component.themeProvider)
    let interactor = SplashInteractor(
      presenter: viewController)
    interactor.listener = listener
    return SplashRouter(interactor: interactor, viewController: viewController)
  }
}
