// (c) Copyright Modaal.dev 2026

import UIKit
import RIBs
import RxSwift
import RxRelay
import Storage

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
  let preloadingTimeoutScheduler: SchedulerType

  weak var router: RootRoutingInternal?

  private let splashDidCompleteRelay = ReplayRelay<Bool>.create(bufferSize: 1)

  init(//storageWorker: StorageWorking,
       resourcesLoadingWorker: ResourcesLoadingWorking,
       preloadingTimeoutScheduler: SchedulerType = ConcurrentMainScheduler.instance) {

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
    Observable
      .combineLatest(
        resourcesLoadingWorker.resourcesReady,
        splashDidCompleteRelay,
      ) { $0 && $1 }
      .take(1)
      .timeout(.seconds(2), scheduler: MainScheduler.instance)
      .catchAndReturn(true)
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [router] _ in
        router?.routeToMain()
      })
      .disposeOnDeactivate(interactor: self)
  }

  override func willResignActive() {
    super.willResignActive()
  }

  // MARK: - SplashListener

  func splashDidComplete() {
    splashDidCompleteRelay.accept(true)
  }
}
