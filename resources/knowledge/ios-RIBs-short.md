# RIBs Architecture – Hard Rules and Operating Checklist

**References**:

- [DOC:IOS_RIBS](ios-RIBs.md)

Read `<project_context>...</project_context>` section in the triggering prompt, and parse available fields in the JSON struct:

- IOS_APP_NAME

--

This file is the authoritative, low-latency instruction set for RIBs work. It contains only non-negotiable rules and a spec-first checklist. All implementation details, patterns, and examples live in [DOC:IOS_RIBS].

Follow these rules in every code or plan change. If you need code-level guidance, open [DOC:IOS_RIBS] and navigate to the referenced sections.

## Core Architecture Principles

### I. Composable RIBs Architecture

- RIBs are the main building blocks of the application.
- The application's architecture is a hierarchy RIBs (directed acyclic graph).
- ALL new features MUST be composed of RIBs.
- A feature might require a single view-having RIB, or a hierarchy of several RIBs and/or Workers. Provide reasoning behind the proposed RIBs hierarchy for the feature.

### II. SPM-First Modules and Clear Boundaries

- All app feature code (RIBs, Workers, Models) MUST live in Swift Package Manager (SPM) modules.
- DO NOT place new RIBs under `iOS/App/...` (the iOS App target contains only minimal app bootstrap code).
- Put new standalone RIBs in the main implementation module (`iOS/Libraries/${IOS_APP_NAME}Main/Sources/${IOS_APP_NAME}Main/RIBs/`). Complex multi-RIB features might warrant separate SPM module. Provide rationale for it. Follow guidelines in [DOC:IOS_RIBS].
- Cross-module APIs MUST be protocol-based; avoid leaking UIKit or concrete types across module boundaries.
- Rationale: SPM-first enables fast, isolated builds, clear ownership, and reuse.

### III. Protocol placement (never violate this)

Protocol placement follows the RIBs rules:

- `*Dependency`, `*Buildable` → in `*Builder.swift`
- `*Interactable`, `*ViewControllable` → in `*Router.swift`
- `*Presentable`, `*Routing`, `*Listener` → in `*Interactor.swift`
- View-having RIBs: the ViewController implements both `*Presentable` (Rx) and `*ViewControllable`
- All public protocols MUST be marked with `/// sourcery: CreateMock` for test scaffolding.
- Rationale: Avoids circular references and preserves testability.

### IV. Presenter pattern (view-having RIBs only)

- Interactor extends `PresentableInteractor<*Presentable>` and controls UI via Rx binders exposed via `*Presentable` protocol (no direct View/ViewController calls)
- UI events flow to Interactor via `Observable` properties on `*Presentable`
- Router never updates UI; it only manages view hierarchy through `*ViewControllable`
- New UI is ONLY developed in SwiftUI.
- The ViewController class derives from `UIHostingController<ViewType>`, implements RIB's `*ViewControllable`, `*Presentable` protocols.
- `ViewType` is the SwiftUI view type implementing the UI.
- The SwiftUI `ViewType` receives state via `@Published` vars in a `ViewState: ObservableObject`, owned and updated by the ViewController (presenter).
- The view observes the state via `@ObservedObject var viewState: ViewState`, injected via the initializer.
- Naming/File convention: It’s acceptable to keep the `UIHostingController` subclass, `ViewType`, and `ViewState` together in the RIB’s `*ViewController.swift` file.
- Rationale: Enforces uni-directional flow and testability; aligns with Uber RIBs and our [DOC:IOS_RIBS].

### V. Navigation DI (no discovery)

- Do NOT discover nav/tab controllers via casts or `viewController.navigationController`
- The required container (e.g., `UINavigationController`) MUST be explicitly provided via DI by the appropriate parent.
- If a container is not available, mark the need as [NEEDS CLARIFICATION] in the spec and propose DI options
- Prefer injecting containers via small protocols (e.g., `NavigationControllable`) instead of UIKit types directly.
- `ViewControllable` definition and UIViewController default conformance live in the RIBs framework;
- `NavigationControllable` definition and UINavigationController default conformance live in the `SharedUtility` framework.
- Import `SharedUtility`, don't add duplicate `NavigationControllable` requirements or conformance.
- Routers MUST attach/detach children and use the router’s `children` collection for lookups (no extra stored state).
- Rationale: Prevents discovery anti-patterns and ensures predictable, composable navigation.

### VI. SwiftUI for new UI

- All new UI MUST be written in SwiftUI.
- Use a presenter class derived from `UIHostingController<ViewType>` as the Presenter/ViewControllable for view-having RIBs.
- `ViewType` is the SwiftUI view implementing the UI.
- State flows Presenter → SwiftUI: the presenter owns a `ViewState` object (ObservableObject) exposing `@Published` vars; the `ViewType` (SwiftUI) observes the view state via `@ObservedObject var viewState: ViewState`, injected via the initializer.
- Naming/File convention: It is acceptable to place the `UIHostingController` subclass (presenter), the SwiftUI `ViewType`, and the `ViewState` class in the RIB’s `*View.swift` file.
- Existing UIKit screens may remain until refactored; new features MUST adopt SwiftUI presenters.
- Rationale: Improves developer velocity, accessibility, and consistency while leveraging SwiftUI.

