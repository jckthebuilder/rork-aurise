import SwiftUI

struct AlarmSoundSelectionView: View {
    @Binding var selectedSoundId: String
    @Binding var playingSoundId: String?
    let onContinue: () -> Void
    @State private var appeared = false
    private let soundService = SoundService.shared

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Pick your alarm sound")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AuriseTheme.primaryText)
                            .lineSpacing(3)

                        Text("You can change this anytime.")
                            .font(.subheadline)
                            .foregroundStyle(AuriseTheme.secondaryText)
                    }
                    .padding(.top, 28)

                    VStack(spacing: 10) {
                        ForEach(Array(AlarmSound.defaults.enumerated()), id: \.element.id) { index, sound in
                            SoundRow(
                                sound: sound,
                                isSelected: selectedSoundId == sound.id,
                                isPlaying: playingSoundId == sound.id,
                                onSelect: { selectedSoundId = sound.id },
                                onTogglePlay: {
                                    if playingSoundId == sound.id {
                                        playingSoundId = nil
                                        soundService.stopSound()
                                    } else {
                                        playingSoundId = sound.id
                                        soundService.previewSound(sound.id)
                                    }
                                }
                            )
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.05), value: appeared)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .scrollBounceBehavior(.basedOnSize)

            PrimaryCTAButton("Continue") {
                soundService.stopSound()
                playingSoundId = nil
                onContinue()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .onAppear {
            withAnimation { appeared = true }
        }
        .onDisappear {
            soundService.stopSound()
            playingSoundId = nil
        }
        .onChange(of: soundService.isPlaying) { _, isPlaying in
            if !isPlaying {
                playingSoundId = nil
            }
        }
    }
}

struct SoundRow: View {
    let sound: AlarmSound
    let isSelected: Bool
    let isPlaying: Bool
    let onSelect: () -> Void
    let onTogglePlay: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                Button(action: onTogglePlay) {
                    ZStack {
                        Circle()
                            .fill(isPlaying ? AuriseTheme.accent.opacity(0.18) : AuriseTheme.subtleFill)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .strokeBorder(isPlaying ? AuriseTheme.accent.opacity(0.3) : Color.clear, lineWidth: 1)
                            )

                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.subheadline)
                            .foregroundStyle(isPlaying ? AuriseTheme.accent : AuriseTheme.secondaryText)
                    }
                }
                .buttonStyle(.plain)

                HStack(spacing: 10) {
                    Image(systemName: sound.icon)
                        .font(.subheadline)
                        .foregroundStyle(isSelected ? AuriseTheme.accent : AuriseTheme.tertiaryText)
                        .frame(width: 20)

                    Text(sound.name)
                        .font(.body.weight(.medium))
                        .foregroundStyle(isSelected ? .white : AuriseTheme.primaryText.opacity(0.8))
                }

                Spacer()

                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? .clear : AuriseTheme.radioUnselected, lineWidth: 1.5)
                        .background(Circle().fill(isSelected ? AuriseTheme.accent : .clear))
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? AuriseTheme.cardSelectedFill : AuriseTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? AuriseTheme.cardSelectedBorder : AuriseTheme.subtleBorder, lineWidth: isSelected ? 1.5 : 0.5)
            )
            .shadow(color: isSelected ? AuriseTheme.accentGlow.opacity(0.1) : .clear, radius: 10, y: 4)
        }
        .buttonStyle(CardButtonStyle())
        .sensoryFeedback(.selection, trigger: isSelected)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}
