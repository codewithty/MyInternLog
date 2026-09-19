# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**MyInternLog** — an iPhone-first SwiftUI app that helps interns capture what they learn, review it later, generate weekly recaps, and create career-ready summaries. Built primarily for use during an AFRL internship, with fellow college interns as secondary users.

**Success metric (original):** Use the app daily throughout AFRL and generate a detailed timeline of what was learned and accomplished. The AFRL internship has ended, so the current goal is a beta with outside testers (see Current Milestone).

### MVP Features
- Quick Notes
- Study Queue
- Weekly Recaps
- Search

## Tech Stack

- **SwiftUI** — UI framework
- **SwiftData** — local-only persistence (no backend)
- **MVVM** — architectural pattern
- iPhone-only for Version 1 (target device: iPhone 17 Pro, iOS 26.0+); no iPad/macOS targets

## Build & Run

Open and run from Xcode (primary workflow):
```
open MyInternLog.xcodeproj
```

Build from the command line (replace destination as needed):
```bash
xcodebuild -project MyInternLog.xcodeproj -scheme MyInternLog -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Run tests (42 unit tests in `MyInternLogTests/`, covering streaks, month grid, weekly recap, summary drafts, week numbers, reminders, search filters, AI prompt privacy, data export, and demo data):
```bash
xcodebuild -project MyInternLog.xcodeproj -scheme MyInternLog -destination 'platform=iOS Simulator,name=iPhone 17' test
```

## Architecture

- **SwiftUI** app lifecycle via `@main MyInternLogApp` (`MyInternLogApp.swift`)
- Entry point opens the real `ModelContainer` once (`AppSchema.makeRealContainer()`) and renders `RootView` inside a `WindowGroup`; `RootView` picks the real store or demo mode's in-memory `SampleData` store, then shows `ContentView`
- `AppSchema.models` is the single list of SwiftData models (app, demo mode, and tests all use it)
- MVVM: Views own no business logic; ViewModels mediate between Views and SwiftData models
- `MyInternLog/` contains all source files; Xcode uses file-system synchronized groups (no manual `.pbxproj` edits needed when adding/removing files in that folder)

## Current Milestone

**No open functional gaps against docs/MVP.md. The "Visual And UX Direction" section (dark by default, subtle cosmic theme, semantic colors) is NOT built yet: the visual design pass is next, waiting on the user's direction. Also open: manual device testing, the app icon (waiting on artwork), and the distribution decision.**

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

Beta readiness (the original AFRL internship has ended, so the next step is outside testers): deployment
target iOS 26.0, portrait-only, generic "School Presentation" labels, Settings → Export All Data
(JSON, via `DataExporter`; photos/PDFs excluded, not re-importable yet), Demo mode (Settings toggle;
`DemoMode` + `RootView` swap to `SampleData`'s in-memory store, so it can never touch real data; not
saved between launches), and a first-run privacy/confidentiality notice (`PrivacyNotice`). Still open,
and only needed to upload to TestFlight (which needs the paid Apple Developer Program — undecided):
app icon (waiting on artwork), privacy manifest (`@AppStorage` needs a UserDefaults reason),
export-compliance flag, privacy policy URL.

Wording policy: user-facing text is role-neutral so the app works for an internship, co-op, research
role, or job (setup says "About Your Role", the end summary is "Wrap-Up", the Dashboard range is
"Year", the default project group is "General"). The app name stays MyInternLog. Change labels, not
identifiers: `InternshipProfile`, `MilestoneType.internshipStart`, `CareerOutputType.endOfInternshipSummary`
and similar are stored values, so renaming them would need a schema migration (see Beta schema policy).

Simplifications made deliberately (not full MVP.md literalism, to avoid overbuilding):
- Highlights are a `HighlightType` enum directly on QuickNote, not a separate polymorphic
  model attached to DailyLog/QuickNote/AttachmentItem/StudyItem/CareerOutput.
- New skill/tool/concept entries default to `.concept` category rather than prompting the
  user to categorize on the fly.

Testing: `MyInternLogTests` is a unit-test target (XCTest) with in-memory SwiftData
helpers in `TestSupport.swift`. New pure-logic code should get a test alongside it. The
target was added by editing `project.pbxproj` directly (folder-synchronized group, like
the app target) and verified with `xcodebuild test`.

## Known development gotcha

If you change SwiftData model relationships/properties significantly across a session, the
simulator's on-disk store (created earlier in the session with an older schema shape) can
get out of sync — inserts silently vanish after the sheet dismisses instead of persisting,
because SwiftData's automatic lightweight migration doesn't handle every kind of change.
**Fix:** `xcrun simctl uninstall <device> ty.MyInternLog` then reinstall/relaunch. This is
expected during active development, not a code bug — confirmed by reproducing the failure
on the stale store and then verifying identical code saves correctly against a fresh one.

## Beta schema policy

Testers will have real entries on their phones, so a model change must never lose them. There is
no `VersionedSchema` migration plan yet, so until one exists:
- Allowed: a new model, or a new property that is optional or has a default value.
- Not allowed without a migration: renaming or removing a property, changing a property's type, or
  changing a relationship. That is exactly the "stale store" failure above, on a tester's phone.
- Before shipping any build that touches a model, run the upgrade test: build the previous commit
  (`git archive <sha> | tar -x -C <dir>`), install it in the simulator, add a note through the UI,
  then `xcrun simctl install` the new build over it (never uninstall in between) and confirm the
  note is still there. Checking the store directly is quick:
  `sqlite3 -readonly "$(xcrun simctl get_app_container <device> ty.MyInternLog data)/Library/Application Support/default.store" "select ZTITLE from ZQUICKNOTE;"`
  (SwiftData autosaves a few seconds after a change, so wait before querying.)
- Last run: b2a25ba → beta-readiness changes, same schema. Profile, note, and daily log all survived.

## Known testing-tool limitation (Claude Code's iOS Simulator control)

Taps/swipes on rows *inside a SwiftUI `List`* did not register when driven through the
automated simulator tool — this reproduced even on a completely unmodified, pre-existing
`Button` (the StudyItem checkbox) as well as `NavigationLink` and `onTapGesture` List rows.
Every non-List interaction in the same sessions (sheets, Form fields, toolbar buttons,
LazyVGrid tiles, tab bar, pickers) worked reliably. One more quirk: a default tap on a `Toggle` switch
inside a Form did nothing, but the same tap with `duration: 0.15` flipped it. So: List-hosted row interactions
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
Features real users need first
Working software over architecture discussions
One feature at a time
Current Project Status

Completed:

Project setup, GitHub setup, CLAUDE.md
All models and features listed under "Current Milestone" above

Current Goal:
Get MyInternLog ready for outside beta testers. The original goal (the smallest useful
version before AFRL began on June 22) was met and far exceeded: every Version 1 feature
in docs/MVP.md exists and works. What's left is listed under "Current Milestone" above:
the visual design pass, the app icon, and how to distribute builds (TestFlight needs the
paid Apple Developer Program, which is undecided).

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
