//
//  RxAVAudioPlayerDelegateProxy.swift
//  Copyright (c) 2024 FabFun. All rights reserved.
//

#if os(iOS)

import AVFoundation
import RxCocoa
import RxSwift

extension AVAudioPlayer: HasDelegate {
  public typealias Delegate = AVAudioPlayerDelegate
}

open class RxAVAudioPlayerDelegateProxy: DelegateProxy<AVAudioPlayer, AVAudioPlayerDelegate>, DelegateProxyType, AVAudioPlayerDelegate {

  /// Typed parent object.
  public weak private(set) var audioPlayer: AVAudioPlayer?

  /// - parameter speechSynthesizer: Parent object for delegate proxy.
  public init(audioPlayer: ParentObject) {
    self.audioPlayer = audioPlayer
    super.init(parentObject: audioPlayer, delegateProxy: RxAVAudioPlayerDelegateProxy.self)
  }

  // Register known implementationss
  public static func registerKnownImplementations() {
    self.register { RxAVAudioPlayerDelegateProxy(audioPlayer: $0) }
  }

  private var disposeBag = DisposeBag()

  // MARK: - AVaudioPlayerDelegate

  // `didFinish` reactive property storage
  private var _didFinishSubject: PublishSubject<Bool>?
  fileprivate var didFinishSubject: PublishSubject<Bool> {
    if let _didFinishSubject {
      return _didFinishSubject
    }
    let subject: PublishSubject<Bool> = createCompletingOnDeinitPublishSubject()
    _didFinishSubject = subject
    return subject
  }
  public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    _didFinishSubject?.onNext(flag)
    _forwardToDelegate?.audioPlayerDidFinishPlaying(player, successfully: flag)
  }

  // MARK: - Private

  private func createCompletingOnDeinitPublishSubject<T>() -> PublishSubject<T> {
    let subject = PublishSubject<T>()
    disposeBag.insert(Disposables.create {
      subject.onCompleted()
    })
    return subject
  }
}

public extension Reactive where Base: AVAudioPlayer {
  /// Reactive wrapper for `delegate`.
  /// For more information take a look at `DelegateProxyType` protocol documentation.
  var delegate: DelegateProxy<AVAudioPlayer, AVAudioPlayerDelegate> {
    return RxAVAudioPlayerDelegateProxy.proxy(for: base)
  }

  /// Installs delegate as forwarding delegate on `delegate`.
  /// Delegate won't be retained.
  ///
  /// It enables using normal delegate mechanism with reactive delegate mechanism.
  ///
  /// - parameter delegate: Delegate object.
  /// - returns: Disposable object that can be used to unbind the delegate.
  func setDelegate(_ delegate: AVAudioPlayerDelegate) -> Disposable {
    return RxAVAudioPlayerDelegateProxy
      .installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
  }

  /**
   Reactive wrapper for `delegate` message `audioPlayerDidFinishPlaying(_:successfully:)`
   */
  var finished: ControlEvent<Bool> {
    let proxy = RxAVAudioPlayerDelegateProxy.proxy(for: base)
    return ControlEvent(events: proxy.didFinishSubject)
  }
}

#endif
