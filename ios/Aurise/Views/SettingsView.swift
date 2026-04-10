import SwiftUI
import UserNotifications

struct SettingsView: View {
    let alarmStore: AlarmStore
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("appThemeMode") private var themeMode: String = AppThemeMode.system.rawValue
    @State private var showResetConfirm: Bool = false
    @State private var showPaywall: Bool = false
    @State private var notificationsEnabled: Bool = false
    @State private var appeared: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                AuriseTheme.pageBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        premiumSection
                        alarmReadinessSection
                        appearanceSection
                        aboutSection
                        dangerZone
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                checkNotifications()
                withAnimation(.spring(response: 0.5)) { appeared = true }
            }
            .alert("Reset Onboarding?", isPresented: $showResetConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    withAnimation(.smooth(duration: 0.5)) {
                        hasCompletedOnboarding = false
                    }
                }
            } message: {
                Text("This will restart the onboarding flow so you can rebuild your wake-up plan.")
            }
            .sheet(isPresented: $showPaywall) {
                PremiumPaywallSheet(alarmStore: alarmStore)
            }
        }
    }

    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SUBSCRIPTION")
                .font(.caption.weight(.bold))
                .foregroundStyle(AuriseTheme.tertiaryText)
                .tracking(1.2)

            Button {
                if alarmStore.isPremium {
                } else {
                    showPaywall = true
                }
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [AuriseTheme.accent, AuriseTheme.accentSoft],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        Image(systemName: alarmStore.isPremium ? "crown.fill" : "lock.fill")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(alarmStore.isPremium ? "Aurise Premium" : "Upgrade to Premium")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(AuriseTheme.primaryText)
                        Text(alarmStore.isPremium ? "All missions unlocked" : "Unlock all missions & unlimited alarms")
                            .font(.caption)
                            .foregroundStyle(AuriseTheme.secondaryText)
                    }

                    Spacer()

                    if !alarmStore.isPremium {
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AuriseTheme.tertiaryText)
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AuriseTheme.cardFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(alarmStore.isPremium ? AuriseTheme.accent.opacity(0.3) : AuriseTheme.subtleBorder, lineWidth: alarmStore.isPremium ? 1 : 0.5)
                )
            }
            .buttonStyle(.plain)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private var alarmReadinessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ALARM READINESS")
                .font(.caption.weight(.bold))
                .foregroundStyle(AuriseTheme.tertiaryText)
                .tracking(1.2)

            VStack(spacing: 0) {
                SettingsReadinessRow(
                    icon: "bell.badge.fill",
                    title: "Notifications",
                    subtitle: notificationsEnabled ? "Enabled" : "Disabled — alarms may not work",
                    isPassed: notificationsEnabled,
                    showDivider: true
                ) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }

                SettingsReadinessRow(
                    icon: "alarm.fill",
                    title: "Active Alarms",
                    subtitle: alarmStore.activeAlarmCount > 0 ? "\(alarmStore.activeAlarmCount) alarm\(alarmStore.activeAlarmCount == 1 ? "" : "s") active" : "No active alarms",
                    isPassed: alarmStore.activeAlarmCount > 0,
                    showDivider: true
                )

                SettingsReadinessRow(
                    icon: "battery.100.bolt",
                    title: "Background App Refresh",
                    subtitle: "Keep enabled for reliable alarms",
                    isPassed: true,
                    showDivider: false
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AuriseTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("APPEARANCE")
                .font(.caption.weight(.bold))
                .foregroundStyle(AuriseTheme.tertiaryText)
                .tracking(1.2)

            HStack(spacing: 10) {
                ForEach(AppThemeMode.allCases, id: \.rawValue) { mode in
                    let isSelected = themeMode == mode.rawValue
                    Button {
                        withAnimation(.snappy) {
                            themeMode = mode.rawValue
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: mode.icon)
                                .font(.body.weight(.medium))
                                .foregroundStyle(isSelected ? AuriseTheme.accent : AuriseTheme.secondaryText)
                            Text(mode.rawValue)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(isSelected ? AuriseTheme.primaryText : AuriseTheme.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isSelected ? AuriseTheme.accent.opacity(0.12) : AuriseTheme.cardFill)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(isSelected ? AuriseTheme.accent.opacity(0.4) : AuriseTheme.subtleBorder, lineWidth: isSelected ? 1.5 : 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.selection, trigger: isSelected)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ABOUT")
                .font(.caption.weight(.bold))
                .foregroundStyle(AuriseTheme.tertiaryText)
                .tracking(1.2)

            VStack(spacing: 0) {
                SettingsLinkRow(icon: "questionmark.circle.fill", title: "Help & Support", color: AuriseTheme.accent, showDivider: true)
                SettingsLinkRow(icon: "envelope.fill", title: "Send Feedback", color: .green, showDivider: true)
                SettingsLinkRow(icon: "hand.raised.fill", title: "Privacy Policy", color: .purple, showDivider: true)
                SettingsLinkRow(icon: "doc.text.fill", title: "Terms of Service", color: .orange, showDivider: false)
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AuriseTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                showResetConfirm = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.body.weight(.medium))
                    Text("Reset Onboarding")
                        .font(.body.weight(.medium))
                    Spacer()
                }
                .foregroundStyle(AuriseTheme.secondaryText)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AuriseTheme.cardFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)

            Text("Aurise v1.0")
                .font(.caption)
                .foregroundStyle(AuriseTheme.tertiaryText)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func checkNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
}

struct SettingsReadinessRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let isPassed: Bool
    let showDivider: Bool
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            Button {
                action?()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundStyle(isPassed ? .green : .orange)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.body.weight(.medium))
                            .foregroundStyle(AuriseTheme.primaryText)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(isPassed ? AuriseTheme.secondaryText : .orange)
                    }

                    Spacer()

                    Image(systemName: isPassed ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundStyle(isPassed ? .green : .orange)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .disabled(action == nil)

            if showDivider {
                Rectangle()
                    .fill(AuriseTheme.divider)
                    .frame(height: 0.5)
                    .padding(.leading, 50)
            }
        }
    }
}

struct SettingsLinkRow: View {
    let icon: String
    let title: String
    let color: Color
    let showDivider: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
                    .frame(width: 24)

                Text(title)
                    .font(.body)
                    .foregroundStyle(AuriseTheme.primaryText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AuriseTheme.tertiaryText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)

            if showDivider {
                Rectangle()
                    .fill(AuriseTheme.divider)
                    .frame(height: 0.5)
                    .padding(.leading, 50)
            }
        }
    }
}
