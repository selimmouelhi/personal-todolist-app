# OnTrack

Personal macOS to-do app built with SwiftUI.

## Current features

- Native macOS SwiftUI interface
- Daily task list with local persistence
- Automatic rollover of unfinished tasks into the current day
- Daily notifications scheduled for `09:00`, `12:30`, and `16:00`
- Settings screen to inspect notification permission state

## Run locally

1. Open the folder in Xcode.
2. Let Xcode resolve the Swift package.
3. Run the `OnTrack` executable target on macOS.

You can also try:

```bash
swift run
```

## Build a clickable app

From Terminal in this folder:

```bash
./Scripts/package_app.sh
```

That creates `OnTrack.app` in the project root so it can be launched from Finder.
