// (c) Copyright Modaal.dev 2026

import Quick
import Nimble
import RxSwift
import RxBlocking
@testable import RxExtensions

class ObservableTypeZipWithPreviousScec: QuickSpec {
  override static func spec() {
    var bag: DisposeBag!
    beforeEach {
      bag = DisposeBag()
    }
    afterEach {
      bag = nil
    }

    describe("zipWithPrevious()") {
      var subject: BehaviorSubject<Int>!
      var observedValue: (Int, Int?)!
      beforeEach {
        subject = BehaviorSubject(value: 1)
      }
      context("initial value") {
        beforeEach {
          subject.zipWithPrevious().subscribe(onNext: { observedValue = $0 }).disposed(by: bag)
        }
        it("(1, nil)") {
          expect(observedValue) == (1, nil)
        }
        context("next value") {
          beforeEach {
            subject.onNext(2)
          }
          it("(2, 1)") {
            expect(observedValue) == (2, 1)
          }
          context("completed") {
            beforeEach {
              subject.onCompleted()
            }
            it("(2, 1)") {
              expect(observedValue) == (2, 1)
            }
          } // context("next value")
        } // context("next value")
      } // context("initial value")
    } // describe("zipWithPrevious()")

    describe("zipWithPreviousOptional()") {
      var subject: BehaviorSubject<Int?>!
      var observedValue: (Int?, Int?)!
      beforeEach {
        subject = BehaviorSubject(value: nil)
      }
      context("initial value") {
        beforeEach {
          subject.zipWithPreviousOptional().subscribe(onNext: { observedValue = ($0.0, $0.1)}).disposed(by: bag)
        }
        it("(nil, nil)") {
          expect(observedValue) == (nil, nil)
        }
        context("next value") {
          beforeEach {
            subject.onNext(1)
          }
          it("(1, nil)") {
            expect(observedValue) == (1, nil)
          }
          context("next value") {
            beforeEach {
              subject.onNext(nil)
            }
            it("(nil, 1)") {
              expect(observedValue) == (nil, 1)
            }
            context("completed") {
              beforeEach {
                subject.onCompleted()
              }
              it("(nil, 1)") {
                expect(observedValue) == (nil, 1)
              }
            } // context("next value")
          } // context("next value")
        } // context("next value")
      } // context("initial value")
    } // describe("zipWithPreviousOptional()")
  }
}
