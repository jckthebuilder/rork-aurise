import Foundation

nonisolated struct WakeUpRecord: Codable, Identifiable, Sendable {
    let id: UUID
    let date: Date
    let alarmTime: Date
    let dismissedTime: Date
    let missionType: String
    let missionCompleted: Bool

    init(id: UUID = UUID(), date: Date = Date(), alarmTime: Date = Date(), dismissedTime: Date = Date(), missionType: String = "math", missionCompleted: Bool = true) {
        self.id = id
        self.date = date
        self.alarmTime = alarmTime
        self.dismissedTime = dismissedTime
        self.missionType = missionType
        self.missionCompleted = missionCompleted
    }
}

nonisolated struct Badge: Identifiable, Sendable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let requirement: Int
    let type: BadgeType

    nonisolated enum BadgeType: Sendable {
        case streak
        case total
        case mission
    }

    static let allBadges: [Badge] = [
        Badge(id: "first_wake", name: "First Wake", icon: "sunrise.fill", description: "Complete your first morning", requirement: 1, type: .total),
        Badge(id: "streak_3", name: "3-Day Streak", icon: "flame.fill", description: "Wake up 3 days in a row", requirement: 3, type: .streak),
        Badge(id: "streak_7", name: "Week Warrior", icon: "flame.fill", description: "7-day wake-up streak", requirement: 7, type: .streak),
        Badge(id: "streak_14", name: "Two Weeks Strong", icon: "bolt.fill", description: "14-day wake-up streak", requirement: 14, type: .streak),
        Badge(id: "streak_30", name: "Monthly Master", icon: "crown.fill", description: "30-day wake-up streak", requirement: 30, type: .streak),
        Badge(id: "total_10", name: "10 Mornings", icon: "star.fill", description: "Complete 10 mornings total", requirement: 10, type: .total),
        Badge(id: "total_50", name: "50 Mornings", icon: "star.circle.fill", description: "Complete 50 mornings total", requirement: 50, type: .total),
        Badge(id: "total_100", name: "Centurion", icon: "trophy.fill", description: "Complete 100 mornings", requirement: 100, type: .total),
    ]
}

nonisolated struct ReadinessCheck: Identifiable, Sendable {
    let id: String
    let title: String
    let description: String
    var isPassed: Bool
    let icon: String
    let fixAction: String?

    static func defaultChecks(notificationsEnabled: Bool) -> [ReadinessCheck] {
        [
            ReadinessCheck(id: "notifications", title: "Notifications", description: "Required for alarm alerts", isPassed: notificationsEnabled, icon: "bell.badge.fill", fixAction: "Open Settings"),
            ReadinessCheck(id: "alarm_set", title: "Alarm Set", description: "At least one active alarm", isPassed: true, icon: "alarm.fill", fixAction: nil),
            ReadinessCheck(id: "mission_set", title: "Mission Assigned", description: "Wake-up mission configured", isPassed: true, icon: "target", fixAction: nil),
            ReadinessCheck(id: "sound_set", title: "Sound Selected", description: "Alarm sound configured", isPassed: true, icon: "speaker.wave.2.fill", fixAction: nil),
        ]
    }
}
