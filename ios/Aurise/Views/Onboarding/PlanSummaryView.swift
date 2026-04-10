import SwiftUI

struct PlanSummaryView: View {
    let vm: OnboardingViewModel
    let onContinue: () -> Void
    @State private var appeared = false
    @State private var showRows = false
    @State private var cardGlow = false

    private var minutesSaved: Int {
        let diff = Calendar.current.dateComponents([.minute], from: vm.targetWakeUpTime, to: vm.currentWakeUpTime).minute ?? 0
        return max(diff, 0)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundStyle(AuriseTheme.accent)
                            Text("YOUR SYSTEM IS READY")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AuriseTheme.accent)
                                .tracking(1.2)
                        }
                        .opacity(appeared ? 1 : 0)

                        Text("Your morning\ntransformation")
                            .font(.system(size: 30, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AuriseTheme.primaryText)
                            .lineSpacing(3)
                    }
                    .padding(.top, 28)

                    HStack(spacing: 16) {
                        TransformationPill(
                            label: "NOW",
                            time: vm.currentTimeFormatted,
                            icon: "bed.double.fill",
                            color: Color.orange
                        )

                        Image(systemName: "arrow.right")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AuriseTheme.accent)

                        TransformationPill(
                            label: "GOAL",
                            time: vm.targetTimeFormatted,
                            icon: "sunrise.fill",
                            color: AuriseTheme.accent
                        )
                    }
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)

                    if minutesSaved > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                                .font(.caption)
                                .foregroundStyle(AuriseTheme.accent)
                            Text("+\(minutesSaved) min every morning")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AuriseTheme.accent)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(AuriseTheme.accent.opacity(0.1))
                        )
                        .opacity(appeared ? 1 : 0)
                    }

                    VStack(spacing: 0) {
                        SummaryDetailRow(
                            icon: vm.effectiveMission.icon,
                            label: "Mission",
                            value: vm.effectiveMission.displayName,
                            accentIcon: true,
                            showRow: showRows,
                            delay: 0
                        )

                        Rectangle()
                            .fill(AuriseTheme.divider)
                            .frame(height: 1)
                            .padding(.horizontal, 20)

                        SummaryDetailRow(
                            icon: vm.selectedSound.icon,
                            label: "Sound",
                            value: vm.selectedSound.name,
                            accentIcon: false,
                            showRow: showRows,
                            delay: 0.08
                        )

                        Rectangle()
                            .fill(AuriseTheme.divider)
                            .frame(height: 1)
                            .padding(.horizontal, 20)

                        SummaryDetailRow(
                            icon: vm.alarmIntensity?.icon ?? "speaker.fill",
                            label: "Intensity",
                            value: vm.alarmIntensity?.rawValue ?? "—",
                            accentIcon: false,
                            showRow: showRows,
                            delay: 0.16
                        )

                        Rectangle()
                            .fill(AuriseTheme.divider)
                            .frame(height: 1)
                            .padding(.horizontal, 20)

                        SummaryDetailRow(
                            icon: "calendar",
                            label: "Active days",
                            value: vm.activeDaysSummary,
                            accentIcon: false,
                            showRow: showRows,
                            delay: 0.24
                        )
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(AuriseTheme.cardFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(AuriseTheme.accent.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: AuriseTheme.accentGlow.opacity(cardGlow ? 0.15 : 0.06), radius: 24, y: 8)
                    .padding(.horizontal, 24)

                    Text("This is your new wake-up system.")
                        .font(.footnote)
                        .foregroundStyle(AuriseTheme.tertiaryText)
                        .opacity(showRows ? 1 : 0)
                }
                .padding(.bottom, 24)
            }
            .scrollBounceBehavior(.basedOnSize)

            PrimaryCTAButton("Continue", action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .opacity(showRows ? 1 : 0)
        }
        .sensoryFeedback(.success, trigger: appeared)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                showRows = true
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                cardGlow = true
            }
        }
    }
}

private struct TransformationPill: View {
    let label: String
    let time: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(color.opacity(0.7))
                .tracking(0.8)

            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
            }

            Text(time)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AuriseTheme.primaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AuriseTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(color.opacity(0.15), lineWidth: 1)
        )
    }
}

private struct SummaryDetailRow: View {
    let icon: String
    let label: String
    let value: String
    let accentIcon: Bool
    let showRow: Bool
    let delay: Double

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accentIcon ? AuriseTheme.accent.opacity(0.12) : AuriseTheme.subtleFill)
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(accentIcon ? AuriseTheme.accent : AuriseTheme.secondaryText)
            }

            Text(label)
                .font(.subheadline)
                .foregroundStyle(AuriseTheme.secondaryText)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AuriseTheme.primaryText)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
        .opacity(showRow ? 1 : 0)
        .offset(x: showRow ? 0 : 12)
        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(delay), value: showRow)
    }
}
