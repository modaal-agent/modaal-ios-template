//(c) Copyright Modaal.dev 2026

import Foundation
import FirebaseStorage
import RxSwift

public final class CloudStorageReference: CloudStorageReferencing {

  private let reference: StorageReference

  init(reference: StorageReference) {
    self.reference = reference
  }

  // MARK: - CloudStorageReferencing

  public var fullPath: String { reference.fullPath }
  public var name: String { reference.name }
  public var bucket: String { reference.bucket }

  public func child(path: String) -> CloudStorageReferencing {
    let child = reference.child(path)
    return CloudStorageReference(reference: child)
  }

  public func parent() -> CloudStorageReferencing? {
    guard let parent = reference.parent() else {
      return nil
    }
    return CloudStorageReference(reference: parent)
  }

  public func root() -> CloudStorageReferencing {
    let root = reference.root()
    return CloudStorageReference(reference: root)
  }

  // MARK: - CloudCollectionStoring

  public func listAll() -> Single<CloudStorageListResultProtocol> {
    return Single.create { observer in
      let disposable = BooleanDisposable()
      self.reference.listAll { result in
        guard !disposable.isDisposed else { return }
        observer(result.map { CloudStorageListResult(result: $0) })
      }
      return disposable
    }

  }

  // MARK: - CloudFileStoring

  public func getData(maxSize: Int64) -> Single<Data> {
    return Single.create { observer in
      let task = self.reference.getData(maxSize: maxSize) { result in
        observer(result)
      }
      return Disposables.create {
        task.cancel()
      }
    }
  }

  public func downloadToFile(localURL: URL) -> Single<URL> {
    return Single.create { observer in
      let task = self.reference.write(toFile: localURL) { result in
        observer(result)
      }
      return Disposables.create {
        task.cancel()
      }
    }
  }

  public func getDownloadURL() -> Single<URL> {
    return Single.create { observer in
      let disposable = BooleanDisposable()
      self.reference.downloadURL() { result in
        guard !disposable.isDisposed else { return }
        observer(result)
      }
      return disposable
    }
  }

  public func putData(_ data: Data) -> Single<Void> {
    return Single.create { observer in
      let task = self.reference.putData(data) { result in
        observer(result.map { _ in () })
      }
      return Disposables.create {
        task.cancel()
      }
    }
  }

  public func uploadFromFile(localURL: URL) -> Single<Void> {
    return Single.create { observer in
      let task = self.reference.putFile(from: localURL) { result in
        observer(result.map { _ in () })
      }
      return Disposables.create {
        task.cancel()
      }
    }
  }

  public func delete() -> Single<Void> {
    return Single.create { observer in
      let task = self.reference.delete { error in
        if let error = error {
          observer(.failure(error))
        } else {
          observer(.success(()))
        }
      }
      return Disposables.create()
    }
  }
}
