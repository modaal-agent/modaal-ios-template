// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

public struct FirAppOptions {
  public let clientID: String

  public init(clientID: String) {
    self.clientID = clientID
  }
}

/// sourcery: CreateMock
public protocol FirAppConfiguring {
  func firAppOptions() -> FirAppOptions?
  func analytics() -> FirebaseAnalyticsProtocol?
  func auth() -> FirebaseAuthProtocol?
  func crashlytics() -> FirebaseCrashlyticsProtocol?
  func firestore() -> FirebaseFirestoreProtocol?
  func cloudStorage() -> FirebaseCloudStorageProtocol?
}
