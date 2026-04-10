import SwiftUI

struct AlarmEditView: View {
    @Environment(\.dismiss) private var dismiss
    let alarmStore: AlarmStore
    let alarm: Alarm?

    @State private var title: String
    @State private var time: Date
    @State private var repeatDays: Set<Int>
    @State private var missionType: String
    @State private var soundId: String
    @State private var intensity: String
    @State private var isOneTime: Bool
    @State private var showMissionPicker: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var playingSoundId: String?

    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    init(alarmStore: AlarmStore, alarm: Alarm?) {
        self.alarmStore = alarmStore
        self.alarm = alarm
        _title = State(initialValue: alarm?.title ?? "Morning Alarm")
        _time = State(initialValue: alarm?.time ?? {
            var c = DateComponents(); c.hour = 7; c.minute = 0
            return Calendar.current.date(from: c) ?? Date()
        }())
        _repeatDays = State(initialValue: alarm?.repeatDays ?? Set([0, 1, 2, 3, 4]))
        _missionType = State(initialValue: alarm?.missionType ?? "math")
        _soundId = State(initialValue: alarm?.soundId ?? "clear_bell")
        _intensity = State(initialValue: alarm?.intensity ?? "standard")
        _isOneTime = State(initialValue: alarm?.isOneTime ?? false)
    }

    private var isEditing: Bool { alarm != nil }

