# RxSwift to Swift.Combine Migration Plan

## Overview

Migrate the modaal-ios-template codebase from RxSwift to Swift.Combine. CombineRIBs is already integrated, providing Combine-based RIBs infrastructure.

**Scope:** 28 files with RxSwift usage, 3 knowledge base files to update

---

## 1. Pattern Mapping Reference

### Type Mappings

| RxSwift                          | Combine                                              | Notes                                                 |
| -------------------------------- | ---------------------------------------------------- | ----------------------------------------------------- |
| `Observable<T>`                  | `AnyPublisher<T, Error>` or `AnyPublisher<T, Never>` | Use `Never` for non-failing streams                   |
| `Single<T>`                      | `AnyPublisher<T, Error>`                             | Implement with `Future`                               |
| `BehaviorRelay<T>`               | `CurrentValueSubject<T, Never>`                      | Direct equivalent                                     |
| `PublishSubject<T>`              | `PassthroughSubject<T, Never>`                       | Direct equivalent                                     |
| `ReplayRelay<T>` (bufferSize: 1) | `CurrentValueSubject<T?, Never>(nil)`                | Use optional + `.compactMap { $0 }` (chosen approach) |
| `AnyObserver<T>`                 | `((T) -> Void)` closure                              | Or `PassthroughSubject`                               |
| `DisposeBag`                     | `Set<AnyCancellable>`                                | Auto-cancel on dealloc                                |
| `BooleanDisposable`              | Closure in `handleEvents(receiveCancel:)`            |                                                       |

### Operator Mappings

| RxSwift                   | Combine                               |
| ------------------------- | ------------------------------------- |
| `.map { }`                | `.map { }`                            |
| `.flatMap { }`            | `.flatMap { }`                        |
| `.filter { }`             | `.filter { }`                         |
| `.combineLatest(a, b)`    | `Publishers.CombineLatest(a, b)`      |
| `.take(1)`                | `.first()`                            |
| `.timeout(_, scheduler:)` | `.timeout(_, scheduler:)`             |
| `.catchAndReturn(value)`  | `.replaceError(with: value)`          |
| `.observe(on: scheduler)` | `.receive(on: scheduler)`             |
| `.delay(_, scheduler:)`   | `.delay(for:, scheduler:)`            |
| `.startWith(value)`       | `.prepend(value)`                     |
| `.bind(to: relay)`        | `.sink { subject.send($0) }`          |
| `.asObservable()`         | `.eraseToAnyPublisher()`              |
| `Observable.just(x)`      | `Just(x)`                             |
| `Observable.create { }`   | `PassthroughSubject` + `handleEvents` |
| `Single.create { }`       | `Future { promise in }`               |

### Scheduler Mappings

| RxSwift                            | Combine              |
| ---------------------------------- | -------------------- |
| `MainScheduler.instance`           | `DispatchQueue.main` |
| `MainScheduler.asyncInstance`      | `DispatchQueue.main` |
| `ConcurrentMainScheduler.instance` | `DispatchQueue.main` |

### Lifecycle Mappings (CombineRIBs)

| RxSwift                             | Combine                            |
| ----------------------------------- | ---------------------------------- |
| `.disposeOnDeactivate(interactor:)` | `.cancelOnDeactivate(interactor:)` |
| `.disposeOnStop(self)`              | `.cancelOnStop(self)`              |

---

## 2. Migration Phases

### Phase 1: Shared Libraries - Leaf Modules

**1.1 Diagnostics Module** (2 files)

- `src-ios/SharedLibraries/Diagnostics/Sources/Diagnostics/Protocols/Diagnostics.swift`
  - `logs: Observable<...>` → `AnyPublisher<..., Never>`
- `src-ios/SharedLibraries/Diagnostics/Sources/Diagnostics/DiagnosticsWorker.swift`
  - `PublishSubject` → `PassthroughSubject`
  - Remove `import RxSwift`

**1.2 RxExtensions Cleanup** (repurpose to CombineExtensions)

- Keep Combine extensions:
  - `Combine/CurrentValueSubject+updateValue.swift`
  - `Combine/Publisher+skipWhile.swift`
