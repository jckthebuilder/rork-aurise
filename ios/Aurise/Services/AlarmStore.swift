import Foundation
import UserNotifications

@Observable
@MainActor
class AlarmStore {
    var alarms: [Alarm] = []
    var isPremium: Bool = false

    private let storageKey = "aurise_alarms"
    private let premiumKey = "aurise_is_premium"
    private let scheduler = AlarmScheduler.shared

    init() {
        loadAlarms()
        isPremium = UserDefaults.standard.bool(forKey: premiumKey)
        if #available(iOS 26.0, *) {
            Task {
                if AlarmKitScheduler.shared.isAuthorized() {
                    await AlarmKitScheduler.shared.rescheduleAll(alarms)
                }
            }
        } else {
            scheduler.rescheduleAllAlarms(alarms)
        }
    }

    var nextAlarm: Alarm? {
        alarms
            .filter(\.isEnabled)
            .compactMap { alarm in
                guard let nextRing = alarm.nextRingDate else { return nil as (Alarm, Date)? }
                return (alarm, nextRing)
            }
            .min(by: { $0.1 < $1.1 })
            .map(\.0)
    }

    var activeAlarmCount: Int {
        alarms.filter(\.isEnabled).count
    }

    var canAddAlarm: Bool {
        isPremium || alarms.count < 1
    }

    func timeUntilNextAlarm() -> String? {
        guard let alarm = nextAlarm, let ringDate = alarm.nextRingDate else { return nil }
        let interval = ringDate.timeIntervalSince(Date())
        guard interval > 0 else { return nil }
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "Rings in \(hours)h \(minutes)m"
        }
        return "Rings in \(minutes)m"
    }

    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        saveAlarms()
        scheduleBackend(alarm)
    }

    func updateAlarm(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index] = alarm
            saveAlarms()
            scheduleBackend(alarm)
        }
    }

    func deleteAlarm(_ alarm: Alarm) {
        cancelBackend(alarm)
        alarms.removeAll { $0.id == alarm.id }
        saveAlarms()
    }

    func toggleAlarm(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index].isEnabled.toggle()
            saveAlarms()
            scheduleBackend(alarms[index])
        }
    }

    private func scheduleBackend(_ alarm: Alarm) {
        if #available(iOS 26.0, *) {
            Task { await AlarmKitScheduler.shared.schedule(alarm) }
        } else {
            scheduler.scheduleAlarm(alarm)
        }
    }

    private func cancelBackend(_ alarm: Alarm) {
        if #available(iOS 26.0, *) {
            Task { await AlarmKitScheduler.shared.cancel(alarm) }
        } else {
            scheduler.cancelAlarm(alarm)
        }
    }

    func requestAlarmAuthorization() async -> Bool {
        if #available(iOS 26.0, *) {
            return await AlarmKitScheduler.shared.requestAuthorization()
        } else {
            return await scheduler.requestPermission()
        }
    }

    func alarmById(_ id: String) -> Alarm? {
        alarms.first { $0.id.uuidString == id }
    }

    func snoozeAlarm(_ alarm: Alarm) {
        if #available(iOS 26.0, *) {
        } else {
            scheduler.scheduleSnooze(for: alarm)
        }
    }

    func dismissAlarm(_ alarm: Alarm) {
        scheduler.cancelFollowUps(for: alarm)

        if alarm.isOneTime {
            if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
                alarms[index].isEnabled = false
                saveAlarms()
            }
        }
    }

    func setPremium(_ value: Bool) {
        isPremium = value
        UserDefaults.standard.set(value, forKey: premiumKey)
    }

    func createAlarmFromOnboarding(vm: OnboardingViewModel) {
        guard alarms.isEmpty else { return }
        let dayInts = Set(vm.activeDays.map(\.rawValue))
        let alarm = Alarm(
            title: "Morning Alarm",
            time: vm.targetWakeUpTime,
            repeatDays: dayInts,
            missionType: vm.effectiveMission.rawValue,
            soundId: vm.selectedSoundId,
            intensity: (vm.alarmIntensity ?? .standard).rawValue.lowercased(),
            isEnabled: true
        )
        addAlarm(alarm)
    }

    private func saveAlarms() {
        if let data = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func reloadAlarms() {
        loadAlarms()
    }

    private func loadAlarms() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Alarm].self, from: data) else { return }
        alarms = decoded
    }
}
