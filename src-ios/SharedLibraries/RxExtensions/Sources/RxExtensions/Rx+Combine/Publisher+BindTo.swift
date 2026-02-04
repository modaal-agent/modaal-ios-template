//(c) Copyright Modaal.dev 2026

import Combine

@available(iOS 13.0, *)
public extension Publisher {
  func bind<S: Subject>(to subject: S) -> Cancellable where S.Output == Output, S.Failure == Failure {
    return self.sink(
      receiveCompletion: { completion in
        subject.send(completion: completion)
      },
      receiveValue: { value in
        subject.send(value)
      }
    )
  }
}
