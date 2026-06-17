
# MyInternLog Version 1 Product Specification

## Product Summary

**App name:** MyInternLog

**Tagline:** Never forget what you accomplished.

MyInternLog is a journal-first internship accomplishment tracker for interns who want to capture what they worked on, what they learned, what challenged them, and what they accomplished. It is not a corporate task manager. It is a daily reflection system that turns internship notes into useful summaries, resume bullets, interview talking points, LinkedIn updates, presentation prep, and PDF reports.

The first real use case is a student internship at an Air Force Research Lab in Rome, NY. The exact internship project is unknown, so the app must support flexible research, lab, software, technical, and general internship work. The UI should avoid AFRL-specific wording and stay reusable for interns in many fields.

Version 1 is intentionally ambitious because this project has a real purpose: it should be useful during the internship and strong enough to present as a portfolio project. Implementation should still happen in small, focused commits.

## Product Goals

- Help interns record daily work without friction.
- Support both quick notes during the day and deeper reflection later.
- Make it easy to search, organize, and revisit internship history.
- Help turn raw notes into summaries, resume bullets, reports, and presentation material.
- Keep data local on the device for Version 1.
- Keep the code beginner-friendly, educational, and portfolio-worthy.
- Use SwiftUI, MVVM, and SwiftData with simple, readable architecture.

## Non-Goals

- MyInternLog is not a full task manager, kanban board, or productivity suite.
- MyInternLog is not a cloud collaboration tool.
- Version 1 does not require accounts, login, backend services, or iCloud sync.
- Version 1 does not use an in-app OpenAI API integration.
- The app should not encourage storing confidential, classified, controlled, or sensitive project details.

## Target User

The primary user is an intern, especially a student intern, who wants to remember what they did over an internship and turn that record into useful career material.

Initial personal context:

- Internship at an Air Force Research Lab in Rome, NY.
- Exact project unknown at planning time.
- Work may involve research, lab work, software, technical concepts, meetings, and learning.
- Final presentation/report requirements for CUNY are unknown, so CUNY support must be flexible.

Future public target:

- Mainly interns, especially student interns.
- Students who want a better record of their accomplishments than scattered notes.

## Core Product Framing

MyInternLog should help answer:

- What did I actually do during this internship?
- What did I learn?
- What problems did I face and overcome?
- What skills, tools, and concepts did I use?
- What should I keep studying?
- What can I use for my resume, interviews, LinkedIn, reports, or presentations?

The app should feel like a modern dashboard wrapped around a reflective journal.

## Platform Requirements

- iPhone first.
- Target device: iPhone 13 Pro.
- Target OS: iOS 18.6.2.
- Support portrait and landscape orientation on iPhone.
- iPad and Mac support are Version 2/future.
- Version 1 should work offline. The only AI workflow is manual copy/paste outside the app.

## Technology Requirements

Use:

- SwiftUI for UI.
- MVVM for architecture.
- SwiftData for local persistence.
- Swift Charts for dashboard charts.
- PDFKit for PDF export.
- UserNotifications for reminders and milestone notifications.
- PhotosUI for photo library import.
- Camera support for taking photos.
- Local file storage for attachments.

Keep implementation choices simple and readable. Prefer beginner-friendly code over clever abstractions.

## Privacy And Safety Requirements

Because this app may be used during a research/lab internship, it should be privacy-conscious by default.

Version 1 requirements:

- Data stays local on device.
- No login or account.
- No backend.
- No automatic cloud sync.
- Generic wording in summaries, AI prompts, and PDFs should be enabled by default.
- Before AI prompt copy or PDF export, show a short reminder to review for sensitive details.
- AI/export flows should include a preview/edit step so the user can sanitize details.
- The app should avoid including specific lab/project names by default unless the user chooses to include them.
- Store pasted AI results, but do not store the exact prompt copied to ChatGPT.

The first AI workflow should use manual ChatGPT copy/paste:

1. MyInternLog generates a prompt from selected app data.
2. The user reviews and sanitizes the prompt.
3. The user copies it to ChatGPT.
4. The user pastes the result back into MyInternLog.
5. MyInternLog stores the final result by output type.