    var body: some View {
        NavigationStack {
            ZStack {
                AuriseTheme.pageBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        timePickerSection
                        labelSection
                        repeatSection
                        missionSection
                        soundSection
                        intensitySection

                        if isEditing {
                            deleteSection
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle(isEditing ? "Edit Alarm" : "New Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAlarm()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Delete Alarm?", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let alarm {
                        alarmStore.deleteAlarm(alarm)
                    }
                    dismiss()
                }
            } message: {
                Text("This alarm will be permanently removed.")
            }
        }
    }

    private var timePickerSection: some View {
        DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }

    private var labelSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LABEL")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AuriseTheme.tertiaryText)
                .tracking(1)

            TextField("Alarm name", text: $title)
                .font(.body)
                .foregroundStyle(AuriseTheme.primaryText)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AuriseTheme.cardFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
                )
        }
    }

    private var repeatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("REPEAT")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AuriseTheme.tertiaryText)
                    .tracking(1)

                Spacer()

                Toggle("One-time", isOn: $isOneTime)
                    .font(.subheadline)
                    .foregroundStyle(AuriseTheme.secondaryText)
                    .tint(AuriseTheme.accent)
                    .fixedSize()
            }

            if !isOneTime {
                HStack(spacing: 8) {
                    ForEach(0..<7, id: \.self) { index in
                        let isSelected = repeatDays.contains(index)
                        Button {
                            if isSelected {
                                repeatDays.remove(index)
                            } else {
                                repeatDays.insert(index)
                            }
                        } label: {
                            Text(dayLabels[index])
                                .font(.caption.weight(.semibold))
                                .frame(width: 38, height: 38)
                                .foregroundStyle(isSelected ? .white : AuriseTheme.secondaryText)
                                .background(
                                    Circle()
                                        .fill(isSelected ? AuriseTheme.accent : AuriseTheme.cardFill)
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(isSelected ? Color.clear : AuriseTheme.subtleBorder, lineWidth: 0.5)
                                )
                        }
                        .sensoryFeedback(.selection, trigger: isSelected)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var missionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MISSION")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AuriseTheme.tertiaryText)
                .tracking(1)

            let mission = MissionType(rawValue: missionType) ?? .math

            Button {
                showMissionPicker = true
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(mission.accentColor.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: mission.icon)
                            .font(.body.weight(.medium))
                            .foregroundStyle(mission.accentColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(mission.displayName)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(AuriseTheme.primaryText)
                        Text(mission.subtitle)
                            .font(.caption)
                            .foregroundStyle(AuriseTheme.secondaryText)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AuriseTheme.tertiaryText)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AuriseTheme.cardFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showMissionPicker) {
                MissionPickerSheet(alarmStore: alarmStore, selectedMission: $missionType)
            }
        }
    }

    private var soundSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SOUND")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AuriseTheme.tertiaryText)
                .tracking(1)

            let currentSound = AlarmSound.defaults.first { $0.id == soundId } ?? AlarmSound.defaults[0]

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(AlarmSound.defaults) { sound in
                        let isSelected = sound.id == soundId
                        Button {
                            soundId = sound.id
                            SoundService.shared.previewSound(sound.id, intensity: intensity)
                            playingSoundId = SoundService.shared.isPlaying ? sound.id : nil
                        } label: {
                            VStack(spacing: 6) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(isSelected ? AuriseTheme.accent.opacity(0.15) : AuriseTheme.cardFill)
                                        .frame(width: 56, height: 56)
                                    Image(systemName: isSelected && playingSoundId == sound.id ? "speaker.wave.2.fill" : sound.icon)
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(isSelected ? AuriseTheme.accent : AuriseTheme.secondaryText)
                                        .symbolEffect(.variableColor.iterative, isActive: playingSoundId == sound.id)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(isSelected ? AuriseTheme.accent.opacity(0.4) : AuriseTheme.subtleBorder, lineWidth: isSelected ? 1.5 : 0.5)
                                )

                                Text(sound.name)
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(isSelected ? AuriseTheme.primaryText : AuriseTheme.secondaryText)
                                    .lineLimit(1)
                            }
                            .frame(width: 72)
                        }
                        .buttonStyle(.plain)
                        .sensoryFeedback(.selection, trigger: isSelected)
                    }
                }
                .padding(.horizontal, 2)
            }
            .contentMargins(.horizontal, 0)
        }
    }

    private var intensitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("INTENSITY")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AuriseTheme.tertiaryText)
                .tracking(1)

            HStack(spacing: 10) {
                ForEach(["gentle", "standard", "hardToIgnore"], id: \.self) { level in
                    let isSelected = intensity == level
                    let label: String = {
                        switch level {
                        case "gentle": return "Gentle"
                        case "standard": return "Standard"
                        case "hardToIgnore": return "Hard to ignore"
                        default: return level
                        }
                    }()
                    let icon: String = {
                        switch level {
                        case "gentle": return "speaker.wave.1.fill"
                        case "standard": return "speaker.wave.2.fill"
                        case "hardToIgnore": return "speaker.wave.3.fill"
                        default: return "speaker.fill"
                        }
                    }()

                    Button {
                        intensity = level
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: icon)
                                .font(.body)
                                .foregroundStyle(isSelected ? AuriseTheme.accent : AuriseTheme.secondaryText)
                            Text(label)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(isSelected ? AuriseTheme.primaryText : AuriseTheme.secondaryText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isSelected ? AuriseTheme.accent.opacity(0.12) : AuriseTheme.cardFill)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(isSelected ? AuriseTheme.accent.opacity(0.4) : AuriseTheme.subtleBorder, lineWidth: isSelected ? 1.5 : 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.selection, trigger: isSelected)
                }
            }
        }
    }

    private var deleteSection: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                Text("Delete Alarm")
            }
            .font(.body.weight(.medium))
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.red.opacity(0.08))
            )
        }
        .padding(.top, 8)
    }

    private func stopPreview() {
        SoundService.shared.stopSound()
        playingSoundId = nil
    }

    private func saveAlarm() {
        let saved = Alarm(
            id: alarm?.id ?? UUID(),
            title: title.isEmpty ? "Morning Alarm" : title,
            time: time,
            repeatDays: isOneTime ? [] : repeatDays,
            missionType: missionType,
            soundId: soundId,
            intensity: intensity,
            isEnabled: alarm?.isEnabled ?? true,
            isOneTime: isOneTime
        )
        if isEditing {
            alarmStore.updateAlarm(saved)
        } else {
            alarmStore.addAlarm(saved)
        }
    }
}
