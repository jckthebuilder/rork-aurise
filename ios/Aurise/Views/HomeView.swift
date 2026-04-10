import SwiftUI
import UserNotifications

struct HomeView: View {
    let alarmStore: AlarmStore
    let progressStore: ProgressStore
    @State private var notificationsEnabled: Bool = false
    @State private var showEditAlarm: Bool = false
    @State private var showMissionBrowser: Bool = false
    @State private var appeared: Bool = false
    @State private var selectedDate: Date = Date()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AppNotificationDelegate.self) private var notificationDelegate

    var body: some View {
        NavigationStack {
            ZStack {
                AuriseTheme.pageBg.ignoresSafeArea()
                AdaptiveMeshBackground().opacity(0.6)

                VStack(spacing: 14) {
                    headerSection
                    weekCalendarStrip
                    nextAlarmCard
                    missionAndSoundRow
                    alarmReadinessCard
                    statsRow
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditAlarm) {
                if let alarm = alarmStore.nextAlarm {
                    AlarmEditView(alarmStore: alarmStore, alarm: alarm)
                }
            }
            .sheet(isPresented: $showMissionBrowser) {
                if let alarm = alarmStore.nextAlarm {
                    MissionBrowserView(alarmStore: alarmStore, selectedAlarm: alarm)
                }
            }
            .onAppear {
                checkNotifications()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    appeared = true
                }
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Text("Aurise")
                .font(.system(.title2, weight: .bold))
                .foregroundStyle(AuriseTheme.primaryText)

            Spacer()

            if let next = alarmStore.nextAlarm, next.isEnabled {
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 7, height: 7)
                    Text("Active")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.green)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.green.opacity(0.1)))
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private var weekCalendarStrip: some View {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today) ?? today
        let days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
        let dayLetters = ["S", "M", "T", "W", "T", "F", "S"]

        return HStack(spacing: 0) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                let isToday = calendar.isDateInToday(date)
                let dayNum = calendar.component(.day, from: date)
                let hasAlarmOnDay = alarmForDay(date) != nil

                Button {
                    withAnimation(.snappy(duration: 0.25)) {
                        selectedDate = date
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(dayLetters[index])
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(isToday ? AuriseTheme.accent : AuriseTheme.tertiaryText)

                        ZStack {
                            Circle()
                                .fill(isToday ? AuriseTheme.accent : .clear)
                                .frame(width: 32, height: 32)

                            Text("\(dayNum)")
                                .font(.caption.weight(isToday ? .bold : .medium))
                                .foregroundStyle(isToday ? .white : AuriseTheme.primaryText)
                        }

                        Circle()
                            .fill(hasAlarmOnDay ? AuriseTheme.accent : .clear)
                            .frame(width: 4, height: 4)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AuriseTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func alarmForDay(_ date: Date) -> Alarm? {
        let calendar = Calendar.current
        let weekdayIndex = (calendar.component(.weekday, from: date) + 5) % 7
        return alarmStore.alarms.first { alarm in
            alarm.isEnabled && (alarm.isOneTime || alarm.repeatDays.contains(weekdayIndex))
        }
    }

    private var nextAlarmCard: some View {
        Button {
            if alarmStore.nextAlarm != nil {
                showEditAlarm = true
            }
        } label: {
            if let alarm = alarmStore.nextAlarm {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(alarm.title.uppercased())
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(AuriseTheme.accent)
                            .tracking(1.0)

                        Text(alarm.timeFormatted)
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(AuriseTheme.primaryText)
                            .contentTransition(.numericText())

                        Text(alarm.repeatSummary)
                            .font(.caption)
                            .foregroundStyle(AuriseTheme.secondaryText)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(AuriseTheme.accent.opacity(0.12))
                            .frame(width: 50, height: 50)

                        Image(systemName: "alarm.fill")
                            .font(.title3)
                            .foregroundStyle(AuriseTheme.accent)
                            .symbolEffect(.pulse, options: .repeating, isActive: alarm.isEnabled)
                    }
                }
                .padding(16)
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "alarm")
                        .font(.system(size: 28))
                        .foregroundStyle(AuriseTheme.tertiaryText)
                    Text("No alarm set")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AuriseTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AuriseTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
        )
        .shadow(color: AuriseTheme.accentGlow.opacity(0.08), radius: 16, y: 6)
        .buttonStyle(CardButtonStyle())
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private var missionAndSoundRow: some View {
        HStack(spacing: 10) {
            if let alarm = alarmStore.nextAlarm {
                let mission = MissionType(rawValue: alarm.missionType) ?? .math
                Button {
                    showMissionBrowser = true
                } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(mission.accentColor.opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: mission.icon)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(mission.accentColor)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Mission")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(AuriseTheme.tertiaryText)
                            Text(mission.shortName)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AuriseTheme.primaryText)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AuriseTheme.cardFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
                    )
                }
                .buttonStyle(CardButtonStyle())

                Button {
                    showEditAlarm = true
                } label: {
                    let soundName = AlarmSound.defaults.first { $0.id == alarm.soundId }?.name ?? "Default"
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(AuriseTheme.accent.opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AuriseTheme.accent)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sound")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(AuriseTheme.tertiaryText)
                            Text(soundName)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AuriseTheme.primaryText)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AuriseTheme.cardFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
                    )
                }
                .buttonStyle(CardButtonStyle())
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private var alarmReadinessCard: some View {
        let hasAlarm = alarmStore.activeAlarmCount > 0
        let hasMission = alarmStore.nextAlarm != nil
        let allGood = notificationsEnabled && hasAlarm && hasMission

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: allGood ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                    .foregroundStyle(allGood ? Color.green : Color.orange)
                Text("Alarm Readiness")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AuriseTheme.primaryText)
                Spacer()
                if !allGood {
                    Text("Action needed")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.orange.opacity(0.12)))
                }
            }

            ReadinessRow(icon: "bell.badge.fill", title: "Notifications", isPassed: notificationsEnabled)
            ReadinessRow(icon: "alarm.fill", title: "Active alarm", isPassed: hasAlarm)
            if let alarm = alarmStore.nextAlarm {
                let mission = MissionType(rawValue: alarm.missionType) ?? .math
                ReadinessRow(icon: "target", title: "Mission: \(mission.shortName)", isPassed: true)
            }

            if !notificationsEnabled {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "gearshape.fill")
                            .font(.caption2)
                        Text("Enable in Settings")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(AuriseTheme.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule().fill(AuriseTheme.accent.opacity(0.12))
                    )
                }
                .padding(.top, 2)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AuriseTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                    .font(.subheadline)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Streak")
                        .font(.caption2)
                        .foregroundStyle(AuriseTheme.tertiaryText)
                    Text("\(progressStore.currentStreak)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AuriseTheme.primaryText)
                }
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AuriseTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
            )

            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(AuriseTheme.accent)
                    .font(.subheadline)
                VStack(alignment: .leading, spacing: 1) {
                    Text("This week")
                        .font(.caption2)
                        .foregroundStyle(AuriseTheme.tertiaryText)
                    Text("\(progressStore.thisWeekCount)/7")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AuriseTheme.primaryText)
                }
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AuriseTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private func checkNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
}

struct ReadinessRow: View {
    let icon: String
    let title: String
    let isPassed: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(isPassed ? Color.green : Color.orange)
                .frame(width: 20)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(AuriseTheme.primaryText)
            Spacer()
            Image(systemName: isPassed ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .font(.caption)
                .foregroundStyle(isPassed ? Color.green : Color.orange)
        }
    }
}
