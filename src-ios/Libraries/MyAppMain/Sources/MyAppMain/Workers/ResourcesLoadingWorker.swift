// (c) Copyright Modaal.dev 2026

import Foundation
import RIBs
import RxSwift
import RxRelay

protocol ResourcesLoadingWorking: Working {
  var resourcesReady: Observable<Bool> { get }
}

final class ResourcesLoadingWorker: Worker, ResourcesLoadingWorking {

  var resourcesReady: Observable<Bool> {
    return resourcesReadySubject.asObservable()
  }

  private let resourcesReadySubject = ReplayRelay<Bool>.create(bufferSize: 1)

  override func didStart(_ interactorScope: any InteractorScope) {
    super.didStart(interactorScope)

    // Mock implementation - in a real app, this would load resources

    Observable
      .just(true).delay(.seconds(1), scheduler: MainScheduler.asyncInstance)
      .bind(to: resourcesReadySubject)
      .disposeOnStop(self)
  }
}
