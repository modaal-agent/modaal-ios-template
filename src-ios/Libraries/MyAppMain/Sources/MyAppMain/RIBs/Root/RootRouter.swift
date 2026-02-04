// (c) Copyright Modaal.dev 2026

import UIKit
import CombineRIBs

/// sourcery: CreateMock
protocol RootInteractable: Interactable {
}

/// sourcery: CreateMock
protocol RootInteractableInternal: RootInteractable, SplashListener, MainListener {
  var router: RootRoutingInternal? { get set }
}

final class RootRouter: LaunchRouter<RootInteractable, ViewControllable>, RootRoutingInternal {

  let interactorInternal: RootInteractableInternal

  let splashBuilder: SplashBuildable
  let mainBuilder: MainBuildable

  init(interactor: RootInteractableInternal,
       viewController: ViewControllable,
       splashBuilder: SplashBuildable,
       mainBuilder: MainBuildable) {

    self.interactorInternal = interactor

    self.splashBuilder = splashBuilder
    self.mainBuilder = mainBuilder

    super.init(interactor: interactor, viewController: viewController)

    interactorInternal.router = self
  }

  // MARK: - RootRouting

  public func routeToSplash() {
    let splashRouter = splashBuilder.build(withListener: interactorInternal)

    let viewController = splashRouter.viewControllable
    viewControllable.uiviewController.addChild(viewController.uiviewController)
    viewControllable.uiviewController.view.addSubview(viewController.uiviewController.view)

    makeEdgesEqualToSuperview(view: viewController.uiviewController.view, superview: viewControllable.uiviewController.view)

    attachChild(splashRouter)
  }

  public func routeToMain() {
    let navigationController = UINavigationController()

    let mainRouter = mainBuilder.build(
      withListener: interactorInternal,
      navigationController: navigationController)

    let viewController = mainRouter.viewControllable
    navigationController.viewControllers = [viewController.uiviewController]

    viewControllable.uiviewController.addChild(navigationController.uiviewController)
    viewControllable.uiviewController.view.addSubview(navigationController.uiviewController.view)

    makeEdgesEqualToSuperview(view: navigationController.uiviewController.view, superview: viewControllable.uiviewController.view)

    // Remove splash screen
    let routersToRemove = children.filter { !($0 is MainRouting) }
    for prevRouter in routersToRemove {
      if let prevRouter = prevRouter as? ViewableRouting {
        prevRouter.viewControllable.uiviewController.view.removeFromSuperview()
        prevRouter.viewControllable.uiviewController.removeFromParent()
        detachChild(prevRouter)
      }
    }

    attachChild(mainRouter)
  }
}

private func makeEdgesEqualToSuperview(view: UIView, superview: UIView) {
  view.translatesAutoresizingMaskIntoConstraints = false
  NSLayoutConstraint.activate([
    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
    view.topAnchor.constraint(equalTo: superview.topAnchor),
    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
  ])
}
