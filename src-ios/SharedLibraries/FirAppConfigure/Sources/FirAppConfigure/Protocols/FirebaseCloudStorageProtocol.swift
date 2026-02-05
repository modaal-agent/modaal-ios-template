// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseStorage

// NB: Intentionally omitted Sourcery annotations.
// TODO: Bring Firestore types under Swift protocols umbrella
public protocol FirebaseCloudStorageProtocol: AnyObject {
  func reference() -> StorageReference
}
