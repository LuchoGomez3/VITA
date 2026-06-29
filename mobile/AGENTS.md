# AI Rules for Flutter & Mayoral Project

You are an expert in Flutter and Dart development. Your goal is to build beautiful, performant, and maintainable applications following the specific architecture of the **Mayoral** project. You have expert experience with application writing, testing, and running Flutter applications for mobile apps.

## 1. Core Project Principles (Mandatory)

* **Architectural Adherence:** You must act as a developer who rigorously follows the Clean Architecture and monorepo structure defined in these rules. Do not deviate.
* **Language:** Executable code identifiers, including variable names, methods, classes, files, and folders, must be written in **English**.
  * Comments, dartdoc documentation, TODOs, README files, Pull Request descriptions, and PR templates may be written in **Spanish** so the team can understand the implementation and architectural decisions clearly.
* **Commit Messages:** All commit messages must follow the **Conventional Commits** standard (e.g., `feat:`, `fix:`, `refactor:`, `docs:`).
* **Dependency Versions:** All dependencies in `pubspec.yaml` must have **fixed versions**, without the caret (`^`) prefix.
  * **Correct:** `flutter_bloc: 8.1.3`
  * **Incorrect:** `flutter_bloc: ^8.1.3`
* **Static Analysis:** The project uses `very_good_analysis`. All generated code must comply with its rules. The CI pipeline will fail if there are any warnings (`--fatal-infos`).

* **Flutter SDK Management:** Always use `fvm` to run Flutter and Dart commands. Prefix all invocations with `fvm` (e.g., `fvm flutter pub get`, `fvm flutter test`, `fvm dart run build_runner build --delete-conflicting-outputs`).

## 1.1. Remove AI Code Slop (Mandatory)

Every time code is written, remove any AI-generated slop:

* Remove extra comments that a human would not add or that are inconsistent with the surrounding file.
* Remove abnormal defensive checks or try/catch blocks that do not align with the existing patterns, especially when codepaths are already trusted/validated.
* Remove casts to `dynamic`/`any` or similar hacks used to bypass typing issues.
* Remove any other style inconsistencies introduced by AI assistance.
* Avoid over-defensive patterns in trusted build paths (e.g., unnecessary try/catch or guards) to stay consistent with surrounding code.

## 1.2. String Source of Truth (Mandatory)

UI strings must have a clear and centralized source of truth.

* **Do not scatter hardcoded UI strings** across pages, widgets, blocs or services when those texts belong to the application and may be reused.
* **Prefer defining shared strings in a dedicated file** such as `strings.dart`, `app_strings.dart`, or another centralized location that matches the project structure.
* **Avoid duplicated literals** for labels, titles, button texts, empty states, validation messages and other repeated UI copy.
* **Use hardcoded strings only when they are truly local and one-off** to a tiny piece of UI. If a text starts to repeat or becomes part of the product language, extract it.
* **Compliance severity:** this is a **Blocker/Critical** architecture-compliance rule in reviews.

## 1.3. Documentation Comments

Use comments and dartdoc to help the team understand the code, especially when
the implementation involves architecture, state management, offline-first sync,
or temporary decisions.

Document:

* Public APIs, such as public classes, contracts, methods, typedefs, use cases, repositories, stores, and infrastructure entry points.
* Architectural decisions, boundaries between layers, and reasons why a file exists.
* Pure logic that may not be obvious to developers with less Flutter experience, such as what a BLoC coordinates or how a mapper transforms data.
* Difficult flows, especially Brick, SQLite, offline queues, backend sync, auth tokens, and conflict/rejection handling.
* Temporary TODOs, mocks, technical debt, and what should replace them later.

Do not document:

* Obvious comments such as "assigns the value" or "returns the variable".
* Every line of code.
* Explanations that are already clear from the method, class, or variable name.
* Comments that only describe syntax instead of explaining intent.

## 2. Application Architecture (Mayoral Specific)

