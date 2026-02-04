//(c) Copyright Modaal.dev 2026

import FirebaseStorage

public final class CloudStorageListResult: CloudStorageListResultProtocol {

  private let result: StorageListResult

  init(result: StorageListResult) {
    self.result = result
  }

  public func prefixes() -> [CloudStorageReferencing] {
    result.prefixes.map { CloudStorageReference(reference: $0) }
  }

  public func items() -> [CloudStorageReferencing] {
    result.items.map { CloudStorageReference(reference: $0) }
  }
}
