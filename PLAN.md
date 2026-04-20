# Fix Alarms toggle appearing in iOS Settings


## Changes

**Fix 1 — Wrong app name in permission text**
- [x] In `project.pbxproj` (both Debug & Release), change `NSAlarmKitUsageDescription` from `"Wayv uses AlarmKit..."` → `"Aurise uses AlarmKit to reliably ring your wake-up alarm even in Silent or Focus mode."`

**Fix 2 — Request AlarmKit permission at app launch**
- [x] In `AuriseApp.swift`, add a Task in the app init that calls `AlarmManager.shared.requestAuthorization()` immediately on iOS 26+
- [x] This ensures iOS registers Aurise as an alarm app the very first time it opens, making the "Alarms" toggle appear in iOS Settings → Aurise (just like Wayk)