ChatGPT Plus can be used manually by the user, but it does not act as a free API for the iOS app. In-app API or local AI integration can be considered later.

## Visual And UX Direction

The app should feel:

- Modern.
- Dashboard-like.
- Friendly.
- Slightly motivational.
- Reflective, not corporate.
- Inspired by learning apps like Mimo, with a subtle cosmic/space-style dark theme.

Theme requirements:

- Dark mode default.
- Light mode also supported.
- Subtle cosmic visual style, not heavy or gimmicky.
- Semantic accent colors should communicate meaning.
- Use chips for tags, skills, tools, concepts, groups, and highlights.

Suggested semantic colors:

- Wins: green.
- Study items: purple.
- Questions: yellow.
- Stress or blockers: red.
- Skills/tools/concepts: blue.
- Milestones: accent color distinct from daily logs.

Copy style:

- Motivational but not cheesy.
- Empty states should be simple.
- Example empty state: "No study items yet."
- The tagline should appear during app opening/onboarding/home.

## Onboarding And Setup

Version 1 should include a first-run setup flow.

Setup should be skippable. The user should be able to start logging immediately even if they skip every field.

Setup should allow:

- Internship title.
- Organization.
- Location.
- Start date.
- End date.
- Mentor/supervisor name.
- Optional mentor/supervisor contact details.
- School/program.
- Presentation date.
- Notes.
- Reminder setup.
- Theme preference.

Do not show a heavy privacy warning in onboarding. Keep privacy reminders near AI prompt export and PDF export.

If the internship start date is missing, the home screen should show a setup prompt instead of an internship week number.

The internship week number should be configurable and hideable.

## Home Screen

Home is a dashboard launchpad, not the full Today screen.

Home should include:

- App name.
- Tagline.
- Today's date.
- Internship week number when configured.
- A prominent "Let's Log" action that opens the Today screen.
- Access to major screens/actions.
- Recent entries.
- A clear empty state if there are no recent entries.

Home should provide access to:

- Today.
- Search.
- Entries/Archive.
- Dashboard.
- Study Queue.
- Calendar/Milestones.
- Attachments/Gallery.
- Career Outputs.
- PDF Export.
- Settings.
- About.

## Today And Daily Logs

The core data model should center around one `DailyLog` per calendar date.

If the user creates a quick note, photo, file attachment, or reflection for a date, the app should create that date's `DailyLog` automatically.

A `DailyLog` should support:

- Date.
- Optional title.
- Quick notes.
- Attachments.
- Reflection prompt/answer pairs.
- Self-summary.
- AI-assisted summary.
- Mood, confidence, energy, and stress values.
- Tags.
- Skills/tools/concepts.
- Project groups.
- Highlights.
- Study items.
- Draft/complete status.

Daily logs should autosave wherever practical.

The app should show a subtle saved indicator after autosave.

Deleting notes, photos, files, or logs should require confirmation.

Version 1 can use confirmation delete. Trash/recovery is Version 2/future.

## Quick Notes

Quick notes are for capturing information during the day.

Quick notes should support:

- Timestamp.
- Optional title.
- Body text.
- Optional type/category.
- Tags.
- Highlights.
- Project groups.
- Skills/tools/concepts.
- Study later suggestion.
- Attachments.

If no title is set, the UI should show the first line or body preview.

Quick note categories should be optional because some notes will be general.

Possible default quick note categories:

- Note.
- Idea.
- Question.
- Win.
- Blocker.
- Study later.

Meetings do not need a separate note type. Meetings can be handled with tags/groups such as `meeting`, `mentor`, or `standup`.

Quick notes should use plain text for Version 1. Link detection should be supported where practical.

## Daily Reflections

Daily reflections are the end-of-day summary experience.

The reflection screen should show that day's quick notes and attachments as context while the user writes.

The user can save a reflection as a draft or mark it complete.

A daily reflection can be marked complete only if at least one prompt has an answer.

Streaks count only completed daily reflections.

Missing a day breaks the streak. There is no streak repair/backfill feature.

Draft/incomplete days should be visible so the user can finish them later.

## Reflection Templates

Version 1 should include at least two templates:

1. Quick Reflection.
2. Full Reflection.