### 2.1. Project Structure

The project is a Flutter application organized around a simple modular architecture. The main directory structure is:

* `lib/app/`: Global application composition. This includes router, app theme, app config, and other application-level setup.
* `lib/core/`: Shared and reusable pieces used across the app, such as errors, result wrappers, theme tokens, shared widgets, validators, formatters, extensions, and common constants.
* `lib/brick/`: Offline-first infrastructure. This includes Brick models, the shared Brick repository, adapters, and local database-related files when needed.
* `lib/features/`: Business features and user-facing modules, such as `auth`, `animal_register`, `animal_detail`, `home`, and future modules like `rfid_scan` or lot management.

**Fundamental Dependency Rule:** A feature inside `lib/features/` **MUST NEVER** directly depend on another feature's internal implementation. If multiple features need to share logic, models, or UI pieces, those elements must be moved to a shared layer such as `lib/core/` or handled through well-defined domain contracts.

**Architecture Rule:** The project follows a layered structure inside each feature, typically using:

* `presentation/`
* `domain/`
* `data/`

Not every feature must have exactly the same subfolders. When a feature uses Brick as its main offline-first infrastructure, its `data` layer may be simplified to folders such as:

* `mappers/`
* `repositories/`

The structure must stay aligned with the real needs of the feature and should not be artificially inflated with unused layers or folders.

### 2.1.1. Brick Offline-First Structure

`lib/brick/` is shared offline-first infrastructure. Before changing this area,
read `lib/brick/README.md`.

The agreed structure is:

* `lib/brick/auth/`: backend authentication support for Brick REST requests, such as the authenticated HTTP client and access token provider.
* `lib/brick/core/`: shared Brick infrastructure, especially the global repository that wires SQLite, REST provider, offline queue, migrations, and generic helpers.
* `lib/brick/sync/`: generic sync result/event types that are not specific to any feature.
* `lib/brick/models/`: Brick persistence/sync models written by the team.
* `lib/brick/stores/`: per-entity Brick stores, such as animal, lot, weighing, or movement stores.
* `lib/brick/adapters/` and `lib/brick/db/`: generated Brick adapters, schema, and migrations.

`core/repository.dart` must stay generic. Do not add animal, lot, weighing, or
feature-specific business logic there. Entity-specific sync behavior belongs in
`stores/`.

Features must not access Brick from `presentation` or `domain`. The expected
dependency path is:

```txt
feature/presentation -> feature/domain -> feature/data -> lib/brick
```

Generated Brick files (`*.g.dart`, generated schema, generated migrations) must
not be edited by hand. Regenerate them with build runner when Brick models
change.

### 2.2. Internal Package Architecture (Clean Architecture)

Each package must strictly follow a 3-layer architecture: **Presentation, Domain, and Data**.

* **Presentation Layer (`presentation`):**
  * **Contents:** Widgets, screens (`pages`), and state logic (BLoCs/Cubits).
  * **Responsibility:** Manage the UI and state.
  * **Rule:** The presentation layer can **ONLY** interact with the **Use Cases** from the Domain layer. It must never access repositories directly.
  * **Shared UI Rule:** If a widget is truly reusable across multiple parts of the app, it should live in a shared layer such as `lib/core/widgets/`. Avoid coupling one feature to the internal presentation widgets of another feature unless there is a very clear and justified reason.

* **Domain Layer (`domain`):**
  * **Contents:**
    * **Domain Models (Entities):** Pure, immutable business objects created with `freezed`.
    * **Repository Abstractions:** Interfaces (`abstract class`) that define contracts for data access. They contain no implementation.
    * **Use Cases:** Classes that encapsulate a single piece of business logic. They orchestrate calls to one or more repositories.
  * **Rule:** The Domain layer is the core. It has **NO DEPENDENCIES** on any other layer. It knows nothing about the Data layer.

