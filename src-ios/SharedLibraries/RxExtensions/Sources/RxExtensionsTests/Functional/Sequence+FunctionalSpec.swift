// (c) Copyright Modaal.dev 2026

@testable import RxExtensions
import Foundation
import Quick
import Nimble

final class SequenceFunctionalSpec: QuickSpec {
  static override func spec() {
    let sut: [Int?] = [0, 1, nil, nil, 2]
    describe("compact()") {
      it("removes nil elements") {
        expect(sut.compact()) == [0, 1, 2]
      }
    } // describe("compact()")
  }
}
