# OnTrack

OnTrack is a personal macOS to-do app built with SwiftUI. It is designed around three daily checkpoints instead of endless list management:

- `09:00` to set the day up
- `12:30` to review progress
- `16:00` to wrap up and plan the next day

The app keeps the UI focused on today's work, carries unfinished tasks forward, and uses local notifications to keep the day moving.

## Features

- Native macOS interface built with SwiftUI
- Modern two-panel layout with a dedicated daily overview
- Double-click task cards to open full title/body editing
- Local task persistence with no account or cloud dependency
- Automatic rollover of unfinished tasks into the current day
- Scheduled reminders for morning, midday, and wrap-up check-ins
- Settings screen for notification permission status
- Packaged `.app` bundle generation for direct Finder launch

## Tech Stack

- Swift 6
- SwiftUI
- Xcode macOS app target
- XcodeGen project spec
- UserNotifications

## Project Structure

```text
OnTrack.xcodeproj/  Main Xcode project for running, debugging, and testing
project.yml         XcodeGen spec used when project structure changes
Sources/
  App/             App entry point
  Models/          Task and reminder models
  Services/        Persistence and notification scheduling
  Views/           SwiftUI screens and theme
Tests/
  OnTrackTests/    Unit tests
Scripts/
  package_app.sh   Builds and packages OnTrack.app
```

## Running Locally

### Xcode

1. Open `OnTrack.xcodeproj` in Xcode.
2. Select the `OnTrack` scheme.
3. Run on `My Mac`.
4. Use `Product > Test` to run `OnTrackTests`.

## Building the macOS App

To create a double-clickable app bundle:

```bash
./Scripts/package_app.sh
```

This generates:

```text
OnTrack.app
```

You can then open `OnTrack.app` directly from Finder.

## Regenerating The Project

`OnTrack.xcodeproj` is checked in and should be used day to day.

Only regenerate it if you change the project structure in `project.yml`:

```bash
xcodegen generate
```

## GitHub Releases

This repository includes a GitHub Actions release workflow:

- It builds `OnTrack.app` on macOS
- Compresses it into a `.zip`
- Uploads it as a workflow artifact
- Publishes it to GitHub Releases when you push a tag like `v1.0.0`

Example:

```bash
git tag v1.0.0
git push origin v1.0.0
```

## Current Limitations

- Reminder times are currently fixed in code
- Tasks are stored locally on one Mac only
- The app does not yet include a menu bar mode, recurring tasks, or sync

## Roadmap Ideas

- Editable reminder times
- Menu bar mode
- Task priorities and categories
- Recurring tasks
- Better daily and weekly review flows
