// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation
import FirebaseFirestore

// NB: Intentionally omitted Sourcery annotations.
// TODO: Bring Firestore types under Swift protocols umbrella (eg CollectionReference etc)
public protocol FirebaseFirestoreProtocol: AnyObject {

  // MARK: - Collections & Documents
  func collection(_ collectionPath: String) -> CollectionReference
  func document(_ documentPath: String) -> DocumentReference
}
