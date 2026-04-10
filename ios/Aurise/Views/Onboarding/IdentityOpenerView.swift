import SwiftUI

struct IdentityOpenerView: View {
    let onContinue: () -> Void
    @State private var appeared = false
    @State private var glowPulse = false
    @State private var orbFloat = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 48) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AuriseTheme.accentGlow.opacity(0.3),
                                    AuriseTheme.accentGlow.opacity(0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(glowPulse ? 1.15 : 0.95)
                        .blur(radius: 30)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AuriseTheme.accent.opacity(0.25),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(glowPulse ? 1.05 : 1.0)

                    Image(systemName: "sunrise.fill")
                        .font(.system(size: 56, weight: .light))
                        .foregroundStyle(AuriseTheme.accentGradient)
                        .symbolEffect(.breathe.pulse, isActive: appeared)
                        .offset(y: orbFloat ? -4 : 4)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 30)

                VStack(spacing: 18) {
                    Text("Become someone who\ngets out of bed.")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AuriseTheme.primaryText)
                        .lineSpacing(3)

                    Text("A wake-up system for people who\nstruggle to get out of bed.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AuriseTheme.secondaryText)
                        .lineSpacing(3)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
            }

            Spacer()
            Spacer()

            PrimaryCTAButton("Build my plan", action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 24)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                orbFloat = true
            }
        }
    }
}