Quick Reflection prompts:

- What did I do?
- What did I learn?
- What should I review later?

Full Reflection prompts:

- Work completed.
- What I learned.
- Problems faced.
- How I solved them.
- Questions I still have.
- Wins/accomplishments.
- Skills/tools/concepts used.
- Things to study later.
- Next steps.
- Freeform notes.

Prompt answers should be stored as flexible prompt/answer pairs, not hard-coded database fields. This supports per-entry customization.

The user should be able to:

- Add prompts to a reflection.
- Remove prompts from a reflection.
- Edit prompt wording for a reflection.
- Switch templates after starting a reflection.

If switching templates would remove a prompt that already has an answer, warn the user before removing it.

Global prompt/template management in Settings should be supported in Version 1 if practical, but the implementation should stay simple.

## Local Summary Draft Builder

Version 1 should include a local, transparent summary draft builder.

It should not pretend to be AI. It should organize available notes into suggested answers and summaries using simple templates.

The draft builder should:

- Use today's quick notes, reflection answers, attachments metadata, tags, skills, groups, highlights, and study items.
- Suggest answers for reflection prompts.
- Fill suggestions by default.
- Allow a Settings option to require per-field approval before filling.
- Produce editable output.

## Mood, Confidence, Energy, And Stress

The daily reflection should include optional sliders for:

- Confidence.
- Mood.
- Energy.
- Stress.

These should be optional and likely placed in an expandable section.

The UI should use emoji/label-style endpoints, but store numeric values behind the scenes for search, filtering, and charts.

The user should not need to see raw numbers unless a future chart/filter requires it.

## Attachments

Version 1 should support:

- Photos.
- Screenshots.
- PDF/file attachments.

Photo sources:

- Camera capture.
- Photo library import.

Photos should be imported into app-local storage rather than only referenced from the Photos library.

Photos should be stored at original quality.

Attachments should support:

- Multiple attachments per day.
- Multiple attachments per note.
- Caption/notes.
- Tags.
- Project groups.
- Skills/tools/concepts.
- Highlights.
- Optional shared batch caption when importing multiple items.

After adding photos/files, the app should show a non-blocking prompt such as "Add context?"

Captions/notes should be plain text for Version 1.

Photos should support full-screen viewing and zoom.

Version 1 should include a dedicated Attachments/Gallery screen.

Attachment search should use captions, notes, tags, groups, skills/tools/concepts, and file names. OCR/image text search is Version 2/future.

## Tags, Skills, Tools, Concepts, And Groups

The app should support both lightweight tags and larger project/group organization.

Tags:

- Freeform.
- Reusable after the user types them once.
- Starter suggestions should be available.

Starter tag suggestions:

- meeting.
- learning.
- debugging.
- win.
- question.
- study later.
- blocker.

Skills/tools/concepts:

- Should be reusable with autocomplete.
- Should be visually separate categories.
- Example skill: debugging.
- Example tool/language: Swift, Python, Git.
- Example concept: radar systems, APIs, SwiftData.

Project groups:

- Default group: Internship.
- User can create custom groups/projects.
- Entries, notes, attachments, and study items can belong to multiple groups.
- Groups should support colors and icons.
- Groups can be archived, edited, and deleted.

Rich group detail pages can grow over time, but Version 1 should at least support assignment, filtering, and basic group organization.

## Highlights

Highlights help mark material for summaries, PDFs, and resume prep.

Version 1 built-in highlight types:

- Win.
- Important.
- Resume-worthy.
- Study later.

Custom highlight types are Version 2/future unless they are easy to include.

Highlights should be available for:

- Daily logs.
- Quick notes.
- Attachments.
- Study items.
- Resume bullets.

## Study Queue

The Study Queue should be a main app area.

If the queue is empty, use a simple empty state:

- No study items yet.

Study items should be created:

- Manually.
- From reflection answers.
- From questions.
- From "things to study later."
- From quick notes tagged or highlighted as study later.

Study items should support:

- Title.
- Notes.
- Source link back to the original daily log, note, or attachment.
- Optional due date.
- Optional group.
- Optional skills/tools/concepts.
- Completion checkbox.
- Completed visual state with strikethrough or dimming.

