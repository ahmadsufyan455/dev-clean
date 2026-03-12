# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
# Build (CLI)
xcodebuild -scheme devclean -destination 'platform=macOS' build

# Clean build
xcodebuild -scheme devclean -destination 'platform=macOS' clean build

# Open in Xcode
open devclean.xcodeproj
```

There are no automated tests yet. The app must be run from Xcode (`⌘R`) to verify UI changes.

## Architecture

MVVM + Service layer. The dependency graph is: `View → ViewModel → Service → FileSystem`.

### Dependency Injection
`AppContainer` (Core/DI) is created once in `devcleanApp.swift` and injected into the SwiftUI environment. It owns all service singletons and vends ViewModels via `lazy var`. To swap a service for a mock, change its concrete type in `AppContainer`.

### State Machine
`DashboardViewModel` drives the entire dashboard via `DashboardState`:
```
idle → scanning(progress, currentCategory) → scanned → cleaning(progress) → complete(totalFreed)
                                                                           ↘ scanned (if items remain)
```
The `statePanel` in `DashboardView` switches on this state to render the correct panel.

### Scanning
`DiskScannerService.scanTopLevel()` is the primary scan method. It reads **only immediate children** of each target path and computes recursive size per child via `directorySize()`. This produces one `DiskItem` per project/module folder rather than per file. Results are sorted largest-first.

### Paths
`DevPaths.swift` (Core/Constants) is the single source of truth for all filesystem paths. No path strings exist elsewhere in the codebase. All paths use `~` and are expanded at runtime via `PathHelper.expand()`.

### Key files by concern
| Concern | File |
|---|---|
| All target paths | `Core/Constants/DevPaths.swift` |
| App-level DI | `Core/DI/AppContainer.swift` |
| Dashboard state + scan/clean orchestration | `ViewModels/DashboardViewModel.swift` |
| File system traversal | `Services/DiskScannerService.swift` |
| File deletion / trash | `Services/CleaningService.swift` |
| Running IDE detection | `Services/AppDetectionService.swift` |
| Real disk usage query | `Services/StorageInfoService.swift` |
| Scan results UI (tool cards, warning banner) | `Views/Components/ScanResultsView.swift` |
| Settings toggles | `ViewModels/SettingsViewModel.swift` |

## Important Constraints

- **App Sandbox is disabled** (`ENABLE_APP_SANDBOX = NO` in project.pbxproj). This is intentional — the app needs broad filesystem access to scan `~/Library`, `~/.gradle`, etc. Do not re-enable it.
- All ViewModels are `@Observable @MainActor`. Never mutate ViewModel state from a background thread.
- Services are `Sendable` and run work in `Task.detached`. Progress callbacks are `@Sendable` closures.
- `ByteFormatter` and `PathHelper` are stateless enums with static methods — do not instantiate them.
- The `Color(hex:)` initialiser lives in `Utilities/Color+Hex.swift` and is used throughout all views.
