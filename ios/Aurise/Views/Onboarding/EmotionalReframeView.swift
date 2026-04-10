import SwiftUI

struct EmotionalReframeView: View {
    let onContinue: () -> Void
    @State private var appeared = false
    @State private var heartPulse = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 40) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AuriseTheme.accent.opacity(0.2),
                                    AuriseTheme.accent.opacity(0.05),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 15,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(heartPulse ? 1.1 : 0.95)
                        .blur(radius: 20)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(AuriseTheme.accentGradient)
                        .symbolEffect(.pulse, isActive: appeared)
                }
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.8)

                VStack(spacing: 18) {
                    Text("This isn't laziness.")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(AuriseTheme.primaryText)

                    Text("It's a pattern.")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(AuriseTheme.accent)

                    Text("If normal alarms don't work for you,\nyou don't need more alarms —\nyou need a better wake-up system.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AuriseTheme.secondaryText)
                        .lineSpacing(4)
                        .padding(.top, 4)
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)

            Spacer()
            Spacer()

            PrimaryCTAButton("Continue", action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                heartPulse = true
            }
        }
    }
}
