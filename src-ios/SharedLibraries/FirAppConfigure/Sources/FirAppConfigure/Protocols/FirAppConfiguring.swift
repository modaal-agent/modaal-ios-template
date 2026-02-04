// (c) Copyright Modaal.dev 2026

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
