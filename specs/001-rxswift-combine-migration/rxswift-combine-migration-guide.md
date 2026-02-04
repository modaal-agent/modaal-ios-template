# RxSwift to Swift.Combine Migration Guide

## Executive Summary

This document describes the migration of the modaal-ios-template codebase from RxSwift to Swift's native Combine framework. The migration leverages the CombineRIBs library which provides Combine-based implementations of Uber's RIBs architecture patterns.

**Migration Completed:** 2026-02-05

## Pattern Mapping Reference

### Type Mappings

| RxSwift                          | Combine                                              | Notes                                                                   |
| -------------------------------- | ---------------------------------------------------- | ----------------------------------------------------------------------- |
| `Observable<T>`                  | `AnyPublisher<T, Error>` or `AnyPublisher<T, Never>` | Use `Never` for non-failing streams                                     |
| `Single<T>`                      | `AnyPublisher<T, Error>`                             | Implement with `Future`                                                 |
| `BehaviorRelay<T>`               | `CurrentValueSubject<T, Never>`                      | Direct equivalent                                                       |
| `PublishSubject<T>`              | `PassthroughSubject<T, Never>`                       | Direct equivalent                                                       |
| `ReplayRelay<T>` (bufferSize: 1) | `CurrentValueSubject<T, Never>(defaultValue)`        | Initialize with default, use `.filter { condition }` to emit when ready |
| `AnyObserver<T>`                 | `AnyActionHandler<T>`                                | Use `SharedUtility.AnyActionHandler` to avoid retain cycles             |
| `Binder<T>`                      | Direct property assignment or closure                | Use ViewState for UI                                                    |
| `DisposeBag`                     | `Set<AnyCancellable>`                                | Auto-cancel on dealloc                                                  |
| `CompositeDisposable`            | `Set<AnyCancellable>`                                |                                                                         |
| `BooleanDisposable`              | Closure in `handleEvents(receiveCancel:)`            |                                                                         |

### Operator Mappings

| RxSwift                     | Combine                               |
| --------------------------- | ------------------------------------- |
| `.map { }`                  | `.map { }`                            |
| `.flatMap { }`              | `.flatMap { }`                        |
| `.filter { }`               | `.filter { }`                         |
| `.compactMap { }`           | `.compactMap { }`                     |
| `.combineLatest(a, b)`      | `Publishers.CombineLatest(a, b)`      |
| `.take(1)`                  | `.first()`                            |
| `.timeout(_, scheduler:)`   | `.timeout(_, scheduler:)`             |
| `.catchAndReturn(value)`    | `.replaceError(with: value)`          |
| `.observe(on: scheduler)`   | `.receive(on: scheduler)`             |
| `.subscribe(on: scheduler)` | `.subscribe(on: scheduler)`           |
| `.delay(_, scheduler:)`     | `.delay(for:, scheduler:)`            |
| `.startWith(value)`         | `.prepend(value)`                     |
| `.bind(to: subject)`        | `.sink { subject.send($0) }`          |
| `.subscribe(onNext:)`       | `.sink { }`                           |
| `.asObservable()`           | `.eraseToAnyPublisher()`              |
| `Observable.just(x)`        | `Just(x)`                             |
| `Observable.empty()`        | `Empty()`                             |
| `Observable.create { }`     | `PassthroughSubject` + `handleEvents` |
| `Single.create { }`         | `Future { promise in }`               |
| `.onNext(value)`            | `.send(value)`                        |
| `.accept(value)`            | `.send(value)`                        |

### Scheduler Mappings

| RxSwift                            | Combine                 |
| ---------------------------------- | ----------------------- |
| `MainScheduler.instance`           | `DispatchQueue.main`    |
| `MainScheduler.asyncInstance`      | `DispatchQueue.main`    |
| `ConcurrentMainScheduler.instance` | `DispatchQueue.main`    |
| `SerialDispatchQueueScheduler`     | `DispatchQueue(label:)` |

### Lifecycle Mappings (CombineRIBs)

| RxSwift                             | Combine                            |
| ----------------------------------- | ---------------------------------- |
| `.disposeOnDeactivate(interactor:)` | `.cancelOnDeactivate(interactor:)` |
| `.disposeOnStop(self)`              | `.cancelOnStop(self)`              |

## Code Transformation Examples

### 1. Protocol with Reactive Stream

**Before (RxSwift):**

```swift
protocol ResourcesLoadingWorking: Working {
  var resourcesReady: Observable<Bool> { get }
}
```

**After (Combine):**

```swift
protocol ResourcesLoadingWorking: Working {
  var resourcesReady: AnyPublisher<Bool, Never> { get }
}
```

### 2. ReplayRelay to CurrentValueSubject

**Before (RxSwift):**

```swift
private let resourcesReadySubject = ReplayRelay<Bool>.create(bufferSize: 1)

var resourcesReady: Observable<Bool> {
  return resourcesReadySubject.asObservable()
}
```

**After (Combine):**

