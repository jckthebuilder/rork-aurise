import SwiftUI

struct PremiumPaywallSheet: View {
    let alarmStore: AlarmStore
    @Environment(\.dismiss) private var dismiss
    @State private var appeared: Bool = false
    @State private var selectedPlan: String = "yearly"

    private let features: [(icon: String, title: String, subtitle: String)] = [
        ("target", "All 10 Missions", "Object Hunt, Photo Sky, Pushups, and more"),
        ("alarm.fill", "Unlimited Alarms", "Set as many alarms as you need"),
        ("slider.horizontal.3", "Full Customization", "Advanced sound, intensity & scheduling"),
        ("chart.bar.fill", "Detailed Insights", "Track your progress and consistency"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AuriseTheme.pageBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        heroSection
                        featuresSection
                        plansSection
                        ctaSection
                        restoreSection
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AuriseTheme.tertiaryText)
                    }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    appeared = true
                }
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AuriseTheme.accent.opacity(0.2), AuriseTheme.accent.opacity(0.05), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 88, height: 88)

                Image(systemName: "crown.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(AuriseTheme.accent)
                    .symbolEffect(.bounce, value: appeared)
            }

            Text("Unlock the Full\nWake-Up System")
                .font(.title.weight(.bold))
                .foregroundStyle(AuriseTheme.primaryText)
                .multilineTextAlignment(.center)

            Text("More missions. More control.\nBetter mornings.")
                .font(.subheadline)
                .foregroundStyle(AuriseTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private var featuresSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(AuriseTheme.accent.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: feature.icon)
                            .font(.body.weight(.medium))
                            .foregroundStyle(AuriseTheme.accent)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(AuriseTheme.primaryText)
                        Text(feature.subtitle)
                            .font(.caption)
                            .foregroundStyle(AuriseTheme.secondaryText)
                    }

                    Spacer()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)

                if index < features.count - 1 {
                    Rectangle()
                        .fill(AuriseTheme.divider)
                        .frame(height: 0.5)
                        .padding(.leading, 68)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AuriseTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private var plansSection: some View {
        VStack(spacing: 10) {
            PlanOptionCard(
                title: "Yearly",
                price: "$29.99/year",
                perMonth: "$2.50/mo",
                badge: "Best Value",
                isSelected: selectedPlan == "yearly"
            ) {
                withAnimation(.snappy) { selectedPlan = "yearly" }
            }

            PlanOptionCard(
                title: "Monthly",
                price: "$4.99/month",
                perMonth: nil,
                badge: nil,
                isSelected: selectedPlan == "monthly"
            ) {
                withAnimation(.snappy) { selectedPlan = "monthly" }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private var ctaSection: some View {
        VStack(spacing: 12) {
            Button {
                alarmStore.setPremium(true)
                dismiss()
            } label: {
                Text("Start Free Trial")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AuriseTheme.accentGradient)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(AuriseTheme.buttonOverlay, lineWidth: 0.5)
                    )
                    .shadow(color: AuriseTheme.accentGlow.opacity(0.3), radius: 16, y: 6)
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: selectedPlan)

            Text("7-day free trial, cancel anytime")
                .font(.caption)
                .foregroundStyle(AuriseTheme.tertiaryText)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private var restoreSection: some View {
        Button {
        } label: {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundStyle(AuriseTheme.secondaryText)
        }
    }
}

struct PlanOptionCard: View {
    let title: String
    let price: String
    let perMonth: String?
    let badge: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color.clear : AuriseTheme.radioUnselected, lineWidth: 1.5)
                        .background(Circle().fill(isSelected ? AuriseTheme.accent : .clear))
                        .frame(width: 22, height: 22)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(AuriseTheme.primaryText)

                        if let badge {
                            Text(badge)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(AuriseTheme.accent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule().fill(AuriseTheme.accent.opacity(0.12))
                                )
                        }
                    }

                    Text(price)
                        .font(.subheadline)
                        .foregroundStyle(AuriseTheme.secondaryText)
                }

                Spacer()

                if let perMonth {
                    Text(perMonth)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AuriseTheme.accent)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? AuriseTheme.cardSelectedFill : AuriseTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isSelected ? AuriseTheme.cardSelectedBorder : AuriseTheme.subtleBorder, lineWidth: isSelected ? 1.5 : 0.5)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}
