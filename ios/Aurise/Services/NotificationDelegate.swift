import Foundation
import UserNotifications

@Observable
@MainActor
class AppNotificationDelegate: NSObject, Sendable {
    var pendingAlarmId: String?
    var pendingMissionType: String?
    var pendingSoundId: String?
    var pendingIntensity: String?
    var shouldShowAlarmRinging: Bool = false
    var shouldSnooze: Bool = false

    func triggerAlarm(alarmId: String, missionType: String, soundId: String, intensity: String) {
        pendingAlarmId = alarmId
        pendingMissionType = missionType
        pendingSoundId = soundId
        pendingIntensity = intensity
        shouldShowAlarmRinging = true
    }

    func clearAlarm() {
        pendingAlarmId = nil
        pendingMissionType = nil
        pendingSoundId = nil
        pendingIntensity = nil
        shouldShowAlarmRinging = false
        shouldSnooze = false
    }
}

class NotificationDelegateHandler: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    let appDelegate: AppNotificationDelegate

    init(appDelegate: AppNotificationDelegate) {
        self.appDelegate = appDelegate
        super.init()
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        let alarmId = userInfo["alarmId"] as? String ?? ""
        let missionType = userInfo["missionType"] as? String ?? "math"
        let soundId = userInfo["soundId"] as? String ?? "clear_bell"
        let intensity = userInfo["intensity"] as? String ?? "standard"

        Task { @MainActor in
            self.appDelegate.triggerAlarm(alarmId: alarmId, missionType: missionType, soundId: soundId, intensity: intensity)
        }

        completionHandler([.sound, .banner])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let alarmId = userInfo["alarmId"] as? String ?? ""
        let missionType = userInfo["missionType"] as? String ?? "math"
        let soundId = userInfo["soundId"] as? String ?? "clear_bell"
        let intensity = userInfo["intensity"] as? String ?? "standard"

        Task { @MainActor in
            switch response.actionIdentifier {
            case "SNOOZE_ALARM":
                self.appDelegate.shouldSnooze = true
                self.appDelegate.pendingAlarmId = alarmId
                self.appDelegate.pendingSoundId = soundId
                self.appDelegate.pendingIntensity = intensity
            case UNNotificationDefaultActionIdentifier, "START_MISSION":
                self.appDelegate.triggerAlarm(alarmId: alarmId, missionType: missionType, soundId: soundId, intensity: intensity)
            case UNNotificationDismissActionIdentifier:
                self.appDelegate.triggerAlarm(alarmId: alarmId, missionType: missionType, soundId: soundId, intensity: intensity)
            default:
                self.appDelegate.triggerAlarm(alarmId: alarmId, missionType: missionType, soundId: soundId, intensity: intensity)
            }
        }

        completionHandler()
    }
}
