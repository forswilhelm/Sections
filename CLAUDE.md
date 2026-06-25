# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

Build for simulator:
```
xcodebuild -project Sections.xcodeproj -scheme Sections -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Run tests (once a test target exists):
```
xcodebuild -project Sections.xcodeproj -scheme Sections -destination 'platform=iOS Simulator,name=iPhone 16' test
```

The project is primarily developed through Xcode. New Swift files added to the `Sections/` directory are picked up automatically — the project uses `PBXFileSystemSynchronizedRootGroup`, so the `.pbxproj` does not need to be manually edited when adding or removing source files.

## Architecture

The app follows a layered architecture with manual dependency injection wired in `SectionsApp`:

```
Api (protocol/impl) → SectionsService (protocol/impl) → SectionsViewModel → SectionsView
```

**`Api` / `ApiImpl`** — Fetches from `https://content.viaplay.com/ios-se`. The response is a HAL-style JSON where sections are nested under `_links["viaplay:sections"]`. `ApiImpl` decodes this into `[Section]` and throws `ApiError` on network or HTTP failures.

**`SectionsService` / `SectionsServiceImpl`** — Thin layer over `Api` that translates `ApiError` into `SectionsServiceError`. Exists to decouple the ViewModel from API-level error types.

**`SectionsViewModel`** — `@MainActor ObservableObject` with a `ViewState` enum (`loading`, `loaded`, `error`). Drives the view via `@Published` properties.

**`SectionsView`** — Switches on `viewState` to render a loading spinner, a `LazyVGrid` of `SectionCard`s, or an error view with a retry button. The ViewModel is injected via `init` and held as `@StateObject`.

**`Section`** — The core model, decoded from the API. `cleanHref` strips URI template placeholders (`{param}`) from `href` for use in navigation.

## Project Configuration

- **Platform:** iOS and iPadOS 26.1+
- **Bundle ID:** `wilhelm.Sections`
- **Swift version:** 5.0

### Concurrency

`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` is set, meaning all types and functions are implicitly `@MainActor`-isolated unless explicitly annotated otherwise. When adding background work, explicitly mark it `nonisolated` or move it to an `actor`/`Task { await ... }` on a non-main executor.

`SWIFT_APPROACHABLE_CONCURRENCY = YES` is also enabled, which relaxes some strict concurrency checking to reduce annotation noise.
