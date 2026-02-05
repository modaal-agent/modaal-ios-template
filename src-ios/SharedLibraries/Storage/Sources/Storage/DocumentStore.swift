// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import FirAppConfigure
import FirebaseFirestore
import Foundation

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

  func observe<T>(as type: T.Type) -> AnyPublisher<T?, Error> where T: Codable {
    let subject = PassthroughSubject<T?, Error>()

    let listener = self.document.reference.addSnapshotListener { snapshot, error in
      if let error {
        subject.send(completion: .failure(error))
        return
      }

      guard let snapshot, snapshot.exists else {
        subject.send(nil)
        return
      }

      do {
        let data = try snapshot.data(as: T.self)
        subject.send(data)
      } catch {
        subject.send(completion: .failure(error))
      }
    }

    return subject
      .handleEvents(receiveCancel: {
        listener.remove()
      })
      .eraseToAnyPublisher()
  }

  func observe() -> AnyPublisher<[String: Any]?, Error> {
    let subject = PassthroughSubject<[String: Any]?, Error>()

    let listener = self.document.reference.addSnapshotListener { snapshot, error in
      if let error {
        subject.send(completion: .failure(error))
        return
      }

      guard let snapshot, snapshot.exists else {
        subject.send(nil)
        return
      }

      let data = snapshot.data()
      subject.send(data)
    }

    return subject
      .handleEvents(receiveCancel: {
        listener.remove()
      })
      .eraseToAnyPublisher()
  }

  func setData<T>(
    _ data: T,
    mergeOption: Storage.MergeOption) -> AnyPublisher<Void, Error> where T: Codable
  {
    Future { [documentReference = document.reference] promise in
      do {
        try mergeOption.setData(documentReference, data: data) { error in
          if let error {
            promise(.failure(error))
          } else {
            promise(.success(()))
          }
        }
      } catch {
        promise(.failure(error))
      }
    }
    .eraseToAnyPublisher()
  }

  func setData(
    _ data: [String: Any],
    mergeOption: Storage.MergeOption) -> AnyPublisher<Void, Error>
  {
    Future { [documentReference = document.reference] promise in
      mergeOption.setData(documentReference, data: data) { error in
        if let error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }
    .eraseToAnyPublisher()
  }

  func delete() -> AnyPublisher<Void, Error> {
    Future { promise in
      self.document.reference.delete { error in
        if let error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }
    .eraseToAnyPublisher()
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
