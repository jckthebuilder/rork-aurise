import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var alarmStore = AlarmStore()
    @State private var progressStore = ProgressStore()
    @Environment(AppNotificationDelegate.self) private var notificationDelegate

    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                MainTabView(alarmStore: alarmStore, progressStore: progressStore)
                    .transition(.opacity)
                    .onAppear {
                        Task {
                            await AlarmScheduler.shared.requestPermission()
                        }
                    }
            } else {
                OnboardingContainerView(hasCompletedOnboarding: $hasCompletedOnboarding, alarmStore: alarmStore)
                    .transition(.opacity)
            }

            if notificationDelegate.shouldShowAlarmRinging {
                alarmRingingOverlay
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        .onChange(of: notificationDelegate.shouldShowAlarmRinging) { _, newValue in
            if newValue {
                let soundId = notificationDelegate.pendingSoundId ?? "clear_bell"
                let intensity = notificationDelegate.pendingIntensity ?? "standard"
                SoundService.shared.playAlarmSound(soundId, intensity: intensity)
            }
        }
        .onChange(of: notificationDelegate.shouldSnooze) { _, newValue in
            if newValue, let alarmId = notificationDelegate.pendingAlarmId,
               let alarm = alarmStore.alarmById(alarmId) {
                alarmStore.snoozeAlarm(alarm)
                SoundService.shared.stopSound()
                notificationDelegate.clearAlarm()
            }
        }
    }

    @ViewBuilder
    private var alarmRingingOverlay: some View {
        let missionRaw = notificationDelegate.pendingMissionType ?? "math"
        let mission = MissionType(rawValue: missionRaw) ?? .math
        let alarm = notificationDelegate.pendingAlarmId.flatMap { alarmStore.alarmById($0) }

        AlarmRingingView(
            alarm: alarm,
            missionType: mission,
            onDismiss: {
                let record = WakeUpRecord(
                    date: Date(),
                    alarmTime: alarm?.time ?? Date(),
                    dismissedTime: Date(),
                    missionType: missionRaw,
                    missionCompleted: true
                )
                progressStore.addRecord(record)

                if let alarm {
                    alarmStore.dismissAlarm(alarm)
                }

                SoundService.shared.stopSound()
                notificationDelegate.clearAlarm()
            },
            onSnooze: {
                if let alarm {
                    alarmStore.snoozeAlarm(alarm)
                }
                SoundService.shared.stopSound()
                notificationDelegate.clearAlarm()
            }
        )
    }
}

struct MainTabView: View {
    let alarmStore: AlarmStore
    let progressStore: ProgressStore
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                HomeView(alarmStore: alarmStore, progressStore: progressStore)
            }

            Tab("Alarms", systemImage: "alarm.fill", value: 1) {
                AlarmsListView(alarmStore: alarmStore)
            }

            Tab("Progress", systemImage: "chart.bar.fill", value: 2) {
                AuriseProgressView(progressStore: progressStore, alarmStore: alarmStore)
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 3) {
                SettingsView(alarmStore: alarmStore)
            }
        }
        .tint(AuriseTheme.accent)
        .onChange(of: selectedTab) { _, newTab in
            if newTab == 1 {
                alarmStore.reloadAlarms()
            }
        }
    }
}
