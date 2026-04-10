import SwiftUI

struct AlarmsListView: View {
    let alarmStore: AlarmStore
    @State private var showCreateAlarm: Bool = false
    @State private var editingAlarm: Alarm?
    @State private var showPaywall: Bool = false
    @State private var appeared: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                AuriseTheme.pageBg.ignoresSafeArea()

                if alarmStore.alarms.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(alarmStore.alarms.enumerated()), id: \.element.id) { index, alarm in
                                AlarmRowCard(alarm: alarm, alarmStore: alarmStore) {
                                    editingAlarm = alarm
                                }
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 12)
                                .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.06), value: appeared)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Alarms")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if alarmStore.canAddAlarm {
                            showCreateAlarm = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AuriseTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showCreateAlarm) {
                AlarmEditView(alarmStore: alarmStore, alarm: nil)
            }
            .sheet(item: $editingAlarm) { alarm in
                AlarmEditView(alarmStore: alarmStore, alarm: alarm)
            }
            .sheet(isPresented: $showPaywall) {
                PremiumPaywallSheet(alarmStore: alarmStore)
            }
            .onAppear {
                alarmStore.reloadAlarms()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    appeared = true
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "alarm")
                .font(.system(size: 48))
                .foregroundStyle(AuriseTheme.tertiaryText)

            Text("No alarms yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AuriseTheme.primaryText)

            Text("Create your first alarm to start\nyour wake-up system")
                .font(.subheadline)
                .foregroundStyle(AuriseTheme.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                showCreateAlarm = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Add Alarm")
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule().fill(AuriseTheme.accentGradient)
                )
            }
            .padding(.top, 8)

            if !alarmStore.isPremium {
                Text("Free plan: 1 alarm")
                    .font(.caption)
                    .foregroundStyle(AuriseTheme.tertiaryText)
            }
        }
    }
}

struct AlarmRowCard: View {
    let alarm: Alarm
    let alarmStore: AlarmStore
    let onEdit: () -> Void

    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(alarm.timeFormatted)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(alarm.isEnabled ? AuriseTheme.primaryText : AuriseTheme.tertiaryText)

                    Text(alarm.title)
                        .font(.subheadline)
                        .foregroundStyle(alarm.isEnabled ? AuriseTheme.secondaryText : AuriseTheme.tertiaryText)

                    HStack(spacing: 12) {
                        let mission = MissionType(rawValue: alarm.missionType) ?? .math
                        HStack(spacing: 4) {
                            Image(systemName: mission.icon)
                                .font(.caption2)
                            Text(mission.shortName)
                                .font(.caption)
                        }
                        .foregroundStyle(alarm.isEnabled ? mission.accentColor : AuriseTheme.tertiaryText)

                        Text(alarm.repeatSummary)
                            .font(.caption)
                            .foregroundStyle(alarm.isEnabled ? AuriseTheme.secondaryText : AuriseTheme.tertiaryText)
                    }
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { alarm.isEnabled },
                    set: { _ in alarmStore.toggleAlarm(alarm) }
                ))
                .labelsHidden()
                .tint(AuriseTheme.accent)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AuriseTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(alarm.isEnabled ? AuriseTheme.subtleBorder : AuriseTheme.subtleBorder.opacity(0.5), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: alarm.isEnabled)
    }
}
