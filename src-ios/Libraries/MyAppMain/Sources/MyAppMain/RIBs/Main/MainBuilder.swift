// (c) Copyright Modaal.dev 2026

import UIKit
import CombineRIBs
import SharedUtility
import SimpleTheming
import Storage

/// sourcery: CreateMock
protocol MainDependency: Dependency {
  var themeProvider: ThemeProviding { get }
  //var storage: Storing { get }
}

final class MainComponent: Component<MainDependency> {
  var themeProvider: ThemeProviding { dependency.themeProvider }
  //var storage: Storing { dependency.storage }
}

// MARK: - Builder

/// sourcery: CreateMock
protocol MainBuildable: Buildable {
  func build(withListener listener: MainListener,
             navigationController: NavigationControllable) -> MainRouting
}

final class MainBuilder: Builder<MainDependency>, MainBuildable {

  override init(dependency: MainDependency) {
    super.init(dependency: dependency)
  }

  func build(withListener listener: MainListener,
             navigationController: NavigationControllable) -> MainRouting
  {
    let component = MainComponent(dependency: dependency)

    let viewController = MainViewController(
      themeProvider: component.themeProvider)

    let interactor = MainInteractor(
      presenter: viewController)

    interactor.listener = listener

    let router = MainRouter(
      navigationController: navigationController,
      viewController: viewController,
      interactor: interactor)

    return router
  }
}
