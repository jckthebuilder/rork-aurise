# Add AlarmKit Permission Step to Onboarding

## What's Being Fixed

The onboarding only ever asks for **notifications** permission. There's no step that asks for **AlarmKit** (the deeper alarm access needed to ring through Silent Mode and Focus). The permission was being requested too early (before any screen appeared), so iOS silently dropped it.

## Changes

- **New onboarding step** — after the notifications step, a new "Alarm Access" screen appears with an alarm bell icon, explaining that Aurise needs AlarmKit access to reliably wake you up through Silent Mode, Focus, and Do Not Disturb. Has an "Allow Access" button that triggers the real iOS AlarmKit permission dialog
- **Correct timing** — the AlarmKit dialog now fires at exactly the right moment during onboarding, ensuring iOS shows it properly
- **Removed premature request** — the early call in app startup (which was silently failing) is removed
- **Graceful handling** — on older devices that don't support AlarmKit, the step auto-advances without error
- **Onboarding step count updated** — progress bar reflects the new step correctly

