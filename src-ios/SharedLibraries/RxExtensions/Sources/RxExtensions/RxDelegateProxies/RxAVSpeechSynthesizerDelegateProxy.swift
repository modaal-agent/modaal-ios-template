//
//  RxAVSpeechSynthesizerDelegateProxy.swift
//  Pomodoro
//
//  Created by Won on 17/12/2018.
//  Copyright © 2018 won. All rights reserved.

//
//  Added reactive wrappers for `isSpeaking` and `isPaused` properties;
//  added iOS17-specific delegate proxy methods.
//
//  Copyright (c) 2024 FabFun. All rights reserved.

#if os(iOS)

import AVFoundation
import RxCocoa
import RxSwift

extension AVSpeechSynthesizer: HasDelegate {
  public typealias Delegate = AVSpeechSynthesizerDelegate
}

open class RxAVSpeechSynthesizerDelegateProxy: DelegateProxy<AVSpeechSynthesizer, AVSpeechSynthesizerDelegate>, DelegateProxyType, AVSpeechSynthesizerDelegate {

  /// Typed parent object.
  public weak private(set) var speechSynthesizer: AVSpeechSynthesizer?

  /// - parameter speechSynthesizer: Parent object for delegate proxy.
  public init(speechSynthesizer: ParentObject) {
    self.speechSynthesizer = speechSynthesizer
    super.init(parentObject: speechSynthesizer, delegateProxy: RxAVSpeechSynthesizerDelegateProxy.self)
  }

  // Register known implementationss
  public static func registerKnownImplementations() {
    self.register { RxAVSpeechSynthesizerDelegateProxy(speechSynthesizer: $0) }
  }

  private var disposeBag = DisposeBag()

  // `isSpeaking` reactive property storage
  private var _isSpeakingSubject: BehaviorSubject<Bool>?
  fileprivate var isSpeakingSubject: BehaviorSubject<Bool> {
    if let _isSpeakingSubject {
      return _isSpeakingSubject
    }
    let subject = createCompletingOnDeinitSubject(value: speechSynthesizer?.isSpeaking ?? false)
    _isSpeakingSubject = subject
    return subject
  }

  // `isPaused` reactive property storage
  private var _isPausedSubject: BehaviorSubject<Bool>?
  fileprivate var isPausedSubject: BehaviorSubject<Bool> {
    if let _isPausedSubject {
      return _isPausedSubject
    }
    let subject = createCompletingOnDeinitSubject(value: speechSynthesizer?.isPaused ?? false)
    _isPausedSubject = subject
    return subject
  }

  // MARK: - AVSpeechSynthesizerDelegate

  // `didStart` reactive property storage
  private var _didStartSubject: PublishSubject<AVSpeechUtterance>?
  fileprivate var didStartSubject: PublishSubject<AVSpeechUtterance> {
    if let _didStartSubject {
      return _didStartSubject
    }
    let subject: PublishSubject<AVSpeechUtterance> = createCompletingOnDeinitPublishSubject()
    _didStartSubject = subject
    return subject
  }
  public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
    if let speechSynthesizer {
      _isSpeakingSubject?.onNext(speechSynthesizer.isSpeaking)
      _isPausedSubject?.onNext(speechSynthesizer.isPaused)
    }
    _didStartSubject?.onNext(utterance)
    _forwardToDelegate?.speechSynthesizer(synthesizer, didStart: utterance)
  }

  // `didFinish` reactive property storage
  private var _didFinishSubject: PublishSubject<AVSpeechUtterance>?
  fileprivate var didFinishSubject: PublishSubject<AVSpeechUtterance> {
    if let _didFinishSubject {
      return _didFinishSubject
    }
    let subject: PublishSubject<AVSpeechUtterance> = createCompletingOnDeinitPublishSubject()
    _didFinishSubject = subject
    return subject
  }
  public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    if let speechSynthesizer {
      _isSpeakingSubject?.onNext(speechSynthesizer.isSpeaking)
      _isPausedSubject?.onNext(speechSynthesizer.isPaused)
    }
    _didFinishSubject?.onNext(utterance)
    _forwardToDelegate?.speechSynthesizer(synthesizer, didFinish: utterance)
  }

  // `didPause` reactive property storage
  private var _didPauseSubject: PublishSubject<AVSpeechUtterance>?
  fileprivate var didPauseSubject: PublishSubject<AVSpeechUtterance> {
    if let _didPauseSubject {
      return _didPauseSubject
    }
    let subject: PublishSubject<AVSpeechUtterance> = createCompletingOnDeinitPublishSubject()
    _didPauseSubject = subject
    return subject
  }
  public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
    if let speechSynthesizer {
      _isSpeakingSubject?.onNext(speechSynthesizer.isSpeaking)
      _isPausedSubject?.onNext(speechSynthesizer.isPaused)
    }
    _didPauseSubject?.onNext(utterance)
    _forwardToDelegate?.speechSynthesizer(synthesizer, didPause: utterance)
  }

  // `didContinue` reactive property storage
  private var _didContinueSubject: PublishSubject<AVSpeechUtterance>?
  fileprivate var didContinueSubject: PublishSubject<AVSpeechUtterance> {
    if let _didContinueSubject {
      return _didContinueSubject
    }
    let subject: PublishSubject<AVSpeechUtterance> = createCompletingOnDeinitPublishSubject()
    _didContinueSubject = subject
    return subject
  }
  public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
    if let speechSynthesizer {
      _isSpeakingSubject?.onNext(speechSynthesizer.isSpeaking)
      _isPausedSubject?.onNext(speechSynthesizer.isPaused)
    }
    _didContinueSubject?.onNext(utterance)
    _forwardToDelegate?.speechSynthesizer(synthesizer, didContinue: utterance)
  }

  // `didCancel` reactive property storage
  private var _didCancelSubject: PublishSubject<AVSpeechUtterance>?
  fileprivate var didCancelSubject: PublishSubject<AVSpeechUtterance> {
    if let _didCancelSubject {
      return _didCancelSubject
    }
    let subject: PublishSubject<AVSpeechUtterance> = createCompletingOnDeinitPublishSubject()
    _didCancelSubject = subject
    return subject
  }
  public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
    if let speechSynthesizer {
      _isSpeakingSubject?.onNext(speechSynthesizer.isSpeaking)
      _isPausedSubject?.onNext(speechSynthesizer.isPaused)
    }
    _didCancelSubject?.onNext(utterance)
    _forwardToDelegate?.speechSynthesizer(synthesizer, didCancel: utterance)
  }

  // MARK: - Private

  private func createCompletingOnDeinitSubject<T>(value: T) -> BehaviorSubject<T> {
    let subject = BehaviorSubject<T>(value: value)
    disposeBag.insert(Disposables.create {
      subject.onCompleted()
    })
    return subject
  }

  private func createCompletingOnDeinitPublishSubject<T>() -> PublishSubject<T> {
    let subject = PublishSubject<T>()
    disposeBag.insert(Disposables.create {
      subject.onCompleted()
    })
    return subject
  }
}

