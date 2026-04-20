import SwiftUI
import UserNotifications
#if canImport(AlarmKit)
import AlarmKit
#endif

@Observable
@MainActor
class OnboardingViewModel {
    var currentStep: Int = 0
    let totalSteps: Int = 23

    var morningEase: MorningEase?
    var bedReason: BedReason?
    var alarmCount: AlarmCount?
    var singleAlarmWorks: SingleAlarmWorks?
    var targetWakeUpTime: Date = {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    var currentWakeUpTime: Date = {
        var components = DateComponents()
        components.hour = 8
        components.minute = 30
        return Calendar.current.date(from: components) ?? Date()
    }()
    var selectedMission: MissionType?
    var selectedSoundId: String = AlarmSound.defaults[0].id
    var alarmIntensity: AlarmIntensity?
    var activeDays: Set<Weekday> = Weekday.weekdays
    var isPremium: Bool = false
    var playingSoundId: String?

    var progress: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(currentStep) / Double(totalSteps - 1)
    }

    var canContinue: Bool {
        switch currentStep {
        case 0, 5, 6, 7, 8, 9, 10: return true
        case 1: return morningEase != nil
        case 2: return bedReason != nil
        case 3: return alarmCount != nil
        case 4: return singleAlarmWorks != nil
        case 11: return selectedMission != nil
        case 12: return selectedMission != nil
        case 13: return true
        case 14: return alarmIntensity != nil
        case 15: return !activeDays.isEmpty
        case 16, 17, 18, 19, 20, 21, 22: return true
        default: return true
        }
    }

    var targetTimeFormatted: String {
        targetWakeUpTime.formatted(date: .omitted, time: .shortened)
    }

    var currentTimeFormatted: String {
        currentWakeUpTime.formatted(date: .omitted, time: .shortened)
    }

    var selectedSound: AlarmSound {
        AlarmSound.defaults.first { $0.id == selectedSoundId } ?? AlarmSound.defaults[0]
    }

    var effectiveMission: MissionType {
        guard let selected = selectedMission else { return .math }
        if isPremium || !selected.isPremium { return selected }
        return .math
    }

    var activeDaysSummary: String {
        if activeDays.count == 7 { return "Every day" }
        if activeDays == Weekday.weekdays { return "Weekdays" }
        if activeDays == Set([Weekday.sat, .sun]) { return "Weekends" }
        let sorted = activeDays.sorted { $0.rawValue < $1.rawValue }
        return sorted.map(\.fullName).joined(separator: ", ")
    }

    func advance() {
        guard currentStep < totalSteps - 1 else { return }
        currentStep += 1
    }

    func toggleDay(_ day: Weekday) {
        if activeDays.contains(day) {
            activeDays.remove(day)
        } else {
            activeDays.insert(day)
        }
    }

    func toggleSound(_ id: String) {
        if playingSoundId == id {
            playingSoundId = nil
        } else {
            playingSoundId = id
        }
    }

    func requestAlarmKitAuthorization() async {
        if #available(iOS 26.0, *) {
            let manager = AlarmManager.shared
            if manager.authorizationState == .notDetermined {
                try? await manager.requestAuthorization()
            }
        }
    }

    func requestNotifications() async {
        let center = UNUserNotificationCenter.current()
        do {
            let _ = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {}
    }

    func completeOnboarding() {
        UserDefaults.standard.set(targetWakeUpTime, forKey: "onboarding_target_time")
        UserDefaults.standard.set(effectiveMission.rawValue, forKey: "onboarding_mission")
        UserDefaults.standard.set(selectedSoundId, forKey: "onboarding_sound")
        UserDefaults.standard.set((alarmIntensity ?? .standard).rawValue.lowercased(), forKey: "onboarding_intensity")
        let dayInts = Set(activeDays.map(\.rawValue))
        if let data = try? JSONEncoder().encode(dayInts) {
            UserDefaults.standard.set(data, forKey: "onboarding_active_days")
        }
        UserDefaults.standard.set(isPremium, forKey: "aurise_is_premium")
    }
}
