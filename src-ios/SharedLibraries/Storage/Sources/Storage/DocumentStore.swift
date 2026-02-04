//(c) Copyright Modaal.dev 2026

import Foundation
import RxSwift
import FirAppConfigure
import FirebaseFirestore

enum DocumentReferenceOrSnapshot {
  case reference(DocumentReference)
  case snapshot(DocumentSnapshot)
}

final class DocumentStore: DocumentStoring {
  let document: DocumentReferenceOrSnapshot

  init(document: DocumentReferenceOrSnapshot) {
    self.document = document
  }

  var documentId: String {
    document.documentId
  }

  func collection(_ path: String) -> any CollectionStoring {
    CollectionStore(
      collectionRef: document.reference.collection(path))
  }

  func get<T: Codable>(as type: T.Type) -> Result<T?, Error> {
    guard case let .snapshot(snapshot) = document else {
      return .failure(NSError(domain: "CodableDocumentStoring", code: -1))
    }

    let data = try? snapshot.data(as: type)
    return .success(data)
  }

  func get() -> Result<[String: Any]?, Error> {
    guard case let .snapshot(snapshot) = document else {
      return .failure(NSError(domain: "CodableDocumentStoring", code: -1))
    }

    let data = snapshot.data()
    return .success(data)
  }

  func observe<T>(as type: T.Type) -> Observable<T?> where T: Codable {
    return Observable.create { observer in
      let disposable = BooleanDisposable()
      let listener = self.document.reference.addSnapshotListener { snapshot, error in
        guard !disposable.isDisposed else { return }

        if let error {
          observer.onError(error)
          return
        }

        guard let snapshot, snapshot.exists else {
          observer.onNext(nil)
          return
        }

        do {
          let data = try snapshot.data(as: T.self)
          observer.onNext(data)
        } catch let e {
          observer.onError(e)
        }

      }
      return Disposables.create {
        listener.remove()
        disposable.dispose()
      }
    }
  }

  func observe() -> Observable<[String: Any]?> {
    return Observable.create { observer in
      let disposable = BooleanDisposable()
      let listener = self.document.reference.addSnapshotListener { snapshot, error in
        guard !disposable.isDisposed else { return }

        if let error {
          observer.onError(error)
          return
        }

        guard let snapshot, snapshot.exists else {
          observer.onNext(nil)
          return
        }

        let data = snapshot.data()
        observer.onNext(data)
      }
      return Disposables.create {
        listener.remove()
        disposable.dispose()
      }
    }
  }

  func setData<T>(
    _ data: T,
    mergeOption: Storage.MergeOption) -> Single<Void> where T: Codable
  {
    return Single.create { [documentReference = document.reference] observer in
      let disposable = BooleanDisposable()
      do {
        try mergeOption.setData(documentReference, data: data) { error in
          guard !disposable.isDisposed else { return }

          if let error {
            observer(.failure(error))
          } else {
            observer(.success(()))
          }
        }
      } catch let e {
        observer(.failure(e))
      }
      return disposable
    }
  }

  func setData(
    _ data: [String: Any],
    mergeOption: Storage.MergeOption) -> Single<Void>
  {
    return Single.create { [documentReference = document.reference] observer in
      let disposable = BooleanDisposable()
      mergeOption.setData(documentReference, data: data) { error in
        guard !disposable.isDisposed else { return }

        if let error {
          observer(.failure(error))
        } else {
          observer(.success(()))
        }
      }
      return disposable
    }
  }

  func delete() -> Single<Void> {
    return Single.create { observer in
      let disposable = BooleanDisposable()
      self.document.reference.delete() { error in
        guard !disposable.isDisposed else { return }

        if let error {
          observer(.failure(error))
        } else {
          observer(.success(()))
        }
      }
      return disposable
    }
  }
}

extension DocumentReferenceOrSnapshot {
  var documentId: String {
    switch self {
    case .reference(let ref):
      return ref.documentID
    case .snapshot(let snapshot):
      return snapshot.documentID
    }
  }

  var reference: DocumentReference {
    switch self {
    case .reference(let ref):
      return ref
    case .snapshot(let snapshot):
      return snapshot.reference
    }
  }
}

private extension MergeOption {
  func setData<T: Codable>(
    _ document: DocumentReference,
    data: T,
    completion: ((Error?) -> Void)? = nil) throws
  {
    switch self {
    case .overwrite:
      try document.setData(from: data, merge: false, completion: completion)

    case .merge:
      try document.setData(from: data, merge: true, completion: completion)

    case .mergeFields(let fields):
      try document.setData(from: data, mergeFields: fields, completion: completion)
    }
  }

  func setData(
    _ document: DocumentReference,
    data: [String: Any],
    completion: ((Error?) -> Void)? = nil)
  {
    switch self {
    case .overwrite:
      document.setData(data, merge: false, completion: completion)

    case .merge:
      document.setData(data, merge: true, completion: completion)

    case .mergeFields(let fields):
      document.setData(data, mergeFields: fields, completion: completion)
    }
  }
}
