# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**MyInternLog** — an iPhone-first SwiftUI app that helps interns capture what they learn, review it later, generate weekly recaps, and create career-ready summaries. Built primarily for use during an AFRL internship, with fellow college interns as secondary users.

**Success metric:** Use the app daily throughout AFRL and generate a detailed timeline of what was learned and accomplished.

### MVP Features
- Quick Notes
- Study Queue
- Weekly Recaps
- Search

## Tech Stack

- **SwiftUI** — UI framework
- **SwiftData** — local-only persistence (no backend)
- **MVVM** — architectural pattern
- iPhone-first; no iPad/macOS targets in scope

## Build & Run

Open and run from Xcode (primary workflow):
```
open MyInternLog.xcodeproj
```

Build from the command line (replace destination as needed):
```bash
xcodebuild -project MyInternLog.xcodeproj -scheme MyInternLog -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Run tests:
```bash
xcodebuild -project MyInternLog.xcodeproj -scheme MyInternLog -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Architecture

- **SwiftUI** app lifecycle via `@main MyInternLogApp` (`MyInternLogApp.swift`)
- Entry point renders `ContentView` inside a `WindowGroup`
- MVVM: Views own no business logic; ViewModels mediate between Views and SwiftData models
- `MyInternLog/` contains all source files; Xcode uses file-system synchronized groups (no manual `.pbxproj` edits needed when adding/removing files in that folder)

## Current Milestone

**Create `QuickNote` and `StudyItem` SwiftData models.**

Work only on what is needed for this milestone. Do not add features or abstractions beyond it.

## Development Philosophy

- Keep code beginner-friendly — prefer clarity over cleverness
- Add a short comment explaining *why* for any non-obvious architectural decision
- Make small, focused commits
- Prefer simple solutions; do not overbuild

## Xcode Project Notes

- `objectVersion = 77` — Xcode 16+
- No Swift packages or third-party dependencies yet
- `.xcuserstate` is gitignored; don't commit it