Study item completion should feed dashboard stats and PDF/report outputs.

## Search

Search is a major Version 1 requirement.

Search should cover:

- Daily reflection answers.
- Self-summaries.
- AI-assisted summaries.
- Quick notes.
- Attachment captions/notes/file names.
- Tags.
- Skills/tools/concepts.
- Study items.
- Groups/projects.
- Milestones.
- Resume/career output drafts.

Search results should:

- Be grouped by type.
- Show highlighted matching snippets where possible.
- Open directly to the matched note/photo/field/item.
- Also provide an option to view the full day.
- Include only active items, not deleted/trash items.
- Save recent searches.

Filters should be combinable.

Required filters:

- Study later.
- Notes.
- Confidence low/medium/high.
- Projects/groups.
- Skills/tools/concepts.
- Date.

Date filters should support:

- Today.
- This week.
- This month.
- Custom range.

OCR/image text search is Version 2/future.

## Reminders And Notifications

Reminders should help the user record consistently without creating streak pressure.

Reminder requirements:

- Reminders are off by default.
- Ask notification permission only when the user turns reminders on.
- Configure reminders during setup and in Settings.
- Show default reminder times even while reminders are off.
- Allow adding/removing reminder slots.
- Allow editing reminder times.
- Allow editing reminder message text.
- Allow day-of-week selection.
- Default to every day unless changed.
- No streak-based notifications.
- Snooze is Version 2/future.

Default reminder slots:

- 9:00 AM, Morning capture: "Capture your first note."
- 2:00 PM, Midday learning: "Log what you learned so far."
- 6:00 PM, Evening reflection: "Write today's reflection."

Notification taps should open the relevant capture flow when possible:

- Morning and midday reminders should open quick capture.
- Evening reminder should open the daily reflection flow.

## Calendar And Milestones

Version 1 should include a Milestones/Calendar section with a simple custom SwiftUI month grid.

Calendar requirements:

- One month at a time.
- Previous/next month navigation.
- Today button.
- Quick jump to internship start/current week where practical.
- Tap any date to open that day's log, even if empty.
- Completed reflection days show a checkmark.
- Days with quick notes but no completed reflection show a small dot.
- Attachment indicators can stay in day detail view.

Milestone fields:

- Title.
- Date.
- Type.
- Notes.
- Optional reminder.

Default milestone types:

- Internship start.
- Internship end.
- Mentor meeting.
- Evaluation.
- Report due.
- Presentation.
- CUNY presentation.
- School deadline.

Custom milestone types are Version 2/future unless easy.

Milestone reminders should use the same notification system.

Milestone reminder options:

- Exact date/time.
- Day before.
- Week before.

Milestones should be available for PDF reports.

## Dashboard

Dashboard is a separate screen from Home.

Dashboard should provide visual progress tracking with basic cards and simple charts.

Use Swift Charts for polished native visuals.

Dashboard cards:

- Current streak.
- Entries this week.
- Open study items.
- Highlighted wins.

Dashboard charts:

- Entries over time.
- Study items completed.
- Confidence trend.

Optional chart views:

- Mood trend.
- Energy trend.
- Stress trend.
- Streak chart.
- Wins chart.

Dashboard should support date ranges:

- Week.
- Month.
- All internship.

Charts should be included in weekly/end PDFs as an export option.

## Weekly Recaps

Version 1 should include weekly recap support.

Weekly recaps should feel like a slightly fun "wrapped" style summary while staying practical and text-first.

Weekly recap should use:

- Daily reflections.
- Quick notes.
- Attachments and captions.
- Tags.
- Skills/tools/concepts.
- Study items.
- Highlights.
- Dashboard stats.

Weekly recap should capture:

- What happened this week.
- Top skills/tools/concepts.
- Biggest win.
- Common theme.
- Challenges or blockers.
- Study items.
- Next week focus.
- Photos/files from the week when appropriate.

Weekly recaps should have draft/complete status.

Weekly AI-assisted recap results should be saved separately from self-written weekly recap content.

## End-Of-Internship Summary

Version 1 should include end-of-internship summary support.

The end summary should use everything available:

