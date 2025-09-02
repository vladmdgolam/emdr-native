# Repository Guidelines

## Project Structure & Module Organization
- Root iOS app lives in `emdr/`.
- Xcode project: `emdr/emdr.xcodeproj`.
- App sources: `emdr/emdr/` (e.g., `emdrApp.swift`, `ContentView.swift`).
- Assets: `emdr/emdr/Assets.xcassets`.
- Tests (if added): `emdr/emdrTests/` (unit) and `emdr/emdrUITests/` (UI).

## Build, Test, and Development Commands
- Open in Xcode: `xed emdr/emdr.xcodeproj`
- Build (Simulator example):
  - `xcodebuild -project emdr/emdr.xcodeproj -scheme emdr -destination 'platform=iOS Simulator,name=iPhone 15' build`
- Run tests (none present yet):
  - `xcodebuild -project emdr/emdr.xcodeproj -scheme emdr -destination 'platform=iOS Simulator,name=iPhone 15' test`
- Run on device/simulator via Xcode: select the target and press Run (⌘R).

## Coding Style & Naming Conventions
- Follow Swift API Design Guidelines and SwiftUI idioms.
- Indentation: 4 spaces; keep lines under ~120 chars.
- Naming: `UpperCamelCase` for types/files, `lowerCamelCase` for vars/functions, `SCREAMING_SNAKE_CASE` for constants if appropriate.
- Structure SwiftUI views by feature; keep view state minimal and localized.
- Use `// MARK:` to group extensions and sections.

## Testing Guidelines
- Preferred frameworks: XCTest for unit tests, XCUITest for UI flows.
- Place tests under `emdr/emdrTests` with names ending in `Tests` (e.g., `ContentViewTests.swift`).
- Keep tests deterministic; avoid implicit timing—use expectations where needed.
- Target ≥80% coverage on new code; include edge cases for animation/config logic.

## Commit & Pull Request Guidelines
- Commits: small, focused, well-titled. Use Conventional Commits where possible (e.g., `feat: add speed control`, `fix: correct animation timing`).
- PRs: include a clear description, linked issues, and screenshots/screen recordings for UI changes.
- Checklist: builds cleanly, no new warnings, updated docs, and tested on at least one iPhone simulator size.

## Architecture Overview & Tips
- Entry point: `emdrApp` launches `ContentView` (SwiftUI).
- Keep animation parameters configurable; prefer `.linear` for constant velocity where appropriate.
- Do not commit secrets; this app has no runtime secrets—keep it that way.
