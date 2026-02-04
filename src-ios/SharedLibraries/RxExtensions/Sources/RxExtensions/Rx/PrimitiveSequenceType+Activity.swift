// (c) Copyright Modaal.dev 2026

import RxSwift

extension PrimitiveSequenceType where Trait == SingleTrait {

  public func delaySubscription(untilInactive activityStream: Observable<Bool>) -> Single<Element> {
    return Single.create { observer in
      let compositeDisposable = CompositeDisposable()

      activityStream
        .filter { $0 == false }
        .take(1)
        .do(onNext: { _ in
          self
            .subscribe(observer)
            .insert(into: compositeDisposable)
        })
        .subscribe()
        .insert(into: compositeDisposable)

      return compositeDisposable
    }
  }

  public func bindSubscriptionIsActive(to activityObserver: AnyObserver<Bool>) -> Single<Element> {
    return `do`(onSubscribed: { activityObserver.onNext(true) },
                onDispose: { activityObserver.onNext(false) })
  }
}