```swift
private let resourcesReadySubject = CurrentValueSubject<Bool, Never>(false)

var resourcesReady: AnyPublisher<Bool, Never> {
  return resourcesReadySubject
    .filter { $0 }  // Only emit when value becomes true
    .eraseToAnyPublisher()
}
```

**Note:** Initialize with a sensible default value (`false`) rather than using an optional wrapper. Use `.filter { condition }` to control when values are emitted to subscribers.

### 3. Worker Subscription with Lifecycle

**Before (RxSwift):**

```swift
override func didStart(_ interactorScope: any InteractorScope) {
  super.didStart(interactorScope)

  Observable
    .just(true).delay(.seconds(1), scheduler: MainScheduler.asyncInstance)
    .bind(to: resourcesReadySubject)
    .disposeOnStop(self)
}
```

**After (Combine):**

```swift
override func didStart(_ interactorScope: any InteractorScope) {
  super.didStart(interactorScope)

  Just(true)
    .delay(for: .seconds(1), scheduler: DispatchQueue.main)
    .sink { [weak self] value in
      self?.resourcesReadySubject.send(value)
    }
    .cancelOnStop(self)
}
```

### 4. Complex Interactor Chain

**Before (RxSwift):**

```swift
Observable
  .combineLatest(
    resourcesLoadingWorker.resourcesReady,
    splashDidCompleteRelay,
  ) { $0 && $1 }
  .take(1)
  .timeout(.seconds(2), scheduler: MainScheduler.instance)
  .catchAndReturn(true)
  .observe(on: MainScheduler.instance)
  .subscribe(onNext: { [router] _ in
    router?.routeToMain()
  })
  .disposeOnDeactivate(interactor: self)
```

**After (Combine):**

```swift
Publishers.CombineLatest(
  resourcesLoadingWorker.resourcesReady,
  splashDidCompleteSubject.filter { $0 }  // Filter on value becoming true
)
.map { $0 && $1 }
.first()
.timeout(.seconds(2), scheduler: DispatchQueue.main)
.replaceError(with: true)
.receive(on: DispatchQueue.main)
.sink { [weak router] _ in
  router?.routeToMain()
}
.cancelOnDeactivate(interactor: self)
```

### 5. Firebase Firestore Listener

**Before (RxSwift):**

```swift
func observe<T>(as type: T.Type) -> Observable<T?> where T: Codable {
  return Observable.create { observer in
    let disposable = BooleanDisposable()
    let listener = self.document.reference.addSnapshotListener { snapshot, error in
      guard !disposable.isDisposed else { return }

      if let error {
        observer.onError(error)
        return
      }

      guard let snapshot, snapshot.exists else {
        observer.onNext(nil)
        return
      }

      do {
        let data = try snapshot.data(as: T.self)
        observer.onNext(data)
      } catch let e {
        observer.onError(e)
      }
    }
    return Disposables.create {
      listener.remove()
      disposable.dispose()
    }
  }
}
```

**After (Combine):**

```swift
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
```

### 6. Firebase Storage One-Shot Operation

**Before (RxSwift):**

```swift
func getData(maxSize: Int64) -> Single<Data> {
  return Single.create { observer in
    let task = self.reference.getData(maxSize: maxSize) { result in
      observer(result)
    }
    return Disposables.create {
      task.cancel()
    }
  }
}
```

**After (Combine):**

```swift
func getData(maxSize: Int64) -> AnyPublisher<Data, Error> {
  var task: StorageDownloadTask?

  return Deferred {
    Future { promise in
      task = self.reference.getData(maxSize: maxSize) { result in
        promise(result)
      }
    }
  }
  .handleEvents(receiveCancel: {
    task?.cancel()
  })
  .eraseToAnyPublisher()
}
```

### 7. AnyObserver to AnyActionHandler (UI Events)

**Before (RxSwift):**

```swift
protocol SplashPresentable: Presentable {
  var splashDidFinish: AnyObserver<Void>? { get set }
}

// In SwiftUI View
var onFinishHandler: AnyObserver<Void>?

.onAppear {
  DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    onFinishHandler?.onNext(())
  }
}
```

**After (Combine with AnyActionHandler):**

```swift
import SharedUtility

protocol SplashPresentable: Presentable {
  var splashDidFinish: AnyActionHandler<Void>? { get set }
}

// In Interactor - AnyActionHandler automatically captures self weakly
presenter.splashDidFinish = AnyActionHandler(self) { interactor in
  interactor.listener?.splashDidComplete()
}

// In SwiftUI View
private var onFinishHandler: AnyActionHandler<Void>?

.onAppear {
  DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    onFinishHandler?.invoke()
  }
}
```

**Note:** Always use `AnyActionHandler` instead of raw closures (`(() -> Void)?`) for UI events in RIBs. Raw closures are prone to strong reference cycles when capturing `self`. `AnyActionHandler` from `SharedUtility` automatically captures the owner weakly, preventing memory leaks.

## Common Pitfalls and Solutions

### 1. ReplayRelay with bufferSize: 1