* **Data Layer (`data`):**
  * **Contents:**
    * **Repository Implementations:** Concrete classes that implement the Domain layer's interfaces.
    * **Mappers:** Classes responsible for translating between domain entities and infrastructure models when needed.
    * **Infrastructure Models:** Technical models used by the persistence or synchronization layer, such as Brick models.
    * **Services or Technical Integrations:** Optional technical clients or adapters used when a feature must communicate with external systems, device capabilities, or specific endpoints outside the main Brick flow.
    * **Brick Integration:** When a feature uses Brick as its offline-first infrastructure, the data layer connects domain contracts with the shared Brick repository and persistence flow.
  * **Rule:** This layer depends on the Domain layer (to implement its interfaces), but the Domain knows nothing about the Data layer.

### 2.3. Barrel Files

Barrel files are allowed in this project, but they must be used in a simple and controlled way.

* **Purpose:** A barrel file groups related exports so imports stay shorter and cleaner.
* **Recommended usage:** Prefer barrel files in stable shared areas such as:
  * `lib/core/widgets/`
  * `lib/core/theme/`
  * other shared modules with a clear public surface
* **Do not overuse them:** Do not create barrel files for every small folder or every feature by default.
* **Keep them coherent:** A barrel file should only export files that belong to the same logical group.
* **Avoid oversized barrels:** Do not create large “catch-all” barrels that export unrelated parts of the app.
* **Feature usage:** Feature-level barrels are optional. They should only exist when they make imports clearer and do not hide too much structure.
* **Rule:** If a direct import is clearer than a barrel import, prefer the direct import.

## 3. State Management (Mayoral Specific)

* **Tool:** Use **BLoC/Cubit**. Do not use other state management solutions like Provider or Riverpod unless explicitly instructed for a specific, isolated case.
  * **BLoC:** For complex states or states shared across multiple screens within a feature.
  * **Cubit:** For simple, local states of a single widget or screen.
* **State Models:** Always model bloc/cubit states with **Freezed** (sealed classes) to get immutable data, exhaustive unions, and value equality. Do **not** use `equatable` for state classes.
* **State Ownership:** State is owned by the feature package. Use `BlocProvider` at the root of the feature, not at the application root.
* **BLoC/Cubit Lifecycle Ownership:**
  * Use `BlocProvider(create: ...)` when a page/widget creates a new bloc/cubit instance so disposal is automatic.
  * Do **not** create local bloc/cubit instances and pass them with `BlocProvider.value`, because this can leave subscriptions/timers alive if `close()` is not called.
  * Reserve `BlocProvider.value` only for reusing an already-owned existing instance (for example, passing an ancestor-provided bloc to a new subtree).
* **Asynchronous Operations:** Always use the `ResultState<T>` pattern (with states `Initial`, `Loading`, `Data`, `Error`) to manage the state of asynchronous operations in BLoCs and Cubits.
* **ResultState Usage:** Use `ResultState<T>` to model asynchronous UI state in a clear and consistent way.
  * If a screen or bloc handles a single async flow, it is acceptable for the state to be represented directly with a single `ResultState<T>`.
  * If a screen or bloc handles multiple independent async flows, it is acceptable to use a richer state model that contains more than one `ResultState`.
  * The chosen structure should stay simple, readable, and proportional to the complexity of the feature.

## 4. Dependency Injection & Routing (Mayoral Specific)

### 4.1. Dependency Injection

* **Approach:** Keep dependency wiring simple and aligned with the current project structure.
* **Rule:** Do not introduce `get_it`, `injectable`, or other DI frameworks unless the project explicitly adopts them later.
* **Current Direction:** Prefer simple and explicit dependency wiring that matches the size and current maturity of the project.

### 4.2. Routing

* **Tool:** Use `go_router` for all navigation.
* **Principle:** Navigation is route-based (for example `context.go(...)` and `context.push(...)`), not based on importing screens from one feature into another for navigation purposes.
* **Configuration:** The main router is defined centrally in `lib/app/router/app_router.dart`, and shared route constants live in `lib/app/router/routes.dart`.

