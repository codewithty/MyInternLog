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

**Only remaining gap: a real XCTest target.**

Completed (models): QuickNote, StudyItem, Reflection, ReflectionAnswer, AttachmentItem,
DailyLog, InternshipProfile, Milestone, ReminderSetting, CareerOutput, Tag, KnowledgeItem,
ProjectGroup, WeeklyRecap.

Completed (features): Quick Notes (tags, skills/tools/concepts, project group, highlight,
camera/photo/PDF attachments), Study Queue, Weekly Recap ("wrapped" — top skills, biggest
win, common theme, blockers, study items, photos), Daily Reflections (editable prompts,
template switching, mood/confidence/energy/stress sliders, local non-AI "Suggest Draft"
summary builder with optional per-field approval), Search (notes/study items/reflections/
attachments/milestones/career outputs, filters, recent searches), Home dashboard, first-run
Setup, Settings, About, Calendar/Milestones (month grid, day detail, milestone reminders),
Dashboard (date-range picker, entries/wins/streak/mood/confidence/energy/stress trend
charts), Gallery, Project Groups management, Reminders & local notifications (including
tap-to-deep-link into Quick Capture or Reflection), Entries/Archive, AI prompt export
(daily/weekly/resume-with-styles/interview/LinkedIn/end-of-internship) + Career Outputs
(grouped by target role), PDF export (3 templates, export toggles, cover page, page
numbers, preview/sanitize step), End-of-Internship Summary, sample data for previews.
Editing and deletion now exist throughout: Quick Notes (full editor + delete), Study Items
(edit + delete), Milestones (edit + delete), Career Outputs (edit text/role/favorite +
delete), Attachments (caption/notes editing + delete) — all via tap-to-edit and
swipe-to-delete.

Simplifications made deliberately (not full MVP.md literalism, to avoid overbuilding):
- Highlights are a `HighlightType` enum directly on QuickNote, not a separate polymorphic
  model attached to DailyLog/QuickNote/AttachmentItem/StudyItem/CareerOutput.
- New skill/tool/concept entries default to `.concept` category rather than prompting the
  user to categorize on the fly.

Not yet done:
- A real XCTest target (needs to be added via Xcode's GUI — New Target > Unit Testing
  Bundle — since neither hand-editing project.pbxproj nor the `pbxproj` Python library
  can safely construct a full native-target object graph blind). DashboardStats,
  DateHelpers, WeeklyRecapBuilder, and SummaryDraftBuilder are all pure, dependency-free
  functions, ready to test once a target exists.

## Known development gotcha

If you change SwiftData model relationships/properties significantly across a session, the
simulator's on-disk store (created earlier in the session with an older schema shape) can
get out of sync — inserts silently vanish after the sheet dismisses instead of persisting,
because SwiftData's automatic lightweight migration doesn't handle every kind of change.
**Fix:** `xcrun simctl uninstall <device> ty.MyInternLog` then reinstall/relaunch. This is
expected during active development, not a code bug — confirmed by reproducing the failure
on the stale store and then verifying identical code saves correctly against a fresh one.

## Known testing-tool limitation (Claude Code's iOS Simulator control)

Taps/swipes on rows *inside a SwiftUI `List`* did not register when driven through the
automated simulator tool — this reproduced even on a completely unmodified, pre-existing
`Button` (the StudyItem checkbox) as well as `NavigationLink` and `onTapGesture` List rows.
Every non-List interaction in the same sessions (sheets, Form fields, toolbar buttons,
LazyVGrid tiles, tab bar, pickers) worked reliably. So: List-hosted row interactions
(tap-to-edit, swipe-to-delete) are implemented per the code review but not confirmed via
automated tap — verify those manually in Xcode's own simulator before trusting them blind.

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

Project setup, GitHub setup, CLAUDE.md
All models and features listed under "Current Milestone" above

Current Goal:
Build the smallest useful version of MyInternLog before AFRL begins on June 22. That
goal has been substantially exceeded in scope — nearly every screen and feature in
docs/MVP.md now exists and works. Remaining backlog is listed under "Current
Milestone" above (just the XCTest target).

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
