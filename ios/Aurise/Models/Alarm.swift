import Foundation

nonisolated struct Alarm: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var title: String
    var time: Date
    var repeatDays: Set<Int>
    var missionType: String
    var soundId: String
    var intensity: String
    var isEnabled: Bool
    var isOneTime: Bool

    init(
        id: UUID = UUID(),
        title: String = "Morning Alarm",
        time: Date = {
            var c = DateComponents()
            c.hour = 7; c.minute = 0
            return Calendar.current.date(from: c) ?? Date()
        }(),
        repeatDays: Set<Int> = [0, 1, 2, 3, 4],
        missionType: String = "math",
        soundId: String = "clear_bell",
        intensity: String = "standard",
        isEnabled: Bool = true,
        isOneTime: Bool = false
    ) {
        self.id = id
        self.title = title
        self.time = time
        self.repeatDays = repeatDays
        self.missionType = missionType
        self.soundId = soundId
        self.intensity = intensity
        self.isEnabled = isEnabled
        self.isOneTime = isOneTime
    }

    var timeFormatted: String {
        time.formatted(date: .omitted, time: .shortened)
    }

    var repeatSummary: String {
        if isOneTime { return "Once" }
        if repeatDays.count == 7 { return "Every day" }
        if repeatDays == Set([0, 1, 2, 3, 4]) { return "Weekdays" }
        if repeatDays == Set([5, 6]) { return "Weekends" }
        let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let sorted = repeatDays.sorted()
        return sorted.map { dayNames[$0] }.joined(separator: ", ")
    }

    var nextRingDate: Date? {
        let calendar = Calendar.current
        let now = Date()
        let todayComponents = calendar.dateComponents([.hour, .minute], from: time)

        if isOneTime {
            var candidate = calendar.date(bySettingHour: todayComponents.hour ?? 7, minute: todayComponents.minute ?? 0, second: 0, of: now) ?? now
            if candidate <= now {
                candidate = calendar.date(byAdding: .day, value: 1, to: candidate) ?? candidate
            }
            return candidate
        }

        guard !repeatDays.isEmpty else { return nil }

        for dayOffset in 0..<8 {
            let candidate = calendar.date(byAdding: .day, value: dayOffset, to: now) ?? now
            let weekdayIndex = (calendar.component(.weekday, from: candidate) + 5) % 7
            if repeatDays.contains(weekdayIndex) {
                let alarmTime = calendar.date(bySettingHour: todayComponents.hour ?? 7, minute: todayComponents.minute ?? 0, second: 0, of: candidate) ?? candidate
                if alarmTime > now {
                    return alarmTime
                }
            }
        }
        return nil
    }
}
