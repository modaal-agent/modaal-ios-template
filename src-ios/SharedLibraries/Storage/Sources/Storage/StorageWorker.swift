// (c) Copyright Modaal.dev 2026

import RIBs
import RxSwift
import FirAppConfigure

/// sourcery: CreateMock
public protocol StorageWorking: Working, Storing {
}

public final class StorageWorker: Worker, StorageWorking {

  let store: FirebaseFirestoreProtocol

  public init(store: FirebaseFirestoreProtocol) {

    self.store = store

    super.init()
  }

  // MARK: - Worker overrides

  public override func didStart(_ interactorScope: InteractorScope) {
    super.didStart(interactorScope)

  }

  // MARK: - Storing

  public func document(_ path: String) -> DocumentStoring {
    DocumentStore(
      document: .reference(store.document(path))
    )
  }

  public func collection(_ path: String) -> CollectionStoring {
    CollectionStore(
      collectionRef: store.collection(path)
    )
  }
}
