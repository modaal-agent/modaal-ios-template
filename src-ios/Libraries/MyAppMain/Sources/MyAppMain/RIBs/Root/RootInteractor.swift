// (c) Copyright Modaal.dev 2026

import Combine
import CombineRIBs
import Storage
import UIKit

/// sourcery: CreateMock
public protocol RootRouting: LaunchRouting {
}

/// sourcery: CreateMock
protocol RootRoutingInternal: RootRouting {
  func routeToSplash()
  func routeToMain()
}

final class RootInteractor: Interactor, RootInteractableInternal {

  //let storageWorker: StorageWorking
  let resourcesLoadingWorker: ResourcesLoadingWorking
  let preloadingTimeoutScheduler: DispatchQueue

  weak var router: RootRoutingInternal?

  private let splashDidCompleteSubject = CurrentValueSubject<Bool, Never>(false)

  init(//storageWorker: StorageWorking,
       resourcesLoadingWorker: ResourcesLoadingWorking,
       preloadingTimeoutScheduler: DispatchQueue = .main) {

    //self.storageWorker = storageWorker
    self.resourcesLoadingWorker = resourcesLoadingWorker
    self.preloadingTimeoutScheduler = preloadingTimeoutScheduler

    super.init()
  }

  override func didBecomeActive() {
    super.didBecomeActive()

    // Start workers
    //storageWorker.start(self)
    resourcesLoadingWorker.start(self)

    // Route to splash immediately
    router?.routeToSplash()

    // Stay on the Splash until both the Splash and ResourcesLoading complete
    Publishers.CombineLatest(
      resourcesLoadingWorker.resourcesReady,
      splashDidCompleteSubject.filter { $0 }
    )
    .map { $0 && $1 }
    .first()
    .timeout(.seconds(2), scheduler: DispatchQueue.main)
    .replaceError(with: true)
    .receive(on: DispatchQueue.main)
    .sink { [weak router] _ in
      router?.routeToMain()
    }
    .cancelOnDeactivate(interactor: self)
  }

  override func willResignActive() {
    super.willResignActive()
  }

  // MARK: - SplashListener

  func splashDidComplete() {
    splashDidCompleteSubject.send(true)
  }
}