- Daily logs.
- Quick notes.
- Attachments and captions.
- Weekly recaps.
- Self-summaries.
- AI-assisted summaries.
- Skills/tools/concepts.
- Study items.
- Highlights.
- Milestones.
- Dashboard stats.
- Resume bullet drafts.

The app should generate a local template-based draft and support AI prompt export for a stronger final version.

End summary sections:

- Overall internship summary.
- Main things worked on.
- What was learned.
- Problems overcome.
- Skills/tools/concepts used.
- Accomplishments.
- Things to keep studying.
- Growth areas.
- Resume bullet drafts.
- Interview talking points.
- LinkedIn/update summary.
- CUNY presentation prep.

## AI Prompt Export

Version 1 should support AI prompt export, not direct in-app AI generation.

Supported prompt modes:

- Daily summary.
- Weekly recap.
- End-of-internship summary.
- Resume bullets.
- Interview talking points.
- LinkedIn summary.
- CUNY presentation prep.

Each AI prompt flow should:

- Let the user choose what source material to include.
- Default to generic wording.
- Show a short sensitive-details reminder.
- Show a preview/edit screen before copy.
- Copy the prompt to the clipboard.
- Let the user paste the final result back into the app.
- Store the final result by output type.
- Not store the copied prompt itself.

AI-assisted content should be clearly labeled.

Daily and weekly summaries should support:

- Self-summary.
- AI-assisted summary.
- Side-by-side labels.
- Editable pasted AI results.
- Latest version only for Version 1.

Version history for the same summary is Version 2/future.

## Resume And Career Outputs

Version 1 should include resume bullet generation as editable drafts.

The app should ask for target role/context before generating resume bullets.

Resume bullet styles:

- Technical.
- STAR.
- Beginner/student-friendly.
- Federal/government-friendly.
- LinkedIn-friendly.

Source material:

- Use all logs by default.
- Allow selected/highlighted material instead.
- Avoid specific lab/project names by default unless approved.

Resume bullet drafts should support:

- Bullet text.
- Target role/context.
- Style.
- Source entries/highlights.
- Favorite/selected state.
- Notes.
- Export inclusion.

Resume bullets should be grouped by target role/context.

Interview talking points should be generated from both selected resume bullets and broader logs.

Career output types:

- Resume bullets.
- Interview talking points.
- LinkedIn summary.
- Internship report summary.
- CUNY presentation prep.

## PDF Export

Version 1 should include PDF export.

PDF report types:

- Daily journal report.
- Weekly journal report.
- End-of-internship report.

Selectable PDF templates:

- Clean academic report.
- Modern portfolio-style report.
- Simple journal export.

PDFs should include:

- Cover page.
- App name.
- Internship info.
- Internship dates.
- Tagline.
- Generated date.
- Page numbers.

Daily PDFs should include everything recorded that day unless toggled off.

Weekly PDFs should include everything recorded that week unless toggled off.

End-of-internship PDFs should use everything available unless toggled off.

Export toggles:

- Include photos.
- Include file attachments.
- Include raw notes.
- Include AI summaries.
- Include resume bullets.
- Include study items.
- Include mood/confidence stats.
- Include dashboard charts.
- Use generic wording.

Before PDF export:

- Show a short sensitive-details reminder.
- Provide preview/edit/sanitize options where practical.

PDFs should support CUNY presentation/report needs, but exact CUNY requirements are unknown and should remain configurable.

## Entries And Archive

Version 1 should include a full Entries/Archive list screen separate from Search.

Default display:

- Newest first.

Optional grouping:

- By week.
- By month.

Calendar-style browsing is handled in the Calendar/Milestones section.

Entries should show draft/complete status.

## Settings

Version 1 Settings should include:

- Internship profile.
- Reminders.
- Reflection prompts/templates.
- Theme.
- Privacy/generic wording.
- Notification settings.
- PDF/export preferences where practical.
- About.

Data reset/delete all data is Version 2/future and should require strong confirmation when added.

Storage usage for attachments is Version 2/future.

## About Screen

Version 1 should include an About MyInternLog screen.

About should mention:

- App name.
- Tagline.
- Purpose.
- Data stays local on-device in Version 1.
- This is a student-built educational project.

