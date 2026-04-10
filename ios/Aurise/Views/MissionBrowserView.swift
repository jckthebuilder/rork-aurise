import SwiftUI

struct MissionBrowserView: View {
    let alarmStore: AlarmStore
    let selectedAlarm: Alarm
    @Environment(\.dismiss) private var dismiss
    @State private var showPaywall: Bool = false
    @State private var appeared: Bool = false
    @State private var previewMission: MissionType? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                AuriseTheme.pageBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Wake-Up Missions")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(AuriseTheme.primaryText)
                            Text("Choose a task that forces you out of bed")
                                .font(.subheadline)
                                .foregroundStyle(AuriseTheme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("FREE")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AuriseTheme.tertiaryText)
                                .tracking(1.2)

                            ForEach(Array(MissionType.freeMissions.enumerated()), id: \.element.id) { index, mission in
                                MissionBrowserCard(
                                    mission: mission,
                                    isSelected: selectedAlarm.missionType == mission.rawValue,
                                    isLocked: false,
                                    onPreview: { previewMission = mission }
                                ) {
                                    selectMission(mission)
                                }
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 12)
                                .animation(.spring(response: 0.4).delay(Double(index) * 0.05), value: appeared)
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Text("PREMIUM")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(AuriseTheme.tertiaryText)
                                    .tracking(1.2)

                                if !alarmStore.isPremium {
                                    Image(systemName: "lock.fill")
                                        .font(.caption2)
                                        .foregroundStyle(AuriseTheme.accent)
                                }
                            }

                            ForEach(Array(MissionType.featuredPremium.enumerated()), id: \.element.id) { index, mission in
                                MissionBrowserCard(
                                    mission: mission,
                                    isSelected: selectedAlarm.missionType == mission.rawValue,
                                    isLocked: !alarmStore.isPremium,
                                    onPreview: { previewMission = mission }
                                ) {
                                    if alarmStore.isPremium {
                                        selectMission(mission)
                                    } else {
                                        showPaywall = true
                                    }
                                }
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 12)
                                .animation(.spring(response: 0.4).delay(Double(index + 2) * 0.05), value: appeared)
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("MORE")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AuriseTheme.tertiaryText)
                                .tracking(1.2)

                            ForEach(Array(MissionType.secondaryPremium.enumerated()), id: \.element.id) { index, mission in
                                MissionBrowserCard(
                                    mission: mission,
                                    isSelected: selectedAlarm.missionType == mission.rawValue,
                                    isLocked: !alarmStore.isPremium,
                                    onPreview: { previewMission = mission }
                                ) {
                                    if alarmStore.isPremium {
                                        selectMission(mission)
                                    } else {
                                        showPaywall = true
                                    }
                                }
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 12)
                                .animation(.spring(response: 0.4).delay(Double(index + 7) * 0.05), value: appeared)
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PremiumPaywallSheet(alarmStore: alarmStore)
            }
            .fullScreenCover(item: $previewMission) { mission in
                MissionPreviewWrapper(mission: mission) {
                    previewMission = nil
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.5)) {
                    appeared = true
                }
            }
        }
    }

    private func selectMission(_ mission: MissionType) {
        var updated = selectedAlarm
        updated.missionType = mission.rawValue
        alarmStore.updateAlarm(updated)
        dismiss()
    }
}

struct MissionPreviewWrapper: View {
    let mission: MissionType
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MissionExecutionView(missionType: mission, onComplete: onDismiss)

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(16)
            }
        }
    }
}

struct MissionBrowserCard: View {
    let mission: MissionType
    let isSelected: Bool
    let isLocked: Bool
    var onPreview: (() -> Void)? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(mission.accentColor.opacity(isLocked ? 0.08 : 0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: mission.icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(isLocked ? AuriseTheme.tertiaryText : mission.accentColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(mission.displayName)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(isLocked ? AuriseTheme.tertiaryText : AuriseTheme.primaryText)

                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                                .foregroundStyle(AuriseTheme.tertiaryText)
                        }
                    }

                    Text(mission.subtitle)
                        .font(.caption)
                        .foregroundStyle(isLocked ? AuriseTheme.tertiaryText : AuriseTheme.secondaryText)
                        .lineLimit(2)

                    HStack(spacing: 3) {
                        ForEach(0..<5, id: \.self) { i in
                            Circle()
                                .fill(i < mission.wakeStrength ? mission.accentColor.opacity(isLocked ? 0.2 : 0.7) : AuriseTheme.subtleFill)
                                .frame(width: 6, height: 6)
                        }
                        Text("Wake power")
                            .font(.caption2)
                            .foregroundStyle(AuriseTheme.tertiaryText)
                            .padding(.leading, 2)
                    }
                    .padding(.top, 2)
                }

                Spacer()

                VStack(spacing: 6) {
                    if let onPreview {
                        Button {
                            onPreview()
                        } label: {
                            Text("Try")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(mission.accentColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(mission.accentColor.opacity(0.12))
                                )
                        }
                    }

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(AuriseTheme.accent)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? AuriseTheme.cardSelectedFill : AuriseTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? AuriseTheme.cardSelectedBorder : AuriseTheme.subtleBorder, lineWidth: isSelected ? 1.5 : 0.5)
            )
        }
        .buttonStyle(CardButtonStyle())
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

struct MissionPickerSheet: View {
    let alarmStore: AlarmStore
    @Binding var selectedMission: String
    @Environment(\.dismiss) private var dismiss
    @State private var showPaywall: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                AuriseTheme.pageBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(MissionType.freeMissions) { mission in
                            MissionPickerRow(mission: mission, isSelected: selectedMission == mission.rawValue, isLocked: false) {
                                selectedMission = mission.rawValue
                                dismiss()
                            }
                        }

                        ForEach(MissionType.featuredPremium) { mission in
                            MissionPickerRow(mission: mission, isSelected: selectedMission == mission.rawValue, isLocked: !alarmStore.isPremium) {
                                if alarmStore.isPremium {
                                    selectedMission = mission.rawValue
                                    dismiss()
                                } else {
                                    showPaywall = true
                                }
                            }
                        }

                        ForEach(MissionType.secondaryPremium) { mission in
                            MissionPickerRow(mission: mission, isSelected: selectedMission == mission.rawValue, isLocked: !alarmStore.isPremium) {
                                if alarmStore.isPremium {
                                    selectedMission = mission.rawValue
                                    dismiss()
                                } else {
                                    showPaywall = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Choose Mission")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PremiumPaywallSheet(alarmStore: alarmStore)
            }
        }
    }
}

struct MissionPickerRow: View {
    let mission: MissionType
    let isSelected: Bool
    let isLocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(mission.accentColor.opacity(isLocked ? 0.08 : 0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: mission.icon)
                        .font(.body.weight(.medium))
                        .foregroundStyle(isLocked ? AuriseTheme.tertiaryText : mission.accentColor)
                }

                Text(mission.displayName)
                    .font(.body.weight(.medium))
                    .foregroundStyle(isLocked ? AuriseTheme.tertiaryText : AuriseTheme.primaryText)

                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(AuriseTheme.tertiaryText)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AuriseTheme.accent)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? AuriseTheme.cardSelectedFill : AuriseTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isSelected ? AuriseTheme.cardSelectedBorder : AuriseTheme.subtleBorder, lineWidth: isSelected ? 1.5 : 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}
