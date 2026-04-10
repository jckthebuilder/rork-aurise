import SwiftUI

struct NotificationPermissionView: View {
    let onEnable: () async -> Void
    let onContinue: () -> Void
    @State private var appeared = false
    @State private var requested = false
    @State private var bellGlow = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 44) {
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
                        .scaleEffect(bellGlow ? 1.08 : 0.95)
                        .blur(radius: 18)

                    Circle()
                        .fill(AuriseTheme.accent.opacity(0.1))
                        .frame(width: 80, height: 80)

                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(AuriseTheme.accentGradient)
                        .symbolEffect(.bounce, value: appeared)
                }
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.85)

                VStack(spacing: 18) {
                    Text("Make sure your alarm\ncan reach you")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AuriseTheme.primaryText)
                        .lineSpacing(3)

                    Text("Enable notifications so your\nwake-up plan can actually do its job.")
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

            VStack(spacing: 12) {
                if !requested {
                    PrimaryCTAButton("Enable notifications") {
                        Task {
                            await onEnable()
                            requested = true
                            onContinue()
                        }
                    }
                } else {
                    PrimaryCTAButton("Continue", action: onContinue)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                bellGlow = true
            }
        }
    }
}
