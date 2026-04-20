import SwiftUI
#if canImport(AlarmKit)
import AlarmKit
#endif

struct AlarmKitPermissionView: View {
    let onEnable: () async -> Void
    let onContinue: () -> Void
    @State private var appeared = false
    @State private var requested = false
    @State private var alarmGlow = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 44) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AuriseTheme.accent.opacity(0.22),
                                    AuriseTheme.accent.opacity(0.06),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 15,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(alarmGlow ? 1.1 : 0.92)
                        .blur(radius: 20)

                    Circle()
                        .fill(AuriseTheme.accent.opacity(0.1))
                        .frame(width: 80, height: 80)

                    Image(systemName: "alarm.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(AuriseTheme.accentGradient)
                        .symbolEffect(.bounce, value: appeared)
                }
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.85)

                VStack(spacing: 18) {
                    Text("Never sleep through\nyour alarm again")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AuriseTheme.primaryText)
                        .lineSpacing(3)

                    VStack(spacing: 10) {
                        Text("Aurise uses Apple's AlarmKit to ring your alarm even with Silent Mode, Focus, or Do Not Disturb on.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AuriseTheme.secondaryText)
                            .lineSpacing(4)

                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(AuriseTheme.accent)
                            Text("Bypasses Silent Mode & Focus")
                                .font(.subheadline)
                                .foregroundStyle(AuriseTheme.secondaryText)
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(AuriseTheme.accent)
                            Text("Appears in Apple's built-in Clock app")
                                .font(.subheadline)
                                .foregroundStyle(AuriseTheme.secondaryText)
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(AuriseTheme.accent)
                            Text("Reliable even if the app is closed")
                                .font(.subheadline)
                                .foregroundStyle(AuriseTheme.secondaryText)
                        }
                    }
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)

            Spacer()
            Spacer()

            VStack(spacing: 12) {
                if !requested {
                    PrimaryCTAButton("Allow Alarm Access") {
                        Task {
                            await onEnable()
                            requested = true
                            onContinue()
                        }
                    }
                } else {
                    PrimaryCTAButton("Continue", action: onContinue)
                }

                Button("Not now") {
                    onContinue()
                }
                .font(.subheadline)
                .foregroundStyle(AuriseTheme.tertiaryText)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                alarmGlow = true
            }
        }
    }
}