The About screen should be user-facing, not a developer architecture tutorial.

Developer architecture explanations belong in docs.

## Expected SwiftData Models

These model names are suggestions. The final implementation can adjust names if the code stays clear and beginner-friendly.

### InternshipProfile

Stores the user's internship setup.

Fields:

- title.
- organization.
- location.
- startDate.
- endDate.
- mentorName.
- mentorEmail.
- mentorPhone.
- schoolProgram.
- presentationDate.
- notes.
- useGenericWordingByDefault.
- showWeekNumber.

### DailyLog

One record per calendar date.

Fields:

- date.
- title.
- isComplete.
- completedAt.
- selfSummary.
- aiSummary.
- confidenceValue.
- moodValue.
- energyValue.
- stressValue.
- createdAt.
- updatedAt.

Relationships:

- quickNotes.
- attachments.
- reflectionAnswers.
- tags.
- knowledgeItems.
- projectGroups.
- highlights.
- studyItems.

### ReflectionAnswer

Flexible prompt/answer storage.

Fields:

- promptText.
- answerText.
- displayOrder.
- templateName.
- createdAt.
- updatedAt.

### QuickNote

Timestamped note captured during the day.

Fields:

- title.
- body.
- noteType.
- timestamp.
- createdAt.
- updatedAt.

Relationships:

- dailyLog.
- tags.
- knowledgeItems.
- projectGroups.
- highlights.
- attachments.

### AttachmentItem

Local photo/file attachment.

Fields:

- fileName.
- fileType.
- localPath.
- caption.
- notes.
- createdAt.
- updatedAt.

Relationships:

- dailyLog.
- quickNote.
- tags.
- knowledgeItems.
- projectGroups.
- highlights.

### Tag

Reusable freeform tag.

Fields:

- name.
- colorName.
- createdAt.

### KnowledgeItem

Reusable skill/tool/concept.

Fields:

- name.
- category.
- createdAt.

Categories:

- skill.
- tool.
- concept.

### ProjectGroup

Custom project/group organization.

Fields:

- name.
- colorName.
- iconName.
- isArchived.
- createdAt.
- updatedAt.

### Highlight

Marks important content.

Fields:

- type.
- notes.
- createdAt.

Built-in types:

- win.
- important.
- resumeWorthy.
- studyLater.

### StudyItem

Actionable study/review item.

Fields:

- title.
- notes.
- isCompleted.
- completedAt.
- dueDate.
- createdAt.
- updatedAt.

Relationships:

- sourceDailyLog.
- sourceQuickNote.
- sourceAttachment.
- projectGroups.
- knowledgeItems.

### Milestone

Important internship date.

Fields:

- title.
- date.
- type.
- notes.
- reminderOption.
- reminderDate.
- createdAt.
- updatedAt.

### ReminderSetting

Notification slot configuration.

Fields:

- label.
- message.
- time.
- enabledDays.
- isEnabled.
- purpose.

### WeeklyRecap

Saved weekly recap.

Fields:

- weekStartDate.
- weekEndDate.
- title.
- selfSummary.
- aiSummary.
- isComplete.
- createdAt.
- updatedAt.

### CareerOutput

Saved resume/interview/LinkedIn/report content.

Fields:

- outputType.
- targetRole.
- style.
- text.
- isFavorite.
- isSelectedForExport.
- notes.
- createdAt.
- updatedAt.

Output types:

- resumeBullet.
- interviewTalkingPoint.
- linkedInSummary.
- internshipReportSummary.
- cunyPresentationPrep.

## Suggested Folder Structure

Keep the folder structure clear and educational.

