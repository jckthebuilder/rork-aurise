import Foundation

@Observable
@MainActor
class ProgressStore {
    var records: [WakeUpRecord] = []

    private let storageKey = "aurise_wake_records"

    init() {
        loadRecords()
    }

    var currentStreak: Int {
        guard !records.isEmpty else { return 0 }
        let calendar = Calendar.current
        let uniqueDays = Set(records.map { calendar.startOfDay(for: $0.date) })
        let sortedDays = uniqueDays.sorted(by: >)

        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        guard let mostRecent = sortedDays.first,
              mostRecent >= yesterday else { return 0 }

        var streak = 1
        var currentDay = mostRecent

        for day in sortedDays.dropFirst() {
            let expectedPrevious = calendar.date(byAdding: .day, value: -1, to: currentDay)!
            if calendar.isDate(day, inSameDayAs: expectedPrevious) {
                streak += 1
                currentDay = day
            } else if calendar.isDate(day, inSameDayAs: currentDay) {
                continue
            } else {
                break
            }
        }
        return streak
    }

    var longestStreak: Int {
        guard !records.isEmpty else { return 0 }
        let calendar = Calendar.current
        let uniqueDays = Set(records.map { calendar.startOfDay(for: $0.date) }).sorted()

        guard !uniqueDays.isEmpty else { return 0 }

        var longest = 1
        var current = 1

        for i in 1..<uniqueDays.count {
            let diff = calendar.dateComponents([.day], from: uniqueDays[i - 1], to: uniqueDays[i]).day ?? 0
            if diff == 1 {
                current += 1
                longest = max(longest, current)
            } else if diff > 1 {
                current = 1
            }
        }
        return longest
    }

    var totalWakeUps: Int { records.count }

    var thisWeekCount: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return records.filter { $0.date >= startOfWeek }.count
    }

    var thisMonthCount: Int {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
        return records.filter { $0.date >= startOfMonth }.count
    }

    var averageWakeUpTime: String? {
        guard !records.isEmpty else { return nil }
        let calendar = Calendar.current
        let totalMinutes = records.reduce(0) { sum, record in
            let comps = calendar.dateComponents([.hour, .minute], from: record.dismissedTime)
            return sum + (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
        }
        let avg = totalMinutes / records.count
        let hour = avg / 60
        let minute = avg % 60
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        let date = calendar.date(from: comps) ?? Date()
        return date.formatted(date: .omitted, time: .shortened)
    }

    var favoriteMission: String? {
        guard !records.isEmpty else { return nil }
        let counts = Dictionary(grouping: records, by: \.missionType).mapValues(\.count)
        return counts.max(by: { $0.value < $1.value })?.key
    }

    var weeklyConsistency: Double {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        let daysSinceStart = max(1, (calendar.dateComponents([.day], from: startOfWeek, to: Date()).day ?? 0) + 1)
        let target = min(daysSinceStart, 7)
        guard target > 0 else { return 0 }
        return min(1.0, Double(thisWeekCount) / Double(target))
    }

    var completedDatesThisMonth: Set<Date> {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
        return Set(
            records
                .filter { $0.date >= startOfMonth }
                .map { calendar.startOfDay(for: $0.date) }
        )
    }

    var earnedBadges: [Badge] {
        Badge.allBadges.filter { badge in
            switch badge.type {
            case .streak: currentStreak >= badge.requirement
            case .total: totalWakeUps >= badge.requirement
            case .mission: false
            }
        }
    }

    var nextBadge: Badge? {
        Badge.allBadges.first { badge in
            switch badge.type {
            case .streak: currentStreak < badge.requirement
            case .total: totalWakeUps < badge.requirement
            case .mission: true
            }
        }
    }

    func addRecord(_ record: WakeUpRecord) {
        records.append(record)
        saveRecords()
    }

    func hasRecordForToday() -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return records.contains { calendar.isDate($0.date, inSameDayAs: today) }
    }

    func recordsForDate(_ date: Date) -> [WakeUpRecord] {
        let calendar = Calendar.current
        return records.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func saveRecords() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadRecords() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([WakeUpRecord].self, from: data) else { return }
        records = decoded
    }
}
