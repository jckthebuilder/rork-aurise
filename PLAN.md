# Make AlarmKit actually fire (add missing entitlement + reliability fixes)

## Why the alarm isn't ringing

Your app already has AlarmKit code wired in, but it's missing one required piece: the **AlarmKit entitlement**. Without it, iOS silently refuses to give the app alarm permission, so no alarm is ever actually scheduled with the system — that's why nothing rings.

Apple requires both a usage description (which you have) AND the entitlement (which you don't). Adding this is what will make it work.

## What I'll do

- **Turn on the AlarmKit capability** so iOS trusts the app to schedule real system alarms that ring through Silent mode and Focus, exactly like Wayv.
- **Prompt for AlarmKit permission at the right moment** — when you first create or enable an alarm, with a clear explanation if it's denied.
- **Fix a small bug in the scheduler** that can cause recurring alarms to not reschedule after firing.
- **Add a "Test alarm" option** in Settings that fires a real AlarmKit alarm ~10 seconds out, so you can verify it rings on the Lock Screen without waiting until morning.
- **Show a clear status** on the home screen if AlarmKit permission is denied, with a one-tap button to open Settings.

## What stays the same

- The alarm list, missions, sounds, and onboarding flow all stay exactly as they are.
- The mission hand-off (app opens → mission runs) keeps working the same way.
- No Live Activity / Dynamic Island changes — you asked for minimal, just reliable firing.

## Testing

After this goes in, the "Test alarm" button in Settings will let you confirm it works in ~10 seconds. If the alarm rings on the Lock Screen even with the phone on Silent, AlarmKit is fully working.