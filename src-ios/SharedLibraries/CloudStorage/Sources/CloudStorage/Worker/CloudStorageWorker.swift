//(c) Copyright Modaal.dev 2026

import RIBs
import FirAppConfigure

/// sourcery: CreateMock
public protocol CloudStoring: CloudStorageReferencing {
}

/// sourcery: CreateMock
public protocol CloudStorageWorking: Working {
  func cloudStorage() -> CloudStoring
}

public final class CloudStorageWorker: Worker, CloudStorageWorking {
  let cloudStore: FirebaseCloudStorageProtocol

  public init(cloudStore: FirebaseCloudStorageProtocol) {
    self.cloudStore = cloudStore

    super.init()
  }

  public override func didStart(_ interactorScope: any InteractorScope) {
    super.didStart(interactorScope)
  }

  // MARK: - CloudStorageWorking
  public func cloudStorage() -> CloudStoring {
    let reference = cloudStore.reference()
    return CloudStorageReference(reference: reference)
  }
}

extension CloudStorageReference: CloudStoring {}
