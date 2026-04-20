import SwiftUI
#if canImport(AlarmKit)
import AlarmKit
#endif

struct AlarmKitPermissionView: View {
    let onEnable: () async -> Bool
    let onContinue: () -> Void

    @State private var appeared = false
    @State private var alarmGlow = false
    @State private var authState: AlarmAuthState = .checking
    @State private var isRequesting = false

    private enum AlarmAuthState {
        case checking, notDetermined, authorized, denied, unavailable
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 44) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    iconColor.opacity(0.22),
                                    iconColor.opacity(0.06),
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
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 80, height: 80)

                    Image(systemName: stateIcon)
                        .font(.system(size: 38))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [iconColor, iconColor.opacity(0.75)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolEffect(.bounce, value: appeared)
                        .contentTransition(.symbolEffect(.replace))
                }
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.85)

                VStack(spacing: 18) {
                    Text(titleText)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AuriseTheme.primaryText)
                        .lineSpacing(3)
                        .contentTransition(.opacity)

                    VStack(spacing: 10) {
                        Text(subtitleText)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AuriseTheme.secondaryText)
                            .lineSpacing(4)
                            .contentTransition(.opacity)

                        if authState == .notDetermined || authState == .checking {
                            featureBullets
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }

                        if authState == .authorized {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(.green)
                                Text("AlarmKit is active — alarms will ring")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.green)
                            }
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        }
                    }
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)

            Spacer()
            Spacer()

            VStack(spacing: 12) {
                switch authState {
                case .checking:
                    PrimaryCTAButton("Checking…") { }
                        .disabled(true)

                case .notDetermined:
                    PrimaryCTAButton(isRequesting ? "Requesting…" : "Allow Alarm Access") {
                        guard !isRequesting else { return }
                        isRequesting = true
                        Task {
                            let granted = await onEnable()
                            withAnimation(.spring(response: 0.4)) {
                                authState = granted ? .authorized : .denied
                                isRequesting = false
                            }
                        }
                    }
                    .disabled(isRequesting)

                    Button("Not now") {
                        onContinue()
                    }
                    .font(.subheadline)
                    .foregroundStyle(AuriseTheme.tertiaryText)

                case .authorized:
                    PrimaryCTAButton("Continue") {
                        onContinue()
                    }

                case .denied:
                    PrimaryCTAButton("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }

                    Button("Continue without AlarmKit") {
                        onContinue()
                    }
                    .font(.subheadline)
                    .foregroundStyle(AuriseTheme.tertiaryText)

                case .unavailable:
                    PrimaryCTAButton("Continue") {
                        onContinue()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) { appeared = true }
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) { alarmGlow = true }
            resolveInitialState()
        }
    }

    private var featureBullets: some View {
        VStack(spacing: 8) {
            BulletRow(text: "Bypasses Silent Mode & Focus")
            BulletRow(text: "Appears in Apple's built-in Clock app")
            BulletRow(text: "Reliable even if the app is closed")
        }
    }

    private var titleText: String {
        switch authState {
        case .checking, .notDetermined: return "Never sleep through\nyour alarm again"
        case .authorized: return "Alarm access\ngranted"
        case .denied: return "Alarm access\nneeded"
        case .unavailable: return "Alarms are\nall set"
        }
    }

    private var subtitleText: String {
        switch authState {
        case .checking, .notDetermined:
            return "Aurise uses Apple's AlarmKit to ring your alarm even with Silent Mode, Focus, or Do Not Disturb on."
        case .authorized:
            return "Aurise can now ring through Silent Mode, Focus, and Do Not Disturb."
        case .denied:
            return "Enable AlarmKit in Settings so Aurise can ring through Silent Mode and Do Not Disturb."
        case .unavailable:
            return "Your alarms are scheduled and ready to go."
        }
    }

    private var stateIcon: String {
        switch authState {
        case .checking, .notDetermined: return "alarm.fill"
        case .authorized: return "checkmark.circle.fill"
        case .denied: return "exclamationmark.circle.fill"
        case .unavailable: return "alarm.fill"
        }
    }

    private var iconColor: Color {
        switch authState {
        case .checking, .notDetermined, .unavailable: return AuriseTheme.accent
        case .authorized: return .green
        case .denied: return .orange
        }
    }

    private func resolveInitialState() {
        if #available(iOS 26.0, *) {
            let state = AlarmManager.shared.authorizationState
            withAnimation(.spring(response: 0.4)) {
                switch state {
                case .authorized:
                    authState = .authorized
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { onContinue() }
                case .denied:
                    authState = .denied
                case .notDetermined:
                    authState = .notDetermined
                @unknown default:
                    authState = .unavailable
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { onContinue() }
                }
            }
        } else {
            authState = .unavailable
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { onContinue() }
        }
    }
}

private struct BulletRow: View {
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(AuriseTheme.accent)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(AuriseTheme.secondaryText)
        }
    }
}
