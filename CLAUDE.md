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

**Build the Study Queue feature.**

Completed:
- QuickNote model
- StudyItem model
- Quick Notes feature

Current focus:
- Study Queue

## Development Philosophy

- Keep code beginner-friendly — prefer clarity over cleverness
- Add a short comment explaining *why* for any non-obvious architectural decision
- Make small, focused commits
- Prefer simple solutions; do not overbuild

## Xcode Project Notes

- `objectVersion = 77` — Xcode 16+
- No Swift packages or third-party dependencies yet
- `.xcuserstate` is gitignored; don't commit it


Important Project Documents

Before proposing architecture, features, or major changes, read:

CLAUDE.md
docs/MVP.md

The MVP describes the long-term vision for MyInternLog.

Do NOT attempt to build the full MVP at once.

Always prioritize:

Small focused milestones
Beginner-friendly code
Features needed before AFRL starts
Working software over architecture discussions
One feature at a time
Current Project Status

Completed:

Project setup
GitHub setup
CLAUDE.md
SwiftData models (QuickNote, StudyItem)
Quick Notes feature
SwiftData persistence verified

Current Goal:
Build the smallest useful version of MyInternLog before AFRL begins on June 22.

Current MVP Priority Order:

Quick Notes ✅
Study Queue
Tab Navigation
Weekly Recaps
Search

Everything else should be considered future work unless explicitly requested.

Development Workflow

For every milestone:

Explain the milestone
Explain the files involved
Explain why they are needed
Wait for approval
Make the changes
Explain how to test
Suggest a commit message

Do not automatically start the next milestone after completion.
