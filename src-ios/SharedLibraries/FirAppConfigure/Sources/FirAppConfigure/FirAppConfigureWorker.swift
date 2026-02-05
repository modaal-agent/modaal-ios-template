// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation
import UIKit
import CombineRIBs
import FirebaseCore
import FirebaseAnalytics
import FirebaseAuth
import FirebaseCrashlytics
import FirebaseFirestore
import FirebaseStorage

/// sourcery: CreateMock
public protocol FirAppConfigureWorking: Working, FirAppConfiguring {
}

public final class FirAppConfigureWorker: Worker, FirAppConfigureWorking {
  let options: FirAppOptions?

  public init(firebaseInfoPlistFilePath: String?) {
    if let firebaseInfoPlistFilePath,
       FileManager.default.fileExists(atPath: firebaseInfoPlistFilePath),
       let options = FirebaseOptions(contentsOfFile: firebaseInfoPlistFilePath)
    {
      FirebaseApp.configure(options: options)
      self.options = FirAppOptions(
        clientID: options.clientID ?? ""
      )
    } else {
      self.options = nil
    }

    super.init()
  }

  override public func didStart(_ interactorScope: InteractorScope) {
    super.didStart(interactorScope)
  }

  // MARK: - FirAppConfiguring

  public func firAppOptions() -> FirAppOptions? {
    return options
  }

  public func analytics() -> FirebaseAnalyticsProtocol? {
    guard let _ = options else { return nil }
    return self
  }

  public func auth() -> FirebaseAuthProtocol? {
    guard let _ = options else { return nil }
    return FirebaseAuthWrapper(auth: Auth.auth())
  }

  public func crashlytics() -> FirebaseCrashlyticsProtocol? {
    guard let _ = options else { return nil }
    return Crashlytics.crashlytics()
  }

  public func firestore() -> FirebaseFirestoreProtocol? {
    guard let _ = options else { return nil }
    return Firestore.firestore()
  }

  public func cloudStorage() -> FirebaseCloudStorageProtocol? {
    guard let _ = options else { return nil }
    return Storage.storage()
  }
}

extension FirAppConfigureWorker: FirebaseAnalyticsProtocol {
  public func logEvent(name: String, parameters: [String: Any]?) {
    guard let _ = options else { return }
    Analytics.logEvent(name, parameters: parameters)
  }

  public func setUserProperty(_ value: String?, forName name: String) {
    guard let _ = options else { return }
    Analytics.setUserProperty(value, forName: name)
  }

  public func setUserID(_ userID: String?) {
    guard let _ = options else { return }
    Analytics.setUserID(userID)
  }
}
