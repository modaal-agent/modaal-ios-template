//(c) Copyright Modaal.dev 2026

import Combine
import FirAppConfigure
import FirebaseFirestore
import Foundation

class QueryableCollectionStore: QueryiableCollectionStoring {
  let query: Query

  fileprivate init(query: Query) {
    self.query = query
  }

  // MARK: - QueryiableCollectionStoring

  func filter(_ filter: Filter) -> QueryiableCollectionStoring {
    QueryableCollectionStore(
      query: query.whereFilter(filter.asFirestoreFilter))
  }

  func order(by field: FieldPath, descending value: Bool) -> QueryiableCollectionStoring {
    QueryableCollectionStore(
      query: query.order(by: field.asFirestoreFieldPath, descending: value))
  }

  func limit(to value: Int) -> QueryiableCollectionStoring {
    QueryableCollectionStore(
      query: query.limit(to: value))
  }

  func limit(toLast value: Int) -> QueryiableCollectionStoring {
    QueryableCollectionStore(
      query: query.limit(toLast: value))
  }

  func get() -> AnyPublisher<[String: DocumentStoring], Error> {
    Future { promise in
      self.query.getDocuments { snapshot, error in
        if let error {
          promise(.failure(error))
          return
        }

        guard let snapshot, !snapshot.isEmpty else {
          promise(.success([:]))
          return
        }

        let values = snapshot.documents
          .map { documentSnapshot -> (String, DocumentStoring) in
            (documentSnapshot.documentID, DocumentStore(document: .snapshot(documentSnapshot)))
          }
          .dictionary()

        promise(.success(values))
      }
    }
    .eraseToAnyPublisher()
  }

  func list() -> AnyPublisher<[String: DocumentStoring], Error> {
    let subject = PassthroughSubject<[String: DocumentStoring], Error>()

    let listener = self.query.addSnapshotListener { snapshot, error in
      if let error {
        subject.send(completion: .failure(error))
        return
      }

      guard let snapshot, !snapshot.isEmpty else {
        subject.send([:])
        return
      }

      let values = snapshot.documents
        .map { documentSnapshot -> (String, DocumentStoring) in
          (documentSnapshot.documentID, DocumentStore(document: .snapshot(documentSnapshot)))
        }
        .dictionary()

      subject.send(values)
    }

    return subject
      .handleEvents(receiveCancel: {
        listener.remove()
      })
      .eraseToAnyPublisher()
  }

  // MARK: - Aggregation
  func count() -> AnyPublisher<Int, Error> {
    Future { promise in
      self.query
        .count
        .getAggregation(source: .server) { aggregateSnapshot, error in
          if let error {
            promise(.failure(error))
            return
          }

          guard let aggregateSnapshot else {
            promise(.success(0))
            return
          }

          promise(.success(aggregateSnapshot.count.intValue))
        }
    }
    .eraseToAnyPublisher()
  }
}

final class CollectionStore: QueryableCollectionStore, CollectionStoring {
  let collectionRef: CollectionReference

  init(collectionRef: CollectionReference) {
    self.collectionRef = collectionRef
    super.init(query: collectionRef)
  }

  var collectionId: String {
    collectionRef.collectionID
  }

  func document() -> DocumentStoring {
    DocumentStore(
      document: .reference(collectionRef.document()))
  }

  func document(_ path: String) -> DocumentStoring {
    DocumentStore(
      document: .reference(collectionRef.document(path)))
  }
}

private extension Sequence {
  func dictionary<Key, Value>() -> [Key: Value] where Element == (Key, Value) {
    return Dictionary(uniqueKeysWithValues: self)
  }
}

private extension FieldPath {
  var asFirestoreFieldPath: FirebaseFirestore.FieldPath {
    switch self {
    case .documentId: return .documentID()
    case .fields(let fields): return .init(fields)
    }
  }
}

private extension Filter {
  var asFirestoreFilter: FirebaseFirestore.Filter {
    switch self {
    case .equalTo(let fieldPath, let value):
      return .whereField(fieldPath.asFirestoreFieldPath, isEqualTo: value)
    case .notEqualTo(let fieldPath, let value):
      return .whereField(fieldPath.asFirestoreFieldPath, isNotEqualTo: value)
    case .greaterThan(let fieldPath, let value):
      return .whereField(fieldPath.asFirestoreFieldPath, isGreaterThan: value)
    case .greaterThanOrEqualTo(let fieldPath, let value):
      return .whereField(fieldPath.asFirestoreFieldPath, isGreaterOrEqualTo: value)
    case .lessThan(let fieldPath, let value):
      return .whereField(fieldPath.asFirestoreFieldPath, isLessThan: value)
    case .lessThanOrEqualTo(let fieldPath, let value):
      return .whereField(fieldPath.asFirestoreFieldPath, isLessThanOrEqualTo: value)
    case .arrayContains(let fieldPath, let value):
      return .whereField(fieldPath.asFirestoreFieldPath, arrayContains: value)
    case .arrayContainsAny(let fieldPath, let values):
      return .whereField(fieldPath.asFirestoreFieldPath, arrayContainsAny: values)
    case .fieldIn(let fieldPath, let values):
      return .whereField(fieldPath.asFirestoreFieldPath, in: values)
    case .fieldNotIn(let fieldPath, let values):
      return .whereField(fieldPath.asFirestoreFieldPath, notIn: values)
    case .any(let filters):
      return .orFilter(filters.map(\.asFirestoreFilter))
    case .all(let filters):
      return .andFilter(filters.map(\.asFirestoreFilter))
    }
  }
}
