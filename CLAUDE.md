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

## File Structure

```
Sections/
  Models/       — Domain models and SwiftData cache models
  Services/     — Api, SectionsService, CacheManager, error types
  Mocks/        — MockCacheManager, MockData (previews only)
  UI/
    SectionsView/       — List screen (view, viewmodel, card)
    SectionDetailView/  — Detail screen (view, viewmodel)
```

## Architecture

Layered with manual DI wired in `SectionsApp`:

```
Api → SectionsService → SectionsViewModel → SectionsView
                      → SectionDetailViewModel → SectionDetailView
```

**`Api` / `ApiImpl`** — Network layer. `getSections()` fetches `https://content.viaplay.com/ios-se`, a HAL-style response where sections live under `_links["viaplay:sections"]`. `getSectionDetails(from:)` fetches a section's `cleanHref` URL. `ApiImpl` enforces HTTPS via `validateSecureURL(_:)` and throws `ApiError.insecureURL` for non-HTTPS URLs.

**`SectionsService` / `SectionsServiceImpl`** — Returns `Result<T, SectionsServiceError>` (not throwing). Implements offline-first: on network failure it falls back to the SwiftData cache. Logs cache hits/misses via `os.Logger`.

**`CacheManaging` / `CacheManagingImpl`** — `@ModelActor` actor backed by SwiftData. Caches `[Section]` and `SectionDetailed` with a 24-hour expiration (`TimeInterval.days(1)`). The `ModelContainer` is created in `SectionsApp.init()` and injected here. `MockCacheManager` (in `Mocks/`) is used in Xcode previews.

**`SectionsViewModel`** — `@MainActor ObservableObject`. `ViewState` is `loading | loaded([Section]) | error(String)`. Navigation: `selectedSection: Section?` is set by `selectSection(_:)`; the view calls `makeDetailViewModel(for:)` inside `navigationDestination(item:)` to create the detail VM on demand. The sections grid supports pull-to-refresh.

**`SectionDetailViewModel`** — `@MainActor ObservableObject`, conforms to `Identifiable` and `Hashable` by `section.id`. `ViewState` is `loading | loaded(SectionDetailed) | error(String)`.

**`SectionsView`** — Root view with `NavigationStack`. Uses `navigationDestination(item: $viewModel.selectedSection)` and resolves color/VM lazily in the destination closure. `SectionCard` receives an `onTap` closure.

**`SectionDetailView`** — Takes `color: Color` and `viewModel: SectionDetailViewModel` as `@ObservedObject`. Shows title and description in a color-matched gradient layout.

**Models** (`Models/SectionModels.swift`) — `Section` (API response, `Sendable`), `SectionDetailed` (carries `sectionId`, `title`, `description`; `Sendable`), and the SwiftData models `CachedSection` / `CachedSectionDetail` (`@Model` classes with `cachedAt` timestamps). `Section.cleanHref` strips URI template placeholders using a Swift Regex literal.

## Project Configuration

- **Platform:** iOS and iPadOS 26.1+
- **Bundle ID:** `wilhelm.Sections`
- **Swift version:** 5.0

### Concurrency

`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` is set, meaning all types and functions are implicitly `@MainActor`-isolated unless explicitly annotated otherwise. When adding background work, explicitly mark it `nonisolated` or move it to an `actor`/`Task { await ... }` on a non-main executor.

`SWIFT_APPROACHABLE_CONCURRENCY = YES` is also enabled, which relaxes some strict concurrency checking to reduce annotation noise.
