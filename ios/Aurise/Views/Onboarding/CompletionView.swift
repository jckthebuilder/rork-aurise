import SwiftUI

struct CompletionView: View {
    let vm: OnboardingViewModel
    let onOpenApp: () -> Void
    @State private var appeared = false
    @State private var checkmarkBounce = 0
    @State private var successGlow = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 44) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AuriseTheme.accent.opacity(0.25),
                                    AuriseTheme.accent.opacity(0.06),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 15,
                                endRadius: 90
                            )
                        )
                        .frame(width: 180, height: 180)
                        .scaleEffect(successGlow ? 1.1 : 0.95)
                        .blur(radius: 25)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(AuriseTheme.accentGradient)
                        .symbolEffect(.bounce, value: checkmarkBounce)
                }
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.7)

                VStack(spacing: 16) {
                    Text("You're set for\ntomorrow morning")
                        .font(.system(size: 30, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AuriseTheme.primaryText)
                        .lineSpacing(3)

                    Text("Your first wake-up plan is ready.")
                        .font(.body)
                        .foregroundStyle(AuriseTheme.secondaryText)
                }

                VStack(spacing: 0) {
                    CompletionDetail(icon: "alarm.fill", label: "Wake-up", value: vm.targetTimeFormatted)
                    Rectangle()
                        .fill(AuriseTheme.divider)
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                    CompletionDetail(icon: vm.effectiveMission.icon, label: "Mission", value: vm.effectiveMission.displayName)
                    Rectangle()
                        .fill(AuriseTheme.divider)
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                    CompletionDetail(icon: "calendar", label: "Days", value: vm.activeDaysSummary)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AuriseTheme.cardFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
                )
                .padding(.horizontal, 40)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)

            Spacer()
            Spacer()

            VStack(spacing: 12) {
                PrimaryCTAButton("Open my app", action: onOpenApp)

                Text("You can edit your plan anytime.")
                    .font(.footnote)
                    .foregroundStyle(AuriseTheme.tertiaryText)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .opacity(appeared ? 1 : 0)
        }
        .sensoryFeedback(.success, trigger: appeared)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                successGlow = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                checkmarkBounce += 1
            }
        }
    }
}

struct CompletionDetail: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(AuriseTheme.accent)
                .frame(width: 22)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(AuriseTheme.secondaryText)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AuriseTheme.primaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
