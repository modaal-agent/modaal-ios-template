//(c) Copyright Modaal.dev 2026

import Combine
import RxSwift

@available(iOS 13.0, *)
public extension Subject where Failure == any Error {
  func asObserver() -> AnyObserver<Output> {
    return AnyObserver { event in
      switch event {
      case .next(let value):
        self.send(value)
      case .error(let error):
        self.send(completion: .failure(error))
      case .completed:
        self.send(completion: .finished)
      }
    }
  }
}

@available(iOS 13.0, *)
public extension Subject where Failure == Never {
  func asObserver() -> AnyObserver<Output> {
    return AnyObserver { event in
      switch event {
      case .next(let value):
        self.send(value)
      case .error, .completed:
        self.send(completion: .finished)
      }
    }
  }
}