- Remove Rx-specific files:
  - `Rx/RxPublished.swift`
  - `Rx/ObservableType+ZipWithPrevious.swift`
  - `Rx/PrimitiveSequenceType+Activity.swift`
  - `Rx/CompositeDisposable+disposeIn.swift`
  - `Rx/UIScreen+RxUserInterfaceStyle.swift`
  - `Functional/Subject+UpdateValue.swift` (RxSwift version)
- Remove bridge adapters (no longer needed):
  - `Rx+Combine/Cancellable+Disposable.swift`
  - `Rx+Combine/Publisher+BindTo.swift`
  - `Rx+Combine/Subject+AnyObserver.swift`
- **Note:** Keep module name as RxExtensions for now (can rename to CombineExtensions later)

### Phase 2: Storage Modules

**2.1 Storage Module** (6 files)

Protocols (API changes):

- `src-ios/SharedLibraries/Storage/Sources/Storage/Protocols/Storing.swift`
- `src-ios/SharedLibraries/Storage/Sources/Storage/Protocols/DocumentStoring.swift`
  ```swift
  // Before: func observe<T>(as:) -> Observable<T?>
  // After:  func observe<T>(as:) -> AnyPublisher<T?, Error>
  // Before: func setData(_:mergeOption:) -> Single<Void>
  // After:  func setData(_:mergeOption:) -> AnyPublisher<Void, Error>
  ```
- `src-ios/SharedLibraries/Storage/Sources/Storage/Protocols/CollectionStoring.swift`
  ```swift
  // Before: func get() -> Single<[String: DocumentStoring]>
  // After:  func get() -> AnyPublisher<[String: DocumentStoring], Error>
  // Before: func list() -> Observable<[String: DocumentStoring]>
  // After:  func list() -> AnyPublisher<[String: DocumentStoring], Error>
  ```

Implementations:

- `src-ios/SharedLibraries/Storage/Sources/Storage/DocumentStore.swift`
  - `Observable.create` → `PassthroughSubject` + `handleEvents(receiveCancel:)`
  - `Single.create` → `Future`
  - `BooleanDisposable` → closure capture pattern
- `src-ios/SharedLibraries/Storage/Sources/Storage/CollectionStore.swift`
  - Same patterns as DocumentStore
- `src-ios/SharedLibraries/Storage/Sources/Storage/StorageWorker.swift`
  - Update imports only (already uses CombineRIBs Worker)

**2.2 CloudStorage Module** (7 files)

Protocols:

- `src-ios/SharedLibraries/CloudStorage/Sources/CloudStorage/Protocols/CloudFileStoring.swift`
- `src-ios/SharedLibraries/CloudStorage/Sources/CloudStorage/Protocols/CloudCollectionStoring.swift`
  ```swift
  // Before: func getData(maxSize:) -> Single<Data>
  // After:  func getData(maxSize:) -> AnyPublisher<Data, Error>
  ```

Implementation:

- `src-ios/SharedLibraries/CloudStorage/Sources/CloudStorage/Types/CloudStorageReference.swift`
  - All `Single.create` → `Future`
  - Task cancellation via `handleEvents(receiveCancel:)`

### Phase 3: Application Modules - RIBs & Workers

**3.1 Workers**

- `src-ios/Libraries/MyAppMain/Sources/MyAppMain/Workers/ResourcesLoadingWorker.swift`

  ```swift
  // Before: var resourcesReady: Observable<Bool>
  // After:  var resourcesReady: AnyPublisher<Bool, Never>

  // Before: ReplayRelay<Bool>.create(bufferSize: 1)
  // After:  CurrentValueSubject<Bool?, Never>(nil)

  // Before: .bind(to: relay).disposeOnStop(self)
  // After:  .sink { subject.send($0) }.cancelOnStop(self)
  ```

**3.2 Splash RIB**

- `src-ios/Libraries/MyAppMain/Sources/MyAppMain/RIBs/Splash/SplashInteractor.swift`
  ```swift
  // Before: var splashDidFinish: AnyObserver<Void>?
  // After:  var splashDidFinish: (() -> Void)?
  ```
- `src-ios/Libraries/MyAppMain/Sources/MyAppMain/RIBs/Splash/SplashView.swift`
  - `AnyObserver<Void>` → closure `(() -> Void)?`

**3.3 Root RIB**

