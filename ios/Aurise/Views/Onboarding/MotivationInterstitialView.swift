import SwiftUI

struct MotivationInterstitialView: View {
    let onContinue: () -> Void
    @State private var appeared = false
    @State private var sparkle = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 40) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AuriseTheme.accentSoft.opacity(0.18),
                                    AuriseTheme.accentSoft.opacity(0.04),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 12,
                                endRadius: 70
                            )
                        )
                        .frame(width: 150, height: 150)
                        .scaleEffect(sparkle ? 1.1 : 0.95)
                        .blur(radius: 18)

                    Image(systemName: "sparkles")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(AuriseTheme.accentGradient)
                        .symbolEffect(.variableColor.iterative, isActive: appeared)
                }
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.8)

                VStack(spacing: 18) {
                    Text("If you win the morning,\nyou win the day.")
                        .font(.system(size: 30, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AuriseTheme.primaryText)
                        .lineSpacing(3)

                    Text("We're building a wake-up plan\naround your actual habits.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AuriseTheme.secondaryText)
                        .lineSpacing(4)
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
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                sparkle = true
            }
        }
    }
}