### VII. Back Navigation Handling for Navigation-Stack Screens

- For any view-having RIB presented within a UINavigationController stack, one (and only one) of the approved
  back-handling patterns from [DOC:IOS_RIBS] MUST be implemented to ensure proper RIB detachment:
  - Option 1: Custom navigation bar with explicit Back button
    - Hide the standard bar with `.navigationBarBackButtonHidden(true)` and provide a custom leading toolbar button, which emits `backTapped` event to notify the Interactor.
  - Option 2: Standard back button and swipe-to-pop gesture
    - Keep the standard navigation bar/gesture. In the Presenter (UIHostingController subclass), override
      `viewDidDisappear(_:)` and, when `isMovingFromParent == true`, emit `backTapped` to notify the Interactor.
- Presentable contract MUST expose `backTapped: Observable<Void>` for such screens.
  The Interactor MUST subscribe to
  `backTapped` and inform the parent via its Listener to perform detachment.
- Parent Router MUST detach the child router on Back. If using the standard bar/gesture (Option 2), the Router MUST
  guard against double-pop by checking whether the child's view controller is still the last on the stack before
  invoking `pop(animated:)`.
- Rationale: Ensures RIB trees remain consistent and prevents memory leaks or undefined behavior when navigating back.

### VI. Dependency flow and DI usage

- Dependencies flow only parent → child; never pass child deps up
- Never pass a `*Dependency` protocol into an Interactor or ViewController
- Extract concrete services/workers/streams in the Builder from the Component and pass those into Interactors/ViewControllers
- Parent routers MUST receive child `*Buildable` via initializer (static DI). No setters.
- Data should flow via Rx streams, even between peer RIBs; avoid direct method calls. Data streams are mamnaged by Workers

### VII. Lifecycle and Rx

- Interactors: start Rx work in `didBecomeActive()` and use `.disposeOnDeactivate(interactor:)`
- Workers (subclass of RIBs `Worker`): start in `didStart()` and use `.disposeOnStop(self)`; start workers from Interactors
- Do not create `DisposeBag` in Interactors/Workers (use lifecycle helpers instead)

### VIII. RIB lifecycle (attach/detach)

- Always `attachChild(_:)` on present/show and `detachChild(_:)` on dismiss/close
- Never retain strong refs to parent RIBs (e.g., Listener)

### IX. Testing and mocks

- Mark all protocols with `/// sourcery: CreateMock`
- NOT A REQUIREMENT NOW: Each RIB must have tests for Interactor logic and Router attach/detach lifecycles

## Operating Checklist (Spec-First)

Use this to author the feature spec before writing code. Keep it in the feature plan.

- Goal & scope: What the RIB does and success criteria
- Module path & ownership:
  - Confirm the RIB lives under `iOS/Libraries/${IOS_APP_NAME}Main/Sources/${IOS_APP_NAME}Main/RIBs/`
  - If a different module is required, justify and add to plan with explicit dependency wiring
- RIB type & contracts:
  - View-having vs View-less; for view-having, list Presentable outputs (Binders) and UI event streams (Observables)
  - Define Listener (child → parent) and Routing methods needed
- Data & dependencies:
  - Data sources/services/workers; concrete protocols to inject; do not pass `*Dependency` to Interactors/ViewControllers
- Navigation & containers:
  - Which container is needed (UINavigationController/UITabBarController)? Confirm explicit DI ownership. If unknown, add [NEEDS CLARIFICATION] and options
- Lifecycle & workers:
  - Long-running streams? Which worker owns them? Note `.disposeOnDeactivate(interactor:)` and `.disposeOnStop(self)` usage
- UI plan & initial data:
  - Minimal ViewState, user actions; mock/sample data if real service isn’t ready
- Parent integration plan:
  - Which parent exposes builders via `*Dependency`, where attach/detach occurs, which Listener callbacks are needed
- Testing strategy:
  - Interactor happy/edge paths; Router attach/detach; ensure `/// sourcery: CreateMock`

## Where to Find Implementation Details

Do not duplicate patterns here. When implementing:

- Read [DOC:IOS_RIBS], especially:
  - Protocol Organization
  - Canonical View-having RIB Example (Presenter pattern)
  - Navigation Controller Access Rules (+ reference patterns)
  - Rx Lifecycle in Interactors/Workers
  - RIB Lifecycle Management (attach/detach)
  - Adding a New RIB (Spec Checklist)

If any rule here conflicts with [DOC:IOS_RIBS], follow this file’s rules and raise a doc issue to reconcile.

## Creating New RIB and Scaffolding (Implementation Steps)

New RIBs are added in a sequence of steps. Create separate tasks for each step in the 'spec.md' file. Refer to [Implementation Steps] section in [DOC:IOS_RIBS] for detailed guidance.