```text
InternshipTracker/
  App/
    InternshipTrackerApp.swift
  Models/
    InternshipProfile.swift
    DailyLog.swift
    ReflectionAnswer.swift
    QuickNote.swift
    AttachmentItem.swift
    Tag.swift
    KnowledgeItem.swift
    ProjectGroup.swift
    Highlight.swift
    StudyItem.swift
    Milestone.swift
    ReminderSetting.swift
    WeeklyRecap.swift
    CareerOutput.swift
  ViewModels/
    HomeViewModel.swift
    TodayViewModel.swift
    SearchViewModel.swift
    DashboardViewModel.swift
    StudyQueueViewModel.swift
    CalendarViewModel.swift
    ExportViewModel.swift
  Views/
    Home/
    Today/
    Search/
    Dashboard/
    StudyQueue/
    Calendar/
    Attachments/
    Career/
    Export/
    Settings/
    About/
    Shared/
  Services/
    NotificationService.swift
    AttachmentStorageService.swift
    SearchService.swift
    SummaryDraftService.swift
    AIPromptBuilderService.swift
    PDFExportService.swift
    DashboardStatsService.swift
    CalendarService.swift
  Utilities/
    DateHelpers.swift
    Theme.swift
    SampleData.swift
```

## Suggested Services

### NotificationService

Handles daily reminders and milestone reminders.

### AttachmentStorageService

Imports, stores, loads, and deletes local photo/file attachments.

### SearchService

Searches logs, notes, captions, tags, skills/tools/concepts, groups, study items, milestones, and career outputs.

### SummaryDraftService

Creates transparent local drafts from existing notes and structured data.

### AIPromptBuilderService

Builds copy/paste prompts for ChatGPT with generic wording and selected source material.

### PDFExportService

Generates daily, weekly, and end-of-internship PDFs using selected templates and export toggles.

### DashboardStatsService

Calculates streaks, entries over time, study completion, wins, and slider trends.

### CalendarService

Builds calendar month data and computes markers for completed reflections, note-only days, and milestones.

## Sample Data And Previews

Version 1 should include sample/mock data for SwiftUI previews and learning.

Sample data should include:

- Internship profile.
- Several daily logs.
- Quick notes.
- Attachments.
- Tags.
- Skills/tools/concepts.
- Project groups.
- Study items.
- Milestones.
- Weekly recap.
- Resume bullets.

Sample data should avoid real sensitive details.

## Beginner-Friendly Test Plan

Include a small number of practical tests.

Focus on core logic tests first:

- Streak calculation.
- Daily completion rules.
- Search matching.
- Search filters.
- Date range filtering.
- Calendar markers.
- Study item completion.
- Dashboard stats.
- Summary draft builder.
- AI prompt generic wording behavior.
- PDF export option configuration.

UI tests can come later after the main screens stabilize.

## Acceptance Criteria

Version 1 is successful when:

- The user can complete skippable onboarding.
- The user can create and view one `DailyLog` per date.
- The user can add quick notes with timestamps.
- The user can write full or quick reflections.
- The user can mark reflections complete.
- The app tracks streaks based on completed reflections.
- The user can add photos and files as local attachments.
- The user can search across notes, reflections, captions, tags, skills, groups, study items, milestones, and career outputs.
- The user can use filters and open direct search results.
- The user can manage study items.
- The user can configure reminders and milestone reminders.
- The calendar shows completed reflection days, note-only days, and milestones.
- The dashboard shows basic stats and charts.
- The user can generate local summary drafts.
- The user can export sanitized prompts for ChatGPT and save pasted results.
- The user can create resume bullet drafts and career outputs.
- The user can export daily, weekly, and end-of-internship PDFs.
- The app works offline.
- The app remains understandable for a beginner learning SwiftUI, MVVM, and SwiftData.

## Version 2 And Future Features

Future features intentionally outside the core Version 1 expectation:

- iCloud sync.
- iPad support.
- Mac support.
- Audio notes.
- Audio transcription.
- Share sheet import.
- OCR/image text search.
- Face ID/app lock.
- App icon and deeper branding polish.
- App Store polish.
- Richer accessibility pass.
- Trash/recovery.
- Data reset/delete all data.
- Attachment storage usage screen.
- Reminder snooze.
- Rich text/Markdown rendering.
- Local AI/Odysseus integration.
- In-app OpenAI API integration.
- Version history for summaries.
- Custom highlight types.
- Custom milestone types.

## Open Questions

- Exact internship project is unknown.
- Exact CUNY presentation/report requirements are unknown.
- Final public release scope is unknown until after the internship.

The Version 1 spec should remain flexible enough to handle those unknowns without requiring major rewrites.