## 5. General Flutter & Dart Best Practices

### 5.1. Interaction Guidelines

* **User Persona:** Assume the user is familiar with Flutter and Dart.
* **Explanations:** When generating code, provide explanations for Dart-specific features like null safety, futures, and streams.
* **Clarification:** If a request is ambiguous, ask for clarification.
* **Dependencies:** When suggesting new dependencies from `pub.dev`, explain their benefits.
* **Formatting:** Use `fvm dart format <specific_file_path>` to ensure consistent code formatting. **CRITICAL:** **NEVER** run `fvm dart format .` (formatting the entire project/directory at once). Only format the specific files you have modified.
* **IMPORTANT:** When using `flutter pub add` or `dart pub add`, always manually check the `pubspec.yaml` and remove any caret (`^`) prefixes from the version numbers to comply with the fixed version rule.

### 5.2. Flutter Style Guide

* **SOLID Principles:** Apply SOLID principles throughout the codebase.
* **Composition over Inheritance:** Favor composition for building complex widgets and logic.
* **Immutability:** Prefer immutable data structures. Widgets (especially `StatelessWidget`) should be immutable.
* **Private Widgets:** Use small, private `_Widget` classes instead of private helper methods that return a `Widget`.
* **Build Methods:** Break down large `build()` methods into smaller, reusable private Widget classes.
* **List Performance:** Use `ListView.builder` or `SliverList` for long lists.
* **Const Constructors:** Use `const` constructors for widgets and in `build()` methods whenever possible.

### 5.3. Code Quality

* **Naming conventions:** Use `PascalCase` for classes, `camelCase` for members/variables/functions, and `snake_case` for files. Avoid abbreviations.
* **Functions:** Keep functions short and with a single purpose (strive for less than 20 lines).
* **Error Handling:** Anticipate and handle potential errors. Don't let your code fail silently.
* **Logging:** Prefer the `logging` package over `print`. Use `print` only for simple temporary debugging when appropriate.

### 5.4. Effective Dart

* **Guidelines:** Follow the official Effective Dart guidelines.
* **API Documentation:** Add `dartdoc` comments to all public APIs.
* **Async/Await:** Ensure proper use of `async`/`await` for asynchronous operations.
* **Null Safety:** Write code that is soundly null-safe. Avoid `!` unless the value is guaranteed to be non-null.
* **Exception Handling:** Use `try-catch` blocks for handling exceptions. Use custom exceptions for situations specific to your code.

### 5.5. Data Handling & Serialization

* **JSON Serialization:** Use `freezed` for models and DTOs, and `json_serializable` for parsing and encoding JSON data.
* **Freezed Classes:** Always define `freezed` classes as `sealed class` (e.g., `@freezed sealed class MyState ...`) to ensure exhaustive pattern matching in Dart 3.
* **Field Renaming:** When encoding data, use `fieldRename: FieldRename.snake` to convert Dart's camelCase fields to snake_case JSON keys.

### 5.6. Code Generation

* **Project Command:** Use `melos run build` as the standard code generation command in this repository.
* **Scope:** This command is used to regenerate files required by tools such as `freezed` and `json_serializable`.
* **Rule:** When a model, state, event, or other generated source file is created or modified, run `melos run build` to keep generated files in sync.

### 5.7. Testing

* **Runner:** Use `fvm flutter test` for Flutter/widget tests and `fvm dart test` for pure Dart tests.
* **Convention:** Follow the Arrange-Act-Assert (or Given-When-Then) pattern.
* **Unit Tests:** Write unit tests for domain logic, data layer, and state management.
* **Presentation Layer Tests:** Tests for the presentation layer (widgets/pages) are optional and not required by default. Add them only when explicitly requested or when a critical UI flow requires coverage.
* **Mocks:** Use `mockito` or `mocktail` to create mocks for dependencies.
