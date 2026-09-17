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

**Add Tags/Skills/Project Groups, a local (non-AI) summary draft builder, and a real XCTest target.**

Completed (models): QuickNote, StudyItem, Reflection, ReflectionAnswer, AttachmentItem,
DailyLog, InternshipProfile, Milestone, ReminderSetting, CareerOutput.

Completed (features): Quick Notes, Study Queue, Weekly Recap, Daily Reflections, photo
import, Search, Home dashboard (with quick capture + launch tiles), first-run Setup,
Settings, About, Calendar/Milestones (custom month grid), Dashboard (streak/stats/chart),
Gallery, Reminders & local notifications, Entries/Archive, AI prompt export + Career
Outputs, PDF export (Core Text pagination, share sheet).

Not yet done (tracked as backlog, deliberately deferred — see docs/MVP.md for full detail):
- Tags / Skills-Tools-Concepts / Project Groups / Highlights as their own reusable,
  cross-cutting models (today there's only a single `NoteTag` category per QuickNote)
- Local (non-AI) summary draft builder that pre-fills reflection prompts from existing notes
- End-of-internship summary screen
- Sample/mock data for SwiftUI previews
- A real XCTest target (needs to be added via Xcode's GUI — New Target > Unit Testing
  Bundle — since hand-editing project.pbxproj to add a target is unsafe to do blind).
  DashboardStats and DateHelpers are already written as pure, dependency-free functions
  so they're ready to test once a target exists.

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
SwiftData models (QuickNote, StudyItem, Reflection, ReflectionAnswer, AttachmentItem,
DailyLog, InternshipProfile, Milestone, ReminderSetting, CareerOutput)
Quick Notes feature
SwiftData persistence verified
Study Queue feature
Tab navigation
Weekly Recap view
Daily Reflections feature
Photo import (PhotosPicker, library only)
DailyLog linking (QuickNote, Reflection, AttachmentItem share one log per date)
Search (notes, study items, reflections)
First-run Setup flow (skippable) + Settings + About
Home dashboard tab (quick capture, recent activity, launch tiles)
Calendar/Milestones (custom month grid, day detail, milestone creation)
Dashboard (streak, weekly entries, open study items, wins, 7-day chart)
Gallery (attachment grid + zoomable viewer)
Reminders & local notifications (off by default, permission requested on opt-in)
Entries/Archive (grouped by week/month)
AI prompt export (manual copy/paste) + Career Outputs
PDF export (journal report, share sheet)

Current Goal:
Build the smallest useful version of MyInternLog before AFRL begins on June 22. That
goal has been substantially exceeded in scope — nearly every major area from
docs/MVP.md now has a working screen. Remaining backlog is listed under "Current
Milestone" above.

Current MVP Priority Order:

Quick Notes ✅
Study Queue ✅
Tab Navigation ✅
Weekly Recaps ✅
Search ✅

Everything else should be considered future work unless explicitly requested.

Development Workflow

Default mode — for every milestone:

Explain the milestone
Explain the files involved
Explain why they are needed
Wait for approval
Make the changes
Explain how to test
Suggest a commit message

Do not automatically start the next milestone after completion.

Batch mode: when the user explicitly asks to work through multiple milestones in one session (e.g. "work on everything"), the approval gate between milestones is skipped for that session. Each milestone should still land as its own focused commit with a clear message, and progress should still be reported as it happens. Return to default mode once the batch request is done.
