import SwiftUI

struct MissionExplanationView: View {
    let mission: MissionType
    let onContinue: () -> Void
    @State private var appeared = false
    @State private var step1 = false
    @State private var step2 = false
    @State private var step3 = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "bolt.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AuriseTheme.accent)
                            Text("HOW IT WORKS")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AuriseTheme.accent)
                                .tracking(1.2)
                        }

                        Text("Why \(mission.displayName)\nwakes you up")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AuriseTheme.primaryText)
                            .lineSpacing(3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 28)
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)

                    VStack(spacing: 0) {
                        MissionStepRow(
                            stepNumber: 1,
                            icon: "alarm.fill",
                            title: "Alarm goes off",
                            subtitle: "Your morning mission begins",
                            isActive: step1,
                            showLine: true
                        )

                        MissionStepRow(
                            stepNumber: 2,
                            icon: mission.icon,
                            title: "Complete: \(mission.shortName)",
                            subtitle: mission.subtitle,
                            isActive: step2,
                            showLine: true
                        )

                        MissionStepRow(
                            stepNumber: 3,
                            icon: "sun.max.fill",
                            title: "You're awake",
                            subtitle: "No snooze loop. No going back to bed.",
                            isActive: step3,
                            showLine: false
                        )
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(AuriseTheme.cardFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
                    )
                    .padding(.horizontal, 24)

                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "brain.head.profile.fill")
                                .font(.body)
                                .foregroundStyle(mission.accentColor)

                            Text("The science behind it")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AuriseTheme.primaryText)
                        }

                        Text(mission.wakeEffectDescription)
                            .font(.subheadline)
                            .foregroundStyle(AuriseTheme.secondaryText)
                            .lineSpacing(4)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(mission.accentColor.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(mission.accentColor.opacity(0.12), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .opacity(step3 ? 1 : 0)
                    .offset(y: step3 ? 0 : 12)
                }
                .padding(.bottom, 24)
            }
            .scrollBounceBehavior(.basedOnSize)

            PrimaryCTAButton("That works", action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .opacity(step3 ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.3)) {
                step1 = true
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.7)) {
                step2 = true
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(1.1)) {
                step3 = true
            }
        }
    }
}

private struct MissionStepRow: View {
    let stepNumber: Int
    let icon: String
    let title: String
    let subtitle: String
    let isActive: Bool
    let showLine: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isActive ? AuriseTheme.accent.opacity(0.15) : AuriseTheme.subtleFill)
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(isActive ? AuriseTheme.accent : AuriseTheme.tertiaryText)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(isActive ? AuriseTheme.primaryText : AuriseTheme.tertiaryText)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(isActive ? AuriseTheme.secondaryText : AuriseTheme.tertiaryText)
                        .lineLimit(2)
                }

                Spacer()

                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AuriseTheme.accent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .opacity(isActive ? 1 : 0.4)
            .animation(.spring(response: 0.35), value: isActive)

            if showLine {
                HStack {
                    Rectangle()
                        .fill(isActive ? AuriseTheme.accent.opacity(0.3) : AuriseTheme.subtleBorder)
                        .frame(width: 2, height: 24)
                        .padding(.leading, 23)
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }
}
