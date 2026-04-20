import Foundation
import SwiftUI
#if canImport(AlarmKit)
import AlarmKit
#endif
#if canImport(ActivityKit)
import ActivityKit
#endif

@available(iOS 26.0, *)
nonisolated struct WayvAlarmMetadata: AlarmMetadata {
    let alarmId: String
    let missionType: String
    let soundId: String
    let intensity: String
    let title: String
}

@available(iOS 26.0, *)
@MainActor
final class AlarmKitScheduler {
    static let shared = AlarmKitScheduler()
    private init() {}

    var isAvailable: Bool { true }

    func requestAuthorization() async -> Bool {
        let manager = AlarmManager.shared
        switch manager.authorizationState {
        case .authorized:
            return true
        case .denied:
            return false
        case .notDetermined:
            do {
                let state = try await manager.requestAuthorization()
                return state == .authorized
            } catch {
                return false
            }
        @unknown default:
            return false
        }
    }

    func isAuthorized() -> Bool {
        AlarmManager.shared.authorizationState == .authorized
    }

    func schedule(_ alarm: Alarm) async {
        await cancel(alarm)
        guard alarm.isEnabled else { return }

        let calendar = Calendar.current
        let comps = calendar.dateComponents([.hour, .minute], from: alarm.time)
        let hour = comps.hour ?? 7
        let minute = comps.minute ?? 0

        let stopButton = AlarmButton(
            text: "Stop",
            textColor: .white,
            systemImageName: "stop.fill"
        )
        let snoozeButton = AlarmButton(
            text: "Snooze",
            textColor: .white,
            systemImageName: "moon.zzz.fill"
        )

        let alertContent = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: alarm.title),
            stopButton: stopButton,
            secondaryButton: snoozeButton,
            secondaryButtonBehavior: .countdown
        )

        let presentation = AlarmPresentation(alert: alertContent)

        let metadata = WayvAlarmMetadata(
            alarmId: alarm.id.uuidString,
            missionType: alarm.missionType,
            soundId: alarm.soundId,
            intensity: alarm.intensity,
            title: alarm.title
        )

        let attributes = AlarmAttributes<WayvAlarmMetadata>(
            presentation: presentation,
            metadata: metadata,
            tintColor: Color(red: 1.0, green: 0.58, blue: 0.30)
        )

        let schedule: AlarmKit.Alarm.Schedule
        if alarm.isOneTime {
            guard let next = alarm.nextRingDate else { return }
            schedule = .fixed(next)
        } else if !alarm.repeatDays.isEmpty {
            let weekdays = alarm.repeatDays.compactMap(Self.localeWeekday(fromAppDay:))
            let time = AlarmKit.Alarm.Schedule.Relative.Time(hour: hour, minute: minute)
            let recurrence: AlarmKit.Alarm.Schedule.Relative.Recurrence =
                weekdays.isEmpty ? .never : .weekly(weekdays)
            schedule = .relative(AlarmKit.Alarm.Schedule.Relative(time: time, repeats: recurrence))
        } else {
            guard let next = alarm.nextRingDate else { return }
            schedule = .fixed(next)
        }

        let config = AlarmManager.AlarmConfiguration.alarm(
            schedule: schedule,
            attributes: attributes
        )

        do {
            _ = try await AlarmManager.shared.schedule(id: alarm.id, configuration: config)
        } catch {
            print("AlarmKit schedule failed: \(error)")
        }
    }

    func scheduleTestAlarm(in seconds: TimeInterval = 10) async -> Bool {
        guard await requestAuthorization() else { return false }

        let fireDate = Date().addingTimeInterval(seconds)

        let stopButton = AlarmButton(
            text: "Stop",
            textColor: .white,
            systemImageName: "stop.fill"
        )

        let alertContent = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: "Test Alarm"),
            stopButton: stopButton
        )

        let presentation = AlarmPresentation(alert: alertContent)

        let metadata = WayvAlarmMetadata(
            alarmId: "test",
            missionType: "none",
            soundId: "clear_bell",
            intensity: "standard",
            title: "Test Alarm"
        )

        let attributes = AlarmAttributes<WayvAlarmMetadata>(
            presentation: presentation,
            metadata: metadata,
            tintColor: Color(red: 1.0, green: 0.58, blue: 0.30)
        )

        let config = AlarmManager.AlarmConfiguration.alarm(
            schedule: .fixed(fireDate),
            attributes: attributes
        )

        do {
            _ = try await AlarmManager.shared.schedule(id: UUID(), configuration: config)
            return true
        } catch {
            print("AlarmKit test schedule failed: \(error)")
            return false
        }
    }

    func cancel(_ alarm: Alarm) async {
        do {
            try AlarmManager.shared.cancel(id: alarm.id)
        } catch {
        }
    }

    func cancelAll() async {
        let manager = AlarmManager.shared
        do {
            let existing = try manager.alarms
            for a in existing {
                try? manager.cancel(id: a.id)
            }
        } catch {
        }
    }

    func rescheduleAll(_ alarms: [Alarm]) async {
        await cancelAll()
        for alarm in alarms where alarm.isEnabled {
            await schedule(alarm)
        }
    }

    nonisolated private static func localeWeekday(fromAppDay appDay: Int) -> Locale.Weekday? {
        switch appDay {
        case 0: return .monday
        case 1: return .tuesday
        case 2: return .wednesday
        case 3: return .thursday
        case 4: return .friday
        case 5: return .saturday
        case 6: return .sunday
        default: return nil
        }
    }
}