public extension Reactive where Base: AVSpeechSynthesizer {
  /// Reactive wrapper for `delegate`.
  /// For more information take a look at `DelegateProxyType` protocol documentation.
  var delegate: DelegateProxy<AVSpeechSynthesizer, AVSpeechSynthesizerDelegate> {
    return RxAVSpeechSynthesizerDelegateProxy.proxy(for: base)
  }

  /// Installs delegate as forwarding delegate on `delegate`.
  /// Delegate won't be retained.
  ///
  /// It enables using normal delegate mechanism with reactive delegate mechanism.
  ///
  /// - parameter delegate: Delegate object.
  /// - returns: Disposable object that can be used to unbind the delegate.
  func setDelegate(_ delegate: AVSpeechSynthesizerDelegate) -> Disposable {
    return RxAVSpeechSynthesizerDelegateProxy
      .installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
  }

  /// Reactive wrapper for `isStarted`.
  var isSpeaking: ControlEvent<Bool> {
    let proxy = RxAVSpeechSynthesizerDelegateProxy.proxy(for: base)
    return ControlEvent(events: proxy.isSpeakingSubject)
  }

  /// Reactive wrapper for `isPaused`.
  var isPaused: ControlEvent<Bool> {
    let proxy = RxAVSpeechSynthesizerDelegateProxy.proxy(for: base)
    return ControlEvent(events: proxy.isPausedSubject)
  }

  /**
   Reactive wrapper for `delegate` message `synthesizer:didStart:`
   */
  var started: ControlEvent<AVSpeechUtterance> {
    let proxy = RxAVSpeechSynthesizerDelegateProxy.proxy(for: base)
    return ControlEvent(events: proxy.didStartSubject)
  }

  /**
   Reactive wrapper for `delegate` message `synthesizer:didFinish:`
   */
  var finished: ControlEvent<AVSpeechUtterance> {
    let proxy = RxAVSpeechSynthesizerDelegateProxy.proxy(for: base)
    return ControlEvent(events: proxy.didFinishSubject)
  }

  /**
   Reactive wrapper for `delegate` message `synthesizer:didPause:`
   */
  var paused: ControlEvent<AVSpeechUtterance> {
    let proxy = RxAVSpeechSynthesizerDelegateProxy.proxy(for: base)
    return ControlEvent(events: proxy.didPauseSubject)
  }

  /**
   Reactive wrapper for `delegate` message `synthesizer:didContinue:`
   */
  var continued: ControlEvent<AVSpeechUtterance> {
    let proxy = RxAVSpeechSynthesizerDelegateProxy.proxy(for: base)
    return ControlEvent(events: proxy.didContinueSubject)
  }

  /**
   Reactive wrapper for `delegate` message `synthesizer:didCancel:`
   */
  var canceled: ControlEvent<AVSpeechUtterance> {
    let proxy = RxAVSpeechSynthesizerDelegateProxy.proxy(for: base)
    return ControlEvent(events: proxy.didCancelSubject)
  }

  /**
   Reactive wrapper for `delegate` message `synthesizer:willSpeakRangeOfSpeechString:utterance:`
   */
  var willSpeakRange: ControlEvent<(characterRange: NSRange, utterance: AVSpeechUtterance)> {
    let source = delegate
      .methodInvoked(#selector(AVSpeechSynthesizerDelegate.speechSynthesizer(_:willSpeakRangeOfSpeechString:utterance:)))
      .map { (characterRange: try castOrThrow(NSRange.self, $0[1]), utterance: try castOrThrow(AVSpeechUtterance.self, $0[2])) }
    return ControlEvent(events: source)
  }

  /**
   Reactive wrapper for `delegate` message `synthesizer:willSpeak:utterance:`
   */
  @available(iOS 17.0, *)
  var willSpeakMarker: ControlEvent<(marker: AVSpeechSynthesisMarker, utterance: AVSpeechUtterance)> {
    let source = delegate
      .methodInvoked(#selector(AVSpeechSynthesizerDelegate.speechSynthesizer(_:willSpeak:utterance:)))
      .map { (marker: try castOrThrow(AVSpeechSynthesisMarker.self, $0[1]), utterance: try castOrThrow(AVSpeechUtterance.self, $0[2])) }
    return ControlEvent(events: source)
  }
}

private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
  guard let returnValue = object as? T else {
    throw RxCocoaError.castingError(object: object, targetType: resultType)
  }

  return returnValue
}

#endif
