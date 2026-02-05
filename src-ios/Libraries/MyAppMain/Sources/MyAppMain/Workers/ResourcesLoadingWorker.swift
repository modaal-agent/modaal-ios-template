// (c) Copyright Modaal.dev 2026

import Combine
import CombineRIBs
import Foundation

protocol ResourcesLoadingWorking: Working {
  var resourcesReady: AnyPublisher<Bool, Never> { get }
}

final class ResourcesLoadingWorker: Worker, ResourcesLoadingWorking {

  var resourcesReady: AnyPublisher<Bool, Never> {
    return resourcesReadySubject
      .filter { $0 }
      .eraseToAnyPublisher()
  }

  private let resourcesReadySubject = CurrentValueSubject<Bool, Never>(false)

  override func didStart(_ interactorScope: any InteractorScope) {
    super.didStart(interactorScope)

    // Mock implementation - in a real app, this would load resources

    Just(true)
      .delay(for: .seconds(1), scheduler: DispatchQueue.main)
      .sink { [weak self] value in
        self?.resourcesReadySubject.send(value)
      }
      .cancelOnStop(self)
  }
}
