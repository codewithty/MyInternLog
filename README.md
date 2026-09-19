# MyInternLog

MyInternLog is an iOS application built with SwiftUI that helps students and early-career workers track accomplishments, lessons learned, challenges, and reflections throughout an internship, co-op, research role, or job.

The goal is to make it easier to document day-to-day work, remember important experiences, and generate resume-ready achievements when the role wraps up.

## Why I Built It

During internships, it can be difficult to remember everything you've worked on over the course of several weeks. MyInternLog was created to provide a simple place to record daily progress, reflect on learning experiences, and maintain a history of accomplishments that can later be used for resumes, interviews, performance reviews, and personal growth.

## Features

* Quick Notes with tags, skills/tools/concepts, project groups, highlights, and photo, camera, or PDF attachments
* Study Queue for things to learn later
* Daily Reflections with mood, confidence, energy, and stress check-ins, plus local (non-AI) summary drafts
* Weekly Recaps in a "wrapped" style
* Calendar and milestones with optional reminders, plus custom daily reminders (local notifications)
* Dashboard with streaks and trend charts, and a photo Gallery
* Search and filtering across notes, reflections, study items, attachments, milestones, and career outputs
* Resume bullets, interview talking points, and a final Wrap-Up summary, written with a copy/paste prompt for the AI tool of your choice (the app never calls an AI service itself)
* PDF reports, and a JSON export of your notes, reflections, and settings
* Demo mode with sample data, so you can explore without any entries of your own
* Local-only storage with SwiftData: no account, no analytics, no network access

## Planned Features

* Visual design pass (a dark, subtle cosmic theme)
* Accessibility pass
* iCloud synchronization

## Tech Stack

* Swift
* SwiftUI
* SwiftData
* Swift Charts
* Core Text (PDF export)
* UserNotifications
* MVVM Architecture

## Running It

Open `MyInternLog.xcodeproj` in Xcode, choose an iPhone simulator (or your own iPhone), and run. It targets iOS 26.0 and later and is iPhone-only. To run on a device, pick your own signing team under Signing & Capabilities.

## Status

Started as a personal project during my Summer 2026 internship. The Version 1 features are built, and a visual design pass and beta testing are next.

## Author

Tyler Smith

* LinkedIn: linkedin.com/in/tylersmith777
* GitHub: github.com/codewithty