- `src-ios/Libraries/MyAppMain/Sources/MyAppMain/RIBs/Root/RootInteractor.swift`

  ```swift
  // Before:
  Observable.combineLatest(resourcesReady, splashDidCompleteRelay) { $0 && $1 }
    .take(1)
    .timeout(.seconds(2), scheduler: MainScheduler.instance)
    .catchAndReturn(true)
    .observe(on: MainScheduler.instance)
    .subscribe(onNext: { router?.routeToMain() })
    .disposeOnDeactivate(interactor: self)

  // After:
  Publishers.CombineLatest(resourcesReady, splashDidCompleteSubject.compactMap { $0 })
    .map { $0 && $1 }
    .first()
    .timeout(.seconds(2), scheduler: DispatchQueue.main)
    .replaceError(with: true)
    .receive(on: DispatchQueue.main)
    .sink { [weak router] _ in router?.routeToMain() }
    .cancelOnDeactivate(interactor: self)
  ```

**3.4 Main RIB**

- `src-ios/Libraries/MyAppMain/Sources/MyAppMain/RIBs/Main/MainInteractor.swift`
- `src-ios/Libraries/MyAppMain/Sources/MyAppMain/RIBs/Main/MainView.swift`
  - Remove RxSwift/RxRelay imports

### Phase 4: Package.swift Updates

Remove RxSwift dependencies from:

- `src-ios/SharedLibraries/Storage/Package.swift`
- `src-ios/SharedLibraries/CloudStorage/Package.swift`
- `src-ios/SharedLibraries/Diagnostics/Package.swift`
- `src-ios/SharedLibraries/RxExtensions/Package.swift` (rename to CombineExtensions)
- `src-ios/Libraries/MyAppMain/Package.swift`

### Phase 5: Knowledge Base Updates

**5.1 ios-RIBs.md** (major update)

- Replace all RxSwift references with Combine equivalents
- Update code examples:
  - `Observable<T>` → `AnyPublisher<T, Never>`
  - `Binder` → closure or sink pattern
  - `.disposeOnDeactivate` → `.cancelOnDeactivate`
  - `DisposeBag` → `Set<AnyCancellable>`

**5.2 ios-RIBs-short.md** (update)

- Update abbreviated rules for Combine
- Fix lifecycle patterns

**5.3 ios-design-system.md** (minimal changes)

- Already uses `ObservableObject`/`@Published` for SwiftUI

### Phase 6: Create Migration Guide

Create `specs/001-rxswift-combine-migration/rxswift-combine-migration-guide.md` containing:

1. Executive summary
2. Complete pattern mapping tables
3. Code transformation examples
4. Common pitfalls and solutions
5. Testing checklist

---

## 3. Critical Files Summary

| File                                             | Key Changes                             |
| ------------------------------------------------ | --------------------------------------- |
| `Storage/DocumentStore.swift`                    | `Observable.create` → Publisher pattern |
| `Storage/CollectionStore.swift`                  | `Observable.create` → Publisher pattern |
| `Storage/Protocols/DocumentStoring.swift`        | Protocol return types                   |
| `CloudStorage/CloudStorageReference.swift`       | `Single.create` → `Future`              |
| `MyAppMain/RIBs/Root/RootInteractor.swift`       | Complex Rx chain → Combine chain        |
| `MyAppMain/Workers/ResourcesLoadingWorker.swift` | `ReplayRelay` → `CurrentValueSubject`   |
| `resources/knowledge/ios-RIBs.md`                | Full documentation update               |

---

## 4. Verification Plan

### Build Verification

```bash
# Build each module after migration
cd src-ios && swift build
```

### Test Verification

```bash
# Run existing tests
./scripts/test_ios.sh
```

### Manual Testing Checklist

- [ ] App launches successfully
- [ ] Splash screen displays and transitions to main
- [ ] Resources loading with timeout fallback works
- [ ] Firebase Firestore document observation works
- [ ] Firebase Storage operations work
- [ ] No memory leaks (verify listener cleanup)
- [ ] Error handling propagates correctly

---

## 5. Estimated File Count

| Category                       | Files  |
| ------------------------------ | ------ |
| Protocol files to update       | 5      |
| Implementation files to update | 10     |
| RIB files to update            | 8      |
| Package.swift files            | 5      |
| Knowledge base files           | 3      |
| New migration guide            | 1      |
| **Total**                      | **32** |
