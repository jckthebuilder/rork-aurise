import Foundation
import UserNotifications
import AVFoundation

@MainActor
class AlarmScheduler {
    static let shared = AlarmScheduler()
    private let notificationCenter = UNUserNotificationCenter.current()
    private let alarmCategoryId = "AURISE_ALARM"
    private let missionActionId = "START_MISSION"
    private let snoozeActionId = "SNOOZE_ALARM"

    private init() {
        registerCategories()
    }

    private func registerCategories() {
        let missionAction = UNNotificationAction(
            identifier: missionActionId,
            title: "Start Mission",
            options: [.foreground]
        )
        let snoozeAction = UNNotificationAction(
            identifier: snoozeActionId,
            title: "Snooze 5 min",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: alarmCategoryId,
            actions: [missionAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        notificationCenter.setNotificationCategories([category])
    }

    func requestPermission() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert])
        } catch {
            do {
                return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                return false
            }
        }
    }

    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    func scheduleAlarm(_ alarm: Alarm) {
        cancelAlarm(alarm)
        guard alarm.isEnabled else { return }

        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: alarm.time)

        if alarm.isOneTime {
            guard let nextRing = alarm.nextRingDate else { return }
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextRing)
            scheduleNotification(alarm: alarm, dateComponents: dateComponents, identifier: "\(alarm.id.uuidString)_onetime", repeats: false)
        } else {
            for day in alarm.repeatDays {
                let systemWeekday = convertToSystemWeekday(day)
                var dateComponents = DateComponents()
                dateComponents.hour = timeComponents.hour
                dateComponents.minute = timeComponents.minute
                dateComponents.weekday = systemWeekday
                scheduleNotification(alarm: alarm, dateComponents: dateComponents, identifier: "\(alarm.id.uuidString)_day\(day)", repeats: true)
            }
        }
    }

    func cancelAlarm(_ alarm: Alarm) {
        let baseId = alarm.id.uuidString
        var identifiers = ["\(baseId)_onetime"]
        for day in 0..<7 {
            identifiers.append("\(baseId)_day\(day)")
        }
        identifiers.append("\(baseId)_snooze")
        for i in 1...5 {
            identifiers.append("\(baseId)_followup_\(i)")
        }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func scheduleSnooze(for alarm: Alarm, minutes: Int = 5) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(minutes * 60), repeats: false)
        let content = buildContent(for: alarm, isSnooze: true)
        let request = UNNotificationRequest(
            identifier: "\(alarm.id.uuidString)_snooze",
            content: content,
            trigger: trigger
        )
        notificationCenter.add(request)
    }

    func rescheduleAllAlarms(_ alarms: [Alarm]) {
        notificationCenter.removeAllPendingNotificationRequests()
        for alarm in alarms where alarm.isEnabled {
            scheduleAlarm(alarm)
        }
    }

    private func scheduleNotification(alarm: Alarm, dateComponents: DateComponents, identifier: String, repeats: Bool) {
        let content = buildContent(for: alarm, isSnooze: false)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request)

        scheduleFollowUpNotifications(alarm: alarm, baseDateComponents: dateComponents, repeats: repeats)
    }

    private func scheduleFollowUpNotifications(alarm: Alarm, baseDateComponents: DateComponents, repeats: Bool) {
        guard let baseHour = baseDateComponents.hour, let baseMinute = baseDateComponents.minute else { return }

        for i in 1...3 {
            let followUpContent = UNMutableNotificationContent()
            followUpContent.title = "⏰ \(alarm.title)"
            followUpContent.body = "Your alarm is still waiting! Complete your mission to dismiss."
            followUpContent.categoryIdentifier = alarmCategoryId
            followUpContent.sound = .defaultCritical
            followUpContent.interruptionLevel = .timeSensitive
            followUpContent.userInfo = [
                "alarmId": alarm.id.uuidString,
                "missionType": alarm.missionType,
                "soundId": alarm.soundId,
                "intensity": alarm.intensity,
                "isFollowUp": true
            ]

            var followUpComponents = baseDateComponents
            let totalMinutes = baseMinute + (i * 2)
            followUpComponents.minute = totalMinutes % 60
            followUpComponents.hour = baseHour + (totalMinutes / 60)

            let followUpTrigger = UNCalendarNotificationTrigger(dateMatching: followUpComponents, repeats: repeats)
            let followUpRequest = UNNotificationRequest(
                identifier: "\(alarm.id.uuidString)_followup_\(i)",
                content: followUpContent,
                trigger: followUpTrigger
            )
            notificationCenter.add(followUpRequest)
        }
    }

    private func buildContent(for alarm: Alarm, isSnooze: Bool) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        let mission = MissionType(rawValue: alarm.missionType) ?? .math

        if isSnooze {
            content.title = "⏰ Snooze Over"
            content.body = "Time to wake up! Complete your \(mission.displayName) mission."
        } else {
            content.title = alarm.title
            content.body = "Complete your \(mission.displayName) mission to dismiss."
        }

        content.categoryIdentifier = alarmCategoryId
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive
        content.relevanceScore = 1.0
        content.userInfo = [
            "alarmId": alarm.id.uuidString,
            "missionType": alarm.missionType,
            "soundId": alarm.soundId,
            "intensity": alarm.intensity,
            "isFollowUp": false
        ]
        return content
    }

    func cancelFollowUps(for alarm: Alarm) {
        var identifiers: [String] = []
        for i in 1...5 {
            identifiers.append("\(alarm.id.uuidString)_followup_\(i)")
        }
        identifiers.append("\(alarm.id.uuidString)_snooze")
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func convertToSystemWeekday(_ appDay: Int) -> Int {
        switch appDay {
        case 0: return 2
        case 1: return 3
        case 2: return 4
        case 3: return 5
        case 4: return 6
        case 5: return 7
        case 6: return 1
        default: return 2
        }
    }
}
