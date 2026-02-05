# RIBs Architecture Guide

This document provides a comprehensive guide to the RIBs (Router, Interactor, Builder, State) architecture implementation in our iOS projects.

## Table of Contents

1. [Overview](#overview)
2. [RIB Types and Components](#rib-types-and-components)
3. [Protocol Organization](#protocol-organization)
4. [Project Structure](#project-structure)
5. [Implementation Examples](#implementation-examples)
6. [Communication Patterns](#communication-patterns)
7. [Guidelines for AI Agents](#guidelines-for-ai-agents)
8. [Examples and counter-examples](#examples-and-counter-examples)

## Overview

We're using [Uber's RIBs framework](https://github.com/uber/RIBs-iOS) to build scalable app architecture.
RIBs facilitate explicit dependencies, uni-directional data flow, and separation of UI and business logic.

RxSwift is used as the underlying uni-directional data framework.

**Key Benefits:**

- Modular architecture with clear boundaries
- Testable components with protocol-based mocking
- Uni-directional data flow using RxSwift
- Explicit dependency management
- Scalable from simple to complex flows

## RIB Types and Components

### RIB Components

Every RIB consists of these core components:

- **Builder** (`*Builder.swift`): Creates and configures RIB components
- **Interactor** (`*Interactor.swift`): Contains business logic and state management
- **Router** (`*Router.swift`): Handles presentation of child RIBs in the view hierarchy and navigation between child RIBs
- **Presenter** (`*ViewController.swift`): Manages UI presentation and implements `*Presentable` protocol (view-having RIBs only)
- **Protocols**: Define contracts between components, strategically placed across RIB files

### RIB Types

- **View-having RIBs**: Own UI components (UIHostingController) and use Presenter pattern
  - _Use for_: Individual screens, forms, lists, detail views
- **View-less RIBs**: Act as coordinators/flow managers without owning UI, no Presenter pattern
  - _Use for_: Navigation flows, multi-step processes, app-level coordination, container management

See the Canonical View-having RIB Example for a full presenter and interactor wiring.

**Key Rules:**

- **Router NEVER directly communicates with ViewController** - it only uses ViewControllable for view hierarchy management
- **View-less RIBs do NOT use the Presenter pattern** - they have no UI components to control
- **Only view-having RIBs implement Presentable with Rx bindings (no listener protocol)**
- **SwiftUI-only for new UI** — All new view-having RIBs MUST implement UI in SwiftUI and use a `UIHostingController<ViewType>` presenter. Do not introduce new UIKit-based presenters.

## Protocol Organization

### Protocol Placement Rules

**Protocols are strategically placed across RIB files following these patterns:**

#### 1. **Builder File** (`*Builder.swift`)

```swift
/// sourcery: CreateMock
protocol ExampleDependency: Dependency {
    // Dependencies required by this RIB
    var someService: SomeServiceProtocol { get }
}

/// sourcery: CreateMock
protocol ExampleBuildable: Buildable {
    // Public build method for external callers
    func build(withListener listener: ExampleListener) -> ExampleRouting
}
```

#### 2. **Router File** (`*Router.swift`)

```swift
/// sourcery: CreateMock
protocol ExampleInteractable: Interactable {
    // Router ↔ Interactor communication interface
    var router: ExampleRouting? { get set }
    var listener: ExampleListener? { get set }
}

/// sourcery: CreateMock
protocol ExampleViewControllable: ViewControllable {
    // ONLY for view hierarchy management - NOT for UI control
    // Router uses this only to present/dismiss the view controller
}
```

#### 3. **Interactor File** (`*Interactor.swift`)

```swift
/// sourcery: CreateMock
protocol ExamplePresentable: Presentable {
    // Interactor → UI (Rx binders)
    var loading: Binder<Bool> { get }
    var content: Binder<ContentData> { get }

    // UI → Interactor (Rx events)
    var buttonTapped: Observable<Void> { get }
}

/// sourcery: CreateMock
protocol ExampleRouting: ViewableRouting {
  // Navigation methods for interactor to request routing
  func routeToNextScreen()
  func dismissCurrentScreen()
}

/// sourcery: CreateMock
protocol ExampleListener: AnyObject {
  // Parent RIB communication interface
  func exampleDidComplete(with result: ExampleResult)
  func exampleDidCancel()
}
```

#### 4. **ViewController File** (`*ViewController.swift`) (ONLY for View-having RIBs)

View controllers implement `ExamplePresentable` by providing Binders for output and Observables for user actions.

SwiftUI presenter conventions for new UI:

- Presenter class derives from `UIHostingController<ViewType>` and implements `*Presentable` and `*ViewControllable`.
- `ViewType` is a SwiftUI `View` that renders a `ViewState` (`ObservableObject`) provided by the presenter.
- The view observes the state via `@ObservedObject var viewState: ViewState`, injected via the initializer.
- State flows Presenter → SwiftUI via `@Published` vars on `ViewState`.
- Naming/File convention: Presenter (hosting controller), `ViewType`, and `ViewState` may reside together in `*ViewController.swift`.

### Protocol Naming Conventions

- **`*Dependency`**: Dependencies required by RIB (in Builder)
- **`*Buildable`**: Public builder interface (in Builder)
- **`*Interactable`**: Router ↔ Interactor communication (in Router)
- **`*ViewControllable`**: Router view hierarchy management (in Router)
- **`*Routing`**: Interactor → Router navigation requests (in Interactor)
- **`*Listener`**: Child → Parent RIB communication (in Interactor)
- **`*Presentable`**: Interactor ↔ UI contract with Rx binders (outputs) and observables (events)

### Mock Generation

All protocols are marked with `/// sourcery: CreateMock` for automatic test mock generation.

## Project Structure

### RIB Directory Structure

```

ExampleRIB/
├── ExampleBuilder.swift # DI setup, component creation
├── ExampleInteractor.swift # Business logic, state management
├── ExampleRouter.swift # Navigation, child RIB management
└── ExampleViewController.swift # UI presentation (if view-having): UIHostingController-derived class, SwiftUI View, View State object (ObservableObject)
```

#### SwiftUI Integration (View-having RIBs)

```swift
import RxSwift
import SwiftUI

// View state stored in an ObservableObject
final class ExampleViewState: ObservableObject {
    @Published var isLoading = false
    @Published var title = ""
}

// SwiftUI view rendering the state and emitting actions
struct ExampleView: View {
    @ObservedObject private var state: ExampleViewState // The view observes changes to the view state via @ObservedObject
    private var buttonObserver: AnyObserver<Void>? = nil

    init(state: ExampleViewState) {
      self._state = ObservedObject(wrappedValue: state)
    }

    var body: some View {
        VStack {
            if state.isLoading { ProgressView() }
            Text(state.title)
            Button("Continue") { buttonObserver?.onNext(()) }
        }
    }

    func onButtonTapped(_ observer: AnyObserver<Void>) -> Self {
        var copy = self
        copy.buttonObserver = observer
        return copy
    }
}
// Presenter implementation and builder wiring: see the Canonical View-having RIB Example below.
```

SwiftUI-only rule for new UI:

- All new UI MUST be implemented in SwiftUI.
- The presenter MUST be `UIHostingController<ViewType>` and implement the RIB’s `*Presentable` and `*ViewControllable`.
- `ViewType` is the SwiftUI view type implementing the UI.
- Presenter owns a `ViewState: ObservableObject` with `@Published` properties used to drive `ViewType`.
- The view observes the state via `@ObservedObject var viewState: ViewState`, injected via the initializer.
- Naming convention: It is permissible to keep Presenter (hosting controller), `ViewType`, and `ViewState` in the RIB’s `*ViewController.swift` file.

### Library Organization

```
Libraries
└── ExampleModule/
    ├── Package.swift
    ├── Sources/ExampleModule/
    │   ├── RIBs/
    │   │   ├── MainExample/     # Primary RIB
    │   │   ├── SubExample1/     # Child RIB
    │   │   └── SubExample2/     # Child RIB
    │   ├── Workers/            # Business logic services
    │   ├── Models/             # Data structures
    │   ├── Extensions/         # Utility extensions
    │   └── Resources/          # Assets, strings
    └── Tests/ExampleModuleTests/
        └── RIBs/              # RIB unit tests
```

### Module Types

- **UI Modules**: Contain RIBs that represent main application UI flows and screens
- **Logic Modules**: Contain Workers/Services with business logic but no RIBs
- **Utility Modules**: Contain utility classes, extensions, and helper functions only

### App Architecture Overview

```
AppDelegate
|- SceneDelegate (DI: SceneComponent)
  |- Root RIB (View-less; DI: RootComponent)
    |- RIBs:
    | |- Splash RIB (Owns a view; DI: SplashComponent)
    | |- Main RIB (View-less; DI: MainComponent)
    |   |- Tab1 RIB
    |   |- Tab2 RIB
    |   |- ...
    |- Workers:
      |- ResourcesLoader
```

## Implementation Examples

### Canonical View-having RIB Example (Rx + SwiftUI Presenter)

This is the single, canonical example for a view-having RIB.

```swift
// Presentable defines outputs (Binders) and inputs (Observables)
protocol MainPresentable: Presentable {
    var wordSets: Binder<[WordSet]> { get }
    var wordSetSelected: Observable<UUID> { get }
}

final class MainInteractor: PresentableInteractor<MainPresentable>, MainInteractable {
    override func didBecomeActive() {
        super.didBecomeActive()

        // Interactor → UI
        presenter.wordSets.onNext([
            WordSet(title: "Basic Greetings", subtitle: "Hello, Goodbye, Thank you", wordCount: 12, color: .blue),
            WordSet(title: "Food & Drinks", subtitle: "Restaurant vocabulary", wordCount: 24, color: .green)
        ])

        // UI → Interactor
        presenter.wordSetSelected
            .subscribe(onNext: { id in
                // route to selected word set
                // NB: It's OK to capture strong ref to `self`, as long as the Rx subscription is bound to the Interactor's lifecycle
                self.router?.routeToWordSet(wordSetId: id)
            })
            .disposeOnDeactivate(interactor: self)
    }
}

// SwiftUI presenter implementation with UIHostingController
final class MainViewController: UIHostingController<MainView>, MainPresentable, MainViewControllable {
    private let viewState = MainViewState() // Note: The view controller doesn't observe the viewState, it owns the state and passes it to the view.
    private let wordSetSelectedSubject = PublishSubject<UUID>()

    init(themeProvider: ThemeProviding) {
        super.init(rootView: MainView(themeProvider: themeProvider, viewState: viewState))
        self.rootView = MainView(themeProvider: themeProvider, viewState: viewState)
            .onWordSetSelected(wordSetSelectedSubject.asObserver())
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // Interactor → UI
    var wordSets: Binder<[WordSet]> { Binder(viewState) { $0.wordSets = $1 } }

    // UI → Interactor
    var wordSetSelected: Observable<UUID> { wordSetSelectedSubject.asObservable() }
}

// Builder.swift - Wires everything together
final class MainBuilder: Builder<MainDependency>, MainBuildable {
    func build(withListener listener: MainListener) -> MainRouting {
        let component = MainComponent(dependency: dependency)

        // 1. Create ViewController (implements Presentable + ViewControllable)
        let viewController = MainViewController(
            themeProvider: component.themeProvider,
            analytics: component.analytics)

        // 2. Create Interactor with extracted dependencies (NOT dependency protocol)
        let interactor = MainInteractor(
            storage: component.storage,
            networkWorker: component.networkWorker,
            userStream: component.userStream,
            presenter: viewController)

        // 3. Wire connections
        interactor.listener = listener           // Parent communication

        // 4. Create Router (only for navigation, NOT UI control)
        return MainRouter(interactor: interactor, viewController: viewController)
    }
}
```

### View-less RIB Patterns

View-less RIBs serve as UI navigation/flow coordinators without owning UI components:

```swift
final class FlowCoordinatorBuilder: Builder<FlowCoordinatorDependency>, FlowCoordinatorBuildable {
  func build(withListener listener: FlowCoordinatorListener, parameters: FlowParameters) -> FlowCoordinatorRouting {
    let interactor = FlowCoordinatorInteractor(
      // Dependencies for flow coordination
    )
    return FlowCoordinatorRouter(
      navigationController: component.navigationController, // Receive NavigationController via DI
      interactor: interactor,
      step1Builder: Step1Builder(dependency: component),
      step2Builder: Step2Builder(dependency: component)
      // Additional step builders as needed
    )
  }
}
```

Unlike RIBs that have a view (via ViewController), view-less ones need to build and transparently add their first child RIB to the view/navigation
hierarchy on creation either in FlowCoordinatorRouter (implicitly):

```swift
final class FlowCoordinatorRouter: ViewableRouter {
  override func didLoad() {
    super.didLoad()
    routeTo(step: .intro)
  }
}
```

or explicitly by its Interactor:

```swift
final class FlowCoordinatorInteractor {
  override func didBecomeActive() {
    super.didBecomeActive()
    router?.routeTo(step: .intro)
  }
}
```

#### **A. Root RIB (View-less Coordinator)**

The Root RIB creates a view controller and sets it as the UIWindow's rootViewController. The root view controller is then used to present child RIBs.
For convenience, the RootRouter is derived from LaunchRouter.

**Characteristics:**

- Uses `LaunchRouter<RootInteractable, ViewControllable>` base class
- Acts as the main app coordinator
- Manages app-wide dependencies and services
- Coordinates navigation between major application flows (e.g., Splash -> Onboarding -> Main)
- Contains extensive dependency injection setup

**Key Features:**

```swift
final class RootRouter: LaunchRouter<RootInteractable, ViewControllable>, RootRoutingInternal {
    // Manages child RIBs without its own view
    func routeToSplash(...)
    func routeToOnboarding(...)
    func buildAndActivateMain()
    func showMain(animated: Bool)
}
```

```swift
// SceneDelegate.swift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var rootRouter: RootRouting?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else {
            return
        }

        let window = UIWindow(windowScene: scene)

        let component = SceneComponent()
        let builder = RootBuilder(dependency: component)
        let router = builder.build()

        router.launch(from: window)

        self.window = window
        self.rootRouter = router
    }
}
```

#### **B. Main RIB (Tab Bar Coordinator)**

The Main RIB creates a UITabBarController, and assigns tabs to the child RIB's view controllers (wrapped each in its own UINavigationController).

**Characteristics:**

- Uses `ViewableRouter<MainInteractable, ViewControllable>` with UITabBarController
- Acts as a container for main app tabs
- Manages tab-based navigation
- Coordinates child RIBs (Canvas, Games, Wins, Profile)

**Key Features:**

```swift
final class MainRouter: ViewableRouter<MainInteractable, ViewControllable>, MainRouting {
    let tabBarController: UITabBarController

    func buildAndActivateChildren(_ mainRIBs: inout MainRIBs) {
        // Pre-loads child RIBs for performance
    }
}
```

```swift
// MainBuilder.swift
final class MainBuilder: Builder<MainDependency>, MainBuildable {
  func build() -> MainRouter {
    let tab1 = tab1Builder.build(withListener: interactor)
    // ...

    let tab1NC = UINavigationController(rootViewController: tab1.viewControllable.uiviewController)
    // ...

    let tabBarController = UITabBarController()
    tabBarController.viewControllers = [tab1NC /*, ... */]

    let router = MainRouter(tabBarController: tabBarController)

    return router
  }
}
```

#### **C. Flow Coordinator RIBs (View-less Pattern)**

**Use Cases**: Multi-step flows, wizards, sequential navigation

**Characteristics:**

- Uses `ViewableRouter<FlowCoordinatorInteractable, ViewControllable>` with UINavigationController
- Coordinates complex multi-step flows
- Manages sequential navigation between flow steps
- Acts as a container without its own specific view content

**Key Features:**

```swift
final class FlowCoordinatorRouter: ViewableRouter<FlowCoordinatorInteractable, ViewControllable>, FlowCoordinatorRoutingInternal {
    let navigationController: UINavigationController

    func routeTo(step: FlowStep) {
        // Routes to different flow screens based on step
    }
}
```

## Communication Patterns

### Dependency Injection (Parent → Child)

**Component Hierarchy:**

```swift
// Root level - creates all shared services
final class RootComponent: Component<RootDependency> {
    // Shared workers and services
    fileprivate let storageWorker: StorageWorking
    fileprivate let analyticsWorker: AnalyticsWorking
    // etc...
}

// Child RIB component - inherits and adds specific dependencies
final class ExampleComponent: Component<ExampleDependency> {
    var storage: Storing { dependency.storage }

    // Child-specific dependencies
    lazy var exampleWorker: ExampleWorking = {
        ExampleWorker(storage: storage)
    }()
}
```

**Rules:**

- Dependencies flow DOWN from parent to child RIBs only
- Each RIB defines required dependencies via `*Dependency` protocol
- Root-level component acts as the main service container
- Never pass dependencies UP the hierarchy

**Critical Dependency Injection Pattern:**

- **NEVER** pass `*Dependency` protocol references directly to Interactors/ViewControllers
- **ALWAYS** extract actual services/workers/streams from the component in the Builder
- **Interactors/ViewControllers expect concrete service types**, not dependency protocols

```swift
// ❌ WRONG - Don't pass dependency protocol
final class ExampleInteractor {
    init(dependency: ExampleDependency) { ... } // BAD!
}

// ✅ CORRECT - Extract actual services in Builder
final class ExampleBuilder {
    func build() -> ExampleRouting {
        let component = ExampleComponent(dependency: dependency)

        // Extract actual services from component
        let presenter = ExampleViewController(
            themeProvider: component.themeProvider
        )

        // Extract actual services from component
        let interactor = ExampleInteractor(
            storage: component.storage,           // Actual service
            analytics: component.analytics,       // Actual service
            userStream: component.userStream,     // Actual stream
            presenter: presenter)
    }
}

final class ExampleInteractor {
    let storage: Storing                          // Concrete protocol
    let analytics: AnalyticsLogging               // Concrete protocol
    let userStream: UserStreaming                 // Concrete protocol

    init(storage: Storing, analytics: AnalyticsLogging, userStream: UserStreaming, presenter: ExamplePresentable) {
        self.storage = storage
        self.analytics = analytics
        self.userStream = userStream
        super.init(presenter: presenter)
    }
}
```

#### 1. Presenter Pattern (Interactor ↔ UI) - **MOST IMPORTANT**

See the Canonical View-having RIB Example for a complete Interactor controlling UI via Presentable binders and subscribing to UI events.

// Presenter implementation: see Canonical View-having RIB Example.

#### 2. Router Pattern (View Hierarchy Only)

```swift
// Router ONLY manages view hierarchy - NO direct UI control
class ExampleRouter: ViewableRouter<ExampleInteractable, ExampleViewControllable> {
    func routeToDetail(_ item: Item) {
        let detailRouter = detailBuilder.build(withListener: interactor, item: item)
        // Router only presents/dismisses view controllers:
        viewController.present(detailRouter.viewControllable.uiviewController, animated: true)
        attachChild(detailRouter)
    }
}
```

#### 3. Listener Pattern (Child → Parent)

```swift
// Child RIB communicates with parent via listener
protocol ChildListener: AnyObject {
    func childDidComplete(with result: ChildResult)
    func childDidRequestNavigation(to destination: Destination)
}

// Parent implements listener
class ParentInteractor: ChildListener {
    func childDidComplete(with result: ChildResult) {
        // Handle child completion
        router?.routeToNextStep(result)
    }
}
```

#### Router Commands (Interactor → Router)

```swift
// Interactor requests navigation via router
protocol ExampleRouting: ViewableRouting {
    func routeToDetail(_ item: Item)
    func dismissCurrentFlow()
}

// Router implements navigation
class ExampleRouter: ExampleRouting {
    func routeToDetail(_ item: Item) {
        let detailRouter = detailBuilder.build(withListener: interactor, item: item)
        // Present detail RIB
    }
}
```

#### Worker Pattern (Business Logic)

Workers subclass `Worker`. The worker's lifecycle is bound to the owning interactor in `start()`.
Workers receive all inputs through dependency injection -- interactors must not call worker methods directly.
Workers expose Rx data streams via protocols, which are injected into owning or child RIBs;
only these protocols are referenced by children. Workers begin their operation in `didStart()`,
and all Rx subscriptions within should use `.disposeOnStop(self)` to ensure proper cleanup.

```swift
// Data stream-exposing protocol
protocol DataStreamProviding {
  var dataStream: Observable<Data> { get }
}

protocol ExampleWorking: Working, DataStreamProviding {
}

// Workers encapsulate business logic and can be shared across RIBs via data providing protocol.
// Only one RIB owns a worker (and receives it via the *Working protocol).
class ExampleWorker: Worker, ExampleWorking {
    private let storage: Storing
    private let authenticatedUserStream: AuthenticatedUserStreaming

    private let dataStreamSubject = PublishSubject<Data>()

    var dataStream: Observable<Data> { dataStreamSubject.asObservable() } // DataStreamProviding requirement

    init(storage: Storing,
         authenticatedUserStream: AuthenticatedUserStreaming)
    {
      self.storage = storage
      self.authenticatedUserStream = authenticatedUserStream
      super.init()
    }

    override func didStart() {
      super.didStart()

      storage
        .query(/*...*/) // Start Rx subscriptions.
        .map { /*...*/ } // Do business logic, etc.
        .bind(to: dataStreamSubject)
        .disposeOnStop(self)
    }
}
```

#### **D. Navigation Patterns**

- View-based RIBs: Use `ViewableRouter` with view controllers
- Flow coordinators: Use navigation/tab controllers as containers
- Scene-based RIBs: Use `SceneControllable` for SpriteKit integration
- Root-level coordination: Use `LaunchRouter` for app-wide management

##### Navigation Controller Access Rules

- If a parent/child RIB must PUSH/POP, the required `UINavigationController` MUST be explicitly provided via DI at that level (e.g., as a dependency on the parent component or created and owned at that hierarchy level).
- Do NOT attempt to “discover” a nav controller by:
  - Casting the current view controller to `UINavigationController`, or
  - Accessing `viewController.navigationController`
- If a navigation controller is not available via explicit DI, do NOT proceed with implicit access. Instead:
  - Mark the requirement as [NEEDS CLARIFICATION] in the feature spec.
  - Propose concrete options to make the nav controller available, for example:
    - Parent’s dependency exposes `UINavigationController`
    - Parent creates and owns a `UINavigationController` and passes it down as `ViewControllable`
    - Introduce a container RIB (flow coordinator) that owns the nav controller

###### Reference: Parent-owned UINavigationController DI

When a parent RIB wants to route to the start of a Navigation stack, the parent creates and owns a UINavigationController and injects it into a child RIB via `Buildable.build()`:

- Parent ownership: Parent creates `UINavigationController` and embeds it into its view using addChild + pin-to-edges.
- Explicit DI: Parent passes the nav controller into `ChildBuilder.build(…, navigationController: NavigationControllable)`.
- Child usage: Child Router stores the injected `NavigationControllable` for push/pop. It does not discover or create its own nav controller.

Snippet (simplified):

```swift
// Parent router
func routeToChild() {
  let navigationController = UINavigationController()
  let childRouter = childBuilder.build(
    withListener: interactor,
    navigationController: navigationController // injected as NavigationControllable
  )
  navigationController.viewControllers = [childRouter.viewControllable.uiviewController]
  // Embed nav controller into root view
  viewControllable.uiviewController.addChild(navigationController)
  viewControllable.uiviewController.view.addSubview(navigationController.view)
  // Pin to edges …
  // Attach child RIB
  attachChild(mainRouter)
}

// Buildable protocol for the Child RIB
func build(withListener listener: ChildListener,
           navigationController: NavigationControllable) -> ChildRouting { … }

// ChildRouter
final class ChildRouter: ViewableRouter<…, …> {
  let navigationController: NavigationControllable
  init(navigationController: NavigationControllable, interactor: ChildInteractable, viewController: ChildViewControllable, ...) {
    self.navigationController = navigationController
    super.init(interactor: interactor, viewController: viewController)
  }
}
```

Note: `NavigationControllable` is a thin protocol over `ViewControllable` with retroactive conformance for `UINavigationController`. Prefer injecting this protocol to keep routers decoupled from UIKit types while still enabling push/pop.

## Guidelines for AI Agents

### Critical Implementation Rules

#### 1. **Protocol Placement is NOT Arbitrary**

- **NEVER** move protocols between files randomly
- **Builder protocols** (`*Dependency`, `*Buildable`) stay in `*Builder.swift`
- **Router protocols** (`*Interactable`, `*ViewControllable`) stay in `*Router.swift`
- **Interactor protocols** (`*Routing`, `*Listener`, `*Presentable`) stay in `*Interactor.swift`
- View controllers implement `*Presentable` directly (no separate listener protocol)
- This organization enables proper mock generation and circular dependency prevention

#### 2. **Presenter/Presentable Pattern Rules**

**For View-Having RIBs (MANDATORY):**

- **NEVER** let Router directly control UI elements
- **ALWAYS** use Presenter pattern: Interactor ↔ Presentable (Rx) ↔ ViewController
- **ViewControllable is ONLY for view hierarchy management** (present/dismiss)
- **Interactor controls UI state via Presentable binders**
- **Interactor extends PresentableInteractor**
- **UI sends events to Interactor via Presentable observables**
- **ViewController implements BOTH *Presentable (Rx) AND *ViewControllable**

**For View-less RIBs:**

- **NO Presenter pattern** - they have no UI to control
- **NO \*Presentable protocol needed**
- **Router uses base Router<Interactable> or ViewableRouter with container views**
- **Interactor extends base Interactor, not PresentableInteractor**

#### 3. **Communication Flow Rules**

- **Dependencies** ONLY flow DOWN (Parent → Child)
- **Listeners** for UP communication (Child → Parent)
- **Presentable** for Interactor → UI control (view-having RIBs only)
- UI → Interactor events are exposed via `Observable` properties on `*Presentable`
- **Router NEVER directly touches UI** - only view hierarchy
- Root RIB creates all shared services (Storage, Analytics, etc.)
- Never inject child dependencies into parents

#### 4. **RIB Lifecycle Management**

```swift
// ALWAYS attach/detach child RIBs properly
func routeToChild() {
    let childRouter = childBuilder.build(withListener: interactor)
    attachChild(childRouter) // Required!
    // Present UI...
}

func dismissChild() {
    guard let childRouter = children.first(where: { $0 is ChildRouting }) else { return }
    // Dismiss UI...
    detachChild(childRouter) // Required!
}
```

#### 5. **View-less RIB Patterns**

- **Root RIB**: App coordinator using `LaunchRouter`
- **Flow RIBs**: Navigation coordinators using `ViewableRouter` + UINavigationController
- **Container RIBs**: Tab coordinators using `ViewableRouter` + UITabBarController
- **Game RIBs**: Scene managers using `Router` + SpriteKit scenes

#### 6. **Testing Requirements**

- All protocols MUST have `/// sourcery: CreateMock`
- Each RIB MUST have corresponding test file
- Mock all dependencies in tests
- Test RIB lifecycle (attach/detach)

#### 7. **Rx Lifecycle in Interactors**

- Do NOT create a DisposeBag in Interactors or Workers.
- For **Interactors**, ALWAYS use `.disposeOnDeactivate(interactor: self)` for subscriptions made in `didBecomeActive()`.
- For **Workers** (subclasses of RIBs `Worker`), ALWAYS use `.disposeOnStop(self)` for subscriptions made in `didStart()`; the Worker's lifecycle is bound to the owning Interactor.
- For non-Interactor components (e.g., plain services not subclassing `Worker`), use a scoped `DisposeBag` owned by that component.

Example:

```swift
// Interactor starting an Rx subscription example
final class ExampleInteractor: Interactor, ExampleInteractable {
  override func didBecomeActive() {
      super.didBecomeActive()

      presenter.buttonTapped
          .flatMapLatest { [service] in service.performAction() }
          .subscribe(onNext: {
            // handle events
            // NB: It's OK to capture a strong ref to `self`, the subscription will be disposed of when the interactor is detached.
            self.handleEvent()
          })
          .disposeOnDeactivate(interactor: self)
  }
}

// Worker (RIBs Worker) starting an Rx subscription example
final class ExampleWorker: Worker {
    override func didStart() {
        super.didStart()

        service.stream
            .subscribe(onNext: { data in
              // business logic
              // NB: It's OK to capture a strong ref to `self`, the subscription will be disposed of when the worker is stopped.
              self.processUpdate(data)
             })
            .disposeOnStop(self) // Automatically disposed when worker stops
    }
}

// Interactor owning a Worker and starting it example
final class SomeInteractor: Interactor {
    private let someWorker: SomeWorking

    init(someWorker: SomeWorking) {
        self.someWorker = someWorker
        super.init()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        someWorker.start(self) // binds worker lifecycle to this interactor
    }
}
```

#### 8. **Implementation Steps**

**Creating New RIB:**

New RIBs are added in a sequence of steps. Create separate tasks for each step in the 'spec.md' file:

1. Scaffolding a new RIB only
2. Modifying data sources, adding new schema, mock data, etc.
3. Wiring the new RIB to the parent RIB (providing the builder to the parent router, ensuring DI is wired, implmenenting parent router's `routeTo*` method)

Reflect this sequence of steps in the plan.

**Scaffolding the new RIB:**

1. Create directory: `ModuleName/RIBName/`
2. Add files based on RIB type:
   - **View-having**: Builder, Interactor, Router, ViewController
   - **View-less**: Builder, Interactor, Router only
3. Follow protocol placement rules (see Protocol Organization section)
4. Wire components in Builder (see Implementation Examples section)

#### 9. **Error Prevention**

- **NEVER** create circular dependencies between RIBs
- **NEVER** let child RIBs directly access parent services
- **NEVER** pass `*Dependency` protocol references to Interactors/ViewControllers
- **NEVER** let Router directly control UI (use Presenter pattern for view-having RIBs)
- **NEVER** bypass Presentable interface for UI control (in view-having RIBs)
- **ALWAYS** extract concrete services from components in Builders
- **ALWAYS** use listeners for child → parent communication
- **ALWAYS** use Presenter pattern for interactor → UI communication (view-having RIBs only)
- **ALWAYS** properly attach/detach child RIBs
- **NEVER** retain strong references to parent RIBs (via Listener)

### Adding a New RIB (Spec Checklist)

Use this as a planning checklist for your feature spec. Capture decisions there before writing any code, and link back to canonical sections for details.

```
1. RIB type and contracts
  - Decide View-having vs View-less. For View-having ONLY, outline the `*Presentable` outputs (Binders) and UI event streams (Observables). Define `*Listener` (child → parent) and `*Routing` methods you’ll need. See Protocol Organization and the Canonical View-having RIB Example.
2. Data and dependencies
  - List data sources, services, and workers the RIB needs. Specify the concrete service protocols to inject (don’t pass `*Dependency` to Interactors/ViewControllers). Note module boundaries. See Dependency Injection.
3. Navigation and containers
  - Identify where this RIB lives in the hierarchy and what containers it needs (UINavigationController/UITabBarController). Confirm availability via explicit DI. If unavailable, mark [NEEDS CLARIFICATION] and propose options. See Navigation Controller Access Rules.
4. Lifecycle and workers
  - Note any long-running streams or background work. Decide ownership (Interactor-owned Worker?) and intended lifecycle behavior. Plan to bind Rx with `.disposeOnDeactivate(interactor:)` (Interactor) and `.disposeOnStop(self)` (Worker). See Rx Lifecycle in Interactors.
5. UI plan and initial data
  - Describe minimal ViewState and user actions. Plan to use a SwiftUI-hosted presenter. If real data isn’t ready, specify mock/sample data and where it comes from. See SwiftUI Integration.
6. Parent integration plan
  - Specify how the parent will expose child builders via `*Dependency`, attach/detach points, and listener callbacks on close/next. See Router Pattern and RIB Lifecycle Management.
7. Testing strategy
  - List key unit tests (Interactor happy path and edge cases, Router attach/detach). Ensure all protocols will have `/// sourcery: CreateMock`. See Testing Requirements.
```

### Quick Reference Commands

**Finding RIB patterns:**

```bash
# Find all RIB routers
find . -name "*Router.swift" | head -10

# Find protocol definitions
grep -r "protocol.*Routing\|protocol.*Buildable" --include="*.swift"

# Find RIB builders
find . -name "*Builder.swift" | head -10
```

### Frequently Asked Pitfalls and FAQ

- Q: Can Router call methods on ViewController to update UI?
  - A: No. Router only manages view hierarchy via ViewControllable. UI updates must go through Presentable (Interactor → UI) in view-having RIBs.
- Q: Should Interactor accept a `*Dependency` in its initializer?
  - A: No. Extract concrete services from the Component in the Builder and pass them explicitly to the Interactor.
- Q: When do I use PresentableInteractor vs Interactor?
  - A: Use PresentableInteractor only for view-having RIBs. View-less RIBs extend base Interactor and have no Presentable.
- Q: How do I send user actions to the Interactor without a listener protocol?
  - A: Expose `Observable` properties on the `*Presentable` (e.g., `buttonTapped`, `itemSelected`) and subscribe in the Interactor.
- Q: How do I avoid retain cycles between Interactor and Presenter?
  - A: Presenter should not have references to its Interactor.
- Q: Is it OK to capture a strong ref to `self` in Rx subscriptions?
  - A: It's OK in Interactors and Workers, as long as the Rx subscription's lifetime is bound to self (via `.disposeOnDeactivate(interactor: self)` for Interactors, `.disposeOnStop(self)` for Workers). In all other cases (non-Interactor/Worker), make sure a `[weak self]` is captured.

### Key Differences: View-having vs View-less

- View-having: `PresentableInteractor<Presentable>` + Presenter pattern; UI via binders/observables
- View-less: base `Interactor` + container controllers only; focuses on flow coordination

This guide ensures consistency and prevents architectural violations when extending the RIBs codebase.

## Examples and counter-examples

### Passing Child Builders to Routers

**Purpose:**
When a router needs to build one of its child RIBs.

**Solution:**
The router has a reference to the child RIB's builder (conforming to `Buildable`).
In the `routeToXXX()` router method, the router invokes `childBuilder.build()` to construct the child RIB's Router,
then uses a convention to add the RIB to the view hierarchy (eg, push if we have NavigationController and the child is ViewControllable),
and attach to the RIBs tree (`self.attach(childRouter)`).

The best way to pass the child builder to the router is via the initializer.

```swift
final class ParentRouter: ViewableRouter<ParentInteractable, ParentViewControllable>, ParentRouting {
  private let childBuilder: ChildBuildable

  init(childBuilder: ChildBuildable,
    /*...*/)
  {
    self.childBuilder = childBuilder
    // ...
  }

  func routeToChild() {
    let childRouter = childBuilder.build(/**/)
    // ...
  }
}

final class ParentBuilder: Builder<ParentDependency>, ParentBuildable {
  func build(/**/) {
    // ...
    let router = ParentRouter(
      childBuilder: ChildBuilder(dependency: component),
      // ...
    )
    // ...
  }
}
```

This way, the child builder is always available to the router to construct the child.
Static DI also makes it easy to reason about app's structure by looking at the builder hierarchy.
"If it builds - it works".

#### BAD examples

```swift
// BAD example 1
final class ParentRouter: ViewableRouter<ParentInteractable, ParentViewControllable>, ParentRouting {
  private var childBuilder: ChildBuildable?

  func setChildBuilder(_ builder: ChildBuildable) {
    self.childBuilder = builder
  }

  func routeToChild(/**/) {
    guard let builder = childBuilder else { return }
    // Use `builder`
  }
}

final class ParentBuilder: Builder<ParentDependency>, ParentBuildable {
  func build(/**/) {
    // ...
    let router = ParentRouter(/*...*/)

    let childBuilder = ChildBuilder(dependency: component)
    router.setChildBuilder(childBuilder)
    // ...
  }
}
```

Why it's bad:

- Child builders should be availble unconditionally.
- It should be impossible to "forget" to pass required properties.
- The router should always be able to construct a child.
- The builder available to the router should never be set to `nil` or to another instance of `Buildable`.

### Routing to a child

**Purpose:**
To navigate to the child RIB.

**Solution:**

```swift
final class ParentRouter: ViewableRouter<ParentInteractable, ParentViewControllable>, ParentRouting {
  // ...
  private let childBuilder: ChildBuildable
  // ...
  func routeToChild() {
    let childRouter = childBuilder.build(/**/)
    attachChild(childRouter)
    navigationController.push(childRouter.viewControllable, animated: true)
  }
  func routeFromChild() {
    guard let childRouter = children.last as? ChildRouting else {
      assertionFailure("[DEBUG-ONLY] Internal error, should not happen")
      return
    }
    detachChild(childRouter)
    navigationController.pop(animated: true)
  }
}
```

#### Bad examples

```swift
final class ParentRouter: ViewableRouter<ParentInteractable, ParentViewControllable>, ParentRouting {
  // ...
  private var childRouter: ChildRouting?
  // ...
  func routeToChild(/**/) {
    guard childRouter == nil else { return } // Error-prone (extra state)
    let childRouter = // ...
    self.childRouter = childRouter
    // ...
  }
  func detachChild() {
    guard let childRouter else { return } // Not needed, can always find the child router in the children list
    // ...
    childRouter = nil // Error-prone (extra state)
  }
}
```

Why it's bad:

- The router stores additional reference to the child router as an instance var, and has to manage additional state (error-prone, can get out-of sync).
  Use Router's `children` collection to access children and find needed router by type (or an identity if the flow allows multiple children of the same type).

### Handling Back navigation

**Purpose:**
The Router needs to detach the child RIB after the Back navigation command.

There are several ways to implement the Back navigation, let's consider two most typical:

**Option 1: Custom Navigation Bar and the Back button.**
The View hides the standard navigation bar, and shows custom toolbar with the button mimicking the "Back" navigation button.
Events: Tapping the custom button -> onBackTapped event -> Presenter -> Interactor -> Parent Interactor (via Listener) -> Router -> `router.detachChild()`.
(Note: "Swipe to Pop" gesture is disabled in case of a custom Navigation bar).

```swift
struct ChildView: View {
  // ...
  private var backObserver: AnyObserver<Void>?
  // ...
  var body: some View {
    Content {
      // ...
    }
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(action: {
          backObserver?.onNext(())
        }) {
          HStack {
            Image(systemName: "chevron.left")
            Text(localizable: .customBackCommand)
          }
        }
      }
    }
  }
  // ...
  func onBack(_ observer: AnyObserver<Void>) -> Self { var c = self; c.backObserver = observer; return c }
}

protocol ChildPresentable {
  var backTapped: Observable<Void> { get }
}

final class ChildHostingViewController: UIHostingController<ChildView>, ChildPresentable, ChildViewControllable {
  // ...
  private let backSubject = PublishSubject<Void>()
  // Presentable
  var backTapped: Observable<Void> { backSubject.asObservable() }

  init() {
    let view = ChildView(state: state)
      .onBack(backSubject.asObserver())
    super.init(rootView: view)
  }
}
```

**Option 2: Standard Navigation Bar (and the "Swipe to Pop" gesture).**
If the Back navigation button is not hidden (no `.navigationBarBackButtonHidden(true)` view modifier),
the navigation bar shows the standard Back navigation button. Also, the standard "Swipe to Pop" gesture is enabled.
When either of these events happen, the view controller is popped from the navigation stack.
We need to intercept the event and notify the parent Router so it can also detach the child RIB.
Failing to notify the parent Router would lead to memory leaks, and undefined behavior later.
Proposed solution: Child View Controller overrides "viewDidDisappear, and in case of `isMovingFromParent == true`,
sends backTapped event to the Presenter -> Interactor -> Parent Interactor (via Listener) -> Router -> `router.detachChild()`.

```swift
protocol ChildPresentable {
  var backTapped: Observable<Void> { get }
}

final class ChildViewController: UIHostingController<ChildView>, ChildPresentable, ChildViewControllable {
  // ...
  private let backSubject = PublishSubject<Void>()
  // Presentable
  var backTapped: Observable<Void> { backSubject.asObservable() }

  // Detect standard "Back" navigation command, or "Swipe to Pop" navigation gesture
  override func viewDidDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if isMovingFromParent {
      backSubject.onNext(())
    }
  }
}
```

**Router implementation common for 2 options:**

```swift
final class ParentRouter: ViewableRouter<ParentInteractable, ParentViewControllable>, ParentRouting {
  // ...
  // `routeFromChild()` could called either in response to a custom "Back" navigation button,
  // or programmatically from the view controller's `viewDidDisappear()` (in response to the standard "Back" navigation command, or the standard "Swipe to Pop" navigation gesture)
  func routeFromChild() {
    guard let childRouter = children.last as? ChildRouting else { return }
    detachChild(childRouter)

    // In case of the standard Back navigation action (detected in the view controller's `viewDidDisappear()`),
    // the view controller has already been removed from the navigation stack - check to not pop extra VC.
    let viewController = childRouter.viewControllable.uiviewController
    if navigationController.uiNavigationController.viewControllers.last == viewController {
      navigationController.pop(animated: true)
    }
  }
}
```

**IMPORTANT**
The Back navigation needs to be properly handled.
DECIDE during planning which of the options to use to handle the Back navigation.
ALWAYS implement one of the pattern to handle the back navigation, otherwise risk memory leaks and undefined behavior.
