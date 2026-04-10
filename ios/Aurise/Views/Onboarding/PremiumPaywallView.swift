import SwiftUI

struct PremiumPaywallView: View {
    let onUpgrade: () -> Void
    let onContinueFree: () -> Void
    @State private var appeared = false
    @State private var shimmerOffset: CGFloat = -200
    @State private var crownGlow = false

    private let benefits: [(icon: String, title: String, detail: String)] = [
        ("infinity", "Unlimited alarms", "Set as many as you need"),
        ("target", "More mission types", "Steps, make your bed, and more"),
        ("slider.horizontal.3", "Full customization", "Sounds, schedules, snooze rules"),
        ("bolt.fill", "Stronger wake-up tools", "Harder to dismiss, harder to ignore"),
        ("chart.line.uptrend.xyaxis", "Progress tracking", "See your consistency improve"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            AuriseTheme.premiumGold.opacity(0.25),
                                            AuriseTheme.premiumGold.opacity(0.06),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 15,
                                        endRadius: 80
                                    )
                                )
                                .frame(width: 160, height: 160)
                                .scaleEffect(crownGlow ? 1.1 : 0.95)
                                .blur(radius: 20)

                            Image(systemName: "crown.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(AuriseTheme.premiumShimmer)
                        }

                        VStack(spacing: 14) {
                            Text("Unlock the full\nwake-up system")
                                .font(.system(size: 30, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(AuriseTheme.primaryText)
                                .lineSpacing(3)

                            Text("More missions, more alarms, more control.\nA stronger system for consistent mornings.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(AuriseTheme.secondaryText)
                                .lineSpacing(3)
                        }
                    }
                    .padding(.top, 28)

                    VStack(spacing: 0) {
                        ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                            if index > 0 {
                                Rectangle()
                                    .fill(AuriseTheme.divider)
                                    .frame(height: 1)
                                    .padding(.horizontal, 20)
                            }
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(AuriseTheme.accent.opacity(0.12))
                                        .frame(width: 38, height: 38)

                                    Image(systemName: benefit.icon)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(AuriseTheme.accent)
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(benefit.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AuriseTheme.primaryText)
                                    Text(benefit.detail)
                                        .font(.caption)
                                        .foregroundStyle(AuriseTheme.secondaryText)
                                }

                                Spacer()

                                Image(systemName: "checkmark.circle.fill")
                                    .font(.body)
                                    .foregroundStyle(AuriseTheme.accent.opacity(0.6))
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .opacity(appeared ? 1 : 0)
                            .offset(x: appeared ? 0 : 20)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1 + Double(index) * 0.06), value: appeared)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(AuriseTheme.cardFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [AuriseTheme.premiumGold.opacity(0.25), AuriseTheme.accent.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: AuriseTheme.premiumGold.opacity(0.08), radius: 24, y: 10)
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 24)
            }
            .scrollBounceBehavior(.basedOnSize)

            VStack(spacing: 14) {
                Button(action: onUpgrade) {
                    Text("Start free trial")
                        .font(.body.weight(.semibold))
                        .tracking(0.3)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AuriseTheme.premiumShimmer)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(AuriseTheme.buttonOverlay, lineWidth: 0.5)
                        )
                        .shadow(color: AuriseTheme.premiumGold.opacity(0.35), radius: 18, y: 8)
                }

                Button(action: onContinueFree) {
                    Text("Continue with free version")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AuriseTheme.tertiaryText)
                }
                .padding(.bottom, 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                crownGlow = true
            }
        }
    }
}
