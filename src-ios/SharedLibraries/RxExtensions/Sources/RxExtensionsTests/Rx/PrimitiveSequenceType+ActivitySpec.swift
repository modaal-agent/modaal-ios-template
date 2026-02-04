// (c) Copyright Modaal.dev 2026

import Quick
import Nimble
import RxSwift
import RxBlocking
@testable import RxExtensions

class PrimitiveSequenceTypeActivityScec: QuickSpec {
  override static func spec() {
    describe("delaySubscription()") {
      var bag: DisposeBag!
      beforeEach {
        bag = DisposeBag()
      }
      afterEach {
        bag = nil
      }

      context("initially inactive") {
        var activitySubject: BehaviorSubject<Bool>!
        var observedActivitySubject: BehaviorSubject<Bool>!
        var sut: ((SingleEvent<Void>) -> ())!
        var onSubscribe: Bool = false
        var onDispose: Bool = false
        var observedEvents: [SingleEvent<Void>]!
        beforeEach {
          activitySubject = BehaviorSubject(value: false)
          observedActivitySubject = BehaviorSubject(value: false)

          onSubscribe = false
          onDispose = false
          observedEvents = []
          Single.create { observer in
            sut = observer
            return Disposables.create()
          }
            .do(onSubscribe: { onSubscribe = true },
                onDispose: { onDispose = true })
            .bindSubscriptionIsActive(to: observedActivitySubject.asObserver())
            .delaySubscription(untilInactive: activitySubject)
            .subscribe {
              observedEvents.append($0)
            }
            .disposed(by: bag)
        }
        it("subscribed immediately") {
          expect(onSubscribe) == true
        }
        it("not disposed") {
          expect(onDispose) == false
        }
        it("observed activity == true") {
          expect(try! observedActivitySubject.value()) == true
        }
        context("event is sent") {
          beforeEach {
            sut(.success(()))
          }
          it("event observed") {
            expect(observedEvents).to(haveCount(1))
          }
          it("disposed") {
            expect(onDispose) == true
          }
          it("observed activity == false") {
            expect(try! observedActivitySubject.value()) == false
          }
        } // context("event is sent")
      } // context("initially inactive")
      context("initially active") {
        var activitySubject: BehaviorSubject<Bool>!
        var observedActivitySubject: BehaviorSubject<Bool>!
        var sut: ((SingleEvent<Void>) -> ())!
        var onSubscribe: Bool = false
        var onDispose: Bool = false
        var observedEvents: [SingleEvent<Void>]!
        beforeEach {
          activitySubject = BehaviorSubject(value: true)
          observedActivitySubject = BehaviorSubject(value: false)

          onSubscribe = false
          onDispose = false
          observedEvents = []
          Single.create { observer in
            sut = observer
            return Disposables.create()
          }
          .do(onSubscribe: { onSubscribe = true },
              onDispose: { onDispose = true })
          .bindSubscriptionIsActive(to: observedActivitySubject.asObserver())
          .delaySubscription(untilInactive: activitySubject)
          .subscribe {
            observedEvents.append($0)
          }
          .disposed(by: bag)
        }
        it("not subscribed") {
          expect(onSubscribe) == false
        }
        it("not disposed") {
          expect(onDispose) == false
        }
        it("observed activity == false") {
          expect(try! observedActivitySubject.value()) == false
        }
        context("becomes inactive") {
          beforeEach {
            activitySubject.onNext(false)
          }
          it("subscribed") {
            expect(onSubscribe) == true
          }
          it("not disposed") {
            expect(onDispose) == false
          }
          it("observed activity == true") {
            expect(try! observedActivitySubject.value()) == true
          }
          context("event is sent") {
            beforeEach {
              sut(.success(()))
            }
            it("event observed") {
              expect(observedEvents).to(haveCount(1))
            }
            it("disposed") {
              expect(onDispose) == true
            }
            it("observed activity == false") {
              expect(try! observedActivitySubject.value()) == false
            }
          } // context("event is sent")
        } // context("becomes active")
      } // context("initially active")
    } // describe("delaySubscription()")
  }
}
