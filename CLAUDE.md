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

**`Api` / `ApiImpl`** — Network layer. `getSections()` fetches `https://content.viaplay.com/ios-se`, a HAL-style response where sections live under `_links["viaplay:sections"]`. `getSectionDetails(from:)` fetches a section's `cleanHref` URL and decodes `SectionDetailed`. Throws `ApiError` on failure.

**`SectionsService` / `SectionsServiceImpl`** — Thin layer over `Api` that translates `ApiError` into `SectionsServiceError`. `getSectionDetails(for:)` uses `section.cleanHref` (URI template placeholders stripped) to build the detail URL.

**`SectionsViewModel`** — `@MainActor ObservableObject` driving `SectionsView`. `ViewState` is `loading | loaded | error(String)`.

**`SectionDetailViewModel`** — Same pattern as above, but drives `SectionDetailView`. `ViewState.loaded` carries a `SectionDetailed` value.

**`SectionsView`** — Root view. Renders a `LazyVGrid` of `SectionCard`s; each card is wrapped in a `NavigationLink` that pushes `SectionDetailView`. The service passed to `SectionDetailView` is instantiated inline (`SectionsServiceImpl(api: ApiImpl())`), not from the parent ViewModel.

**`SectionDetailView`** — Detail screen pushed via `NavigationStack`. Shows `SectionDetailed.title` and `.description` in a card layout with a color-matched gradient background.

**Models** — `Section` is decoded from the list API. `SectionDetailed` (`title`, `description`) is decoded from a section's detail URL. `Section.cleanHref` strips URI template syntax (`{param}`) from `href`.

## Project Configuration

- **Platform:** iOS and iPadOS 26.1+
- **Bundle ID:** `wilhelm.Sections`
- **Swift version:** 5.0

### Concurrency

`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` is set, meaning all types and functions are implicitly `@MainActor`-isolated unless explicitly annotated otherwise. When adding background work, explicitly mark it `nonisolated` or move it to an `actor`/`Task { await ... }` on a non-main executor.

`SWIFT_APPROACHABLE_CONCURRENCY = YES` is also enabled, which relaxes some strict concurrency checking to reduce annotation noise.