**Problem:** `CurrentValueSubject` requires an initial value, but `ReplayRelay` doesn't emit until a value is accepted.

**Solution:** Initialize with a sensible default value and use `.filter` to control emissions:

```swift
private let subject = CurrentValueSubject<Bool, Never>(false)

var stream: AnyPublisher<Bool, Never> {
  subject.filter { $0 }.eraseToAnyPublisher()  // Only emit when true
}
```

**Why not use `CurrentValueSubject<T?, Never>(nil)`?** While the optional pattern works, it adds unnecessary complexity:

- Extra optional wrapper type
- Extra `.compactMap { $0 }` in every consumer
- Cognitive overhead understanding why the value is optional

For boolean flags, initialize with `false` and filter on `true`. For other types, choose a meaningful default or consider if the stream really needs replay behavior.

### 2. Firebase Listener Cleanup

**Problem:** Need to ensure Firebase listeners are removed when the subscription is cancelled.

**Solution:** Use `handleEvents(receiveCancel:)`:

```swift
return subject
  .handleEvents(receiveCancel: {
    listener.remove()
  })
  .eraseToAnyPublisher()
```

### 3. Task Cancellation for Storage Operations

**Problem:** Firebase Storage tasks need to be cancelled when the publisher is cancelled.

**Solution:** Use `Deferred` + `Future` + `handleEvents`:

```swift
var task: StorageDownloadTask?

return Deferred {
  Future { promise in
    task = reference.getData(maxSize: maxSize) { result in
      promise(result)
    }
  }
}
.handleEvents(receiveCancel: {
  task?.cancel()
})
.eraseToAnyPublisher()
```

### 4. Scheduler Type in Initializers

**Problem:** `SchedulerType` parameter type doesn't exist in Combine.

**Solution:** Use `DispatchQueue` directly:

```swift
// Before
init(scheduler: SchedulerType = MainScheduler.instance)

// After
init(scheduler: DispatchQueue = .main)
```

### 5. UI Event Handlers and Retain Cycles

**Problem:** Raw closures (`(() -> Void)?`) used for UI events can create strong reference cycles when capturing `self` in Presenters.

**Solution:** Use `AnyActionHandler` from `SharedUtility` instead of raw closures:

```swift
import SharedUtility

// ❌ WRONG - raw closure can capture self strongly
protocol ExamplePresentable: Presentable {
  var buttonTapped: (() -> Void)? { get set }
}

// In Interactor - prone to retain cycle if not careful
presenter.buttonTapped = { [weak self] in
  self?.handleButtonTap()
}

// ✅ CORRECT - AnyActionHandler automatically captures owner weakly
protocol ExamplePresentable: Presentable {
  var buttonTapped: AnyActionHandler<Void>? { get set }
}

// In Interactor - safe, automatic weak capture
presenter.buttonTapped = AnyActionHandler(self) { interactor in
  interactor.handleButtonTap()
}
```

**Key benefits of `AnyActionHandler`:**

- Automatically captures the owner weakly (first parameter)
- Provides a strongly-typed reference in the closure body
- Prevents memory leaks without requiring manual `[weak self]`
- Type-safe with generic parameter for payload (`AnyActionHandler<UUID>`, etc.)

## Files Modified in This Migration

### Shared Libraries

| Module       | Files Changed                                                                                                                              |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Diagnostics  | `Diagnostics.swift`, `DiagnosticsWorker.swift`                                                                                             |
| RxExtensions | Removed Rx files, kept Combine extensions                                                                                                  |
| Storage      | `Storing.swift`, `DocumentStoring.swift`, `CollectionStoring.swift`, `DocumentStore.swift`, `CollectionStore.swift`, `StorageWorker.swift` |
| CloudStorage | `CloudFileStoring.swift`, `CloudCollectionStoring.swift`, `CloudStorageReference.swift`                                                    |

### Application Libraries

| Module    | Files Changed                                                                                                                                  |
| --------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| MyAppMain | `ResourcesLoadingWorker.swift`, `RootInteractor.swift`, `SplashInteractor.swift`, `SplashView.swift`, `MainInteractor.swift`, `MainView.swift` |

### Knowledge Base

| File                | Changes                                   |
| ------------------- | ----------------------------------------- |
| `ios-RIBs.md`       | Updated all RxSwift references to Combine |
| `ios-RIBs-short.md` | Updated lifecycle and pattern references  |

## Testing Checklist

- [ ] App launches successfully
- [ ] Splash screen displays and transitions to main
- [ ] Resources loading with timeout fallback works
- [ ] Firebase Firestore document observation works
- [ ] Firebase Storage operations work
- [ ] No memory leaks (verify listener cleanup)
- [ ] Error handling propagates correctly

## References

- [CombineRIBs](https://github.com/modaal-agent/CombineRIBs) - Combine-based RIBs implementation
- [Apple Combine Documentation](https://developer.apple.com/documentation/combine)
- [Swift Evolution: SE-0292 Combine](https://github.com/apple/swift-evolution/blob/main/proposals/0292-package-registry-service.md)
