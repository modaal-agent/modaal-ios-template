// (c) Copyright Modaal.dev 2026

import UIKit
import RIBs
import SimpleTheming
import FirAppConfigure
import Storage

/// sourcery: CreateMock
public protocol RootDependency: Dependency {
}

final class RootComponent: Component<RootDependency> {
  let _themeProvider: ThemeProvider

  let _firAppConfigureWorker: FirAppConfigureWorker
  //let _storageWorker: StorageWorking

  var themeProvider: ThemeProviding { _themeProvider }
  //var storage: Storing { _storageWorker }

  lazy var resourcesLoadingWorker: ResourcesLoadingWorking = {
    ResourcesLoadingWorker()
  }()

  init(dependency: RootDependency,
       rootViewController: UIViewController) {

    _themeProvider = ThemeProvider(
      persistentStorage: ThemePersistentStorage(),
      defaultTheme: Theme.mainTheme,
      defaultPreferredAppearance: .system)

    _firAppConfigureWorker = FirAppConfigureWorker(
      firebaseInfoPlistFilePath: Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"))

//    _storageWorker = StorageWorker(
//      store: _firAppConfigureWorker.firestore())

    super.init(dependency: dependency)
  }
}

// MARK: - Builder

/// sourcery: CreateMock
public protocol RootBuildable: Buildable {
  func build() -> RootRouting
}

final class RootViewController: UIViewController, ViewControllable {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
  }
}

public final class RootBuilder: Builder<RootDependency>, RootBuildable {

  public override init(dependency: RootDependency) {
    super.init(dependency: dependency)
  }

  public func build() -> RootRouting {
    let viewController = RootViewController()
    let component = RootComponent(
      dependency: dependency,
      rootViewController: viewController)
    let interactor = RootInteractor(
      //storageWorker: component._storageWorker,
      resourcesLoadingWorker: component.resourcesLoadingWorker)
    let router = RootRouter(
      interactor: interactor,
      viewController: viewController,
      splashBuilder: SplashBuilder(dependency: component),
      mainBuilder: MainBuilder(dependency: component))
    return router
  }
}

extension RootComponent: SplashDependency {
}

extension RootComponent: MainDependency {
}
