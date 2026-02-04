// (c) Copyright Modaal.dev 2026

@testable import RxExtensions
import Quick
import Nimble
import RxSwift

private class TestState {
  @RxPublished var count: Int = 0
}

final class RxPublishedSpec: QuickSpec {
  override static func spec() {
    var sut: TestState!
    var bag: DisposeBag!

    beforeEach {
      sut = TestState()
      bag = DisposeBag()
    }
    afterEach {
      bag = nil
    }

    describe("value can be read") {
      it("count has initial value") {
        expect(sut.count) == 0
      }
    } // /describe

    describe("value can be updated") {
      beforeEach {
        sut.count = 10
      }
      it("count is updated") {
        expect(sut.count) == 10
      }
    } // /describe

    describe("value can be observed") {
      var observedValue: Int?
      beforeEach {
        sut.$count
          .subscribe(onNext: { observedValue = $0 })
          .disposed(by: bag)

        sut.count = 20
      }

      it("observedValue is updated") {
        expect(observedValue) == 20
      }
    } // /describe
  } // /spec
}
