import SwiftUI

struct MissionSelectionView: View {
    @Binding var selection: MissionType?
    let onContinue: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "target")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AuriseTheme.accent)
                            Text("CORE MECHANIC")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AuriseTheme.accent)
                                .tracking(1.2)
                        }

                        Text("Choose your\nwake-up mission")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AuriseTheme.primaryText)
                            .lineSpacing(3)

                        Text("This is what turns your alarm off.")
                            .font(.subheadline)
                            .foregroundStyle(AuriseTheme.secondaryText)
                    }
                    .padding(.top, 28)

                    VStack(spacing: 12) {
                        ForEach(Array(MissionType.allCases.enumerated()), id: \.element) { index, mission in
                            OnboardingMissionCard(
                                mission: mission,
                                isSelected: selection == mission
                            ) {
                                selection = mission
                            }
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.06), value: appeared)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .scrollBounceBehavior(.basedOnSize)

            PrimaryCTAButton("Continue", enabled: selection != nil, action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}

struct OnboardingMissionCard: View {
    let mission: MissionType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? mission.accentColor.opacity(0.18) : AuriseTheme.subtleFill)
                        .frame(width: 46, height: 46)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(isSelected ? mission.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                        )

                    Image(systemName: mission.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(isSelected ? mission.accentColor : AuriseTheme.secondaryText)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(mission.displayName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AuriseTheme.primaryText)

                        if mission.isPremium {
                            Text("PRO")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(AuriseTheme.premiumGold)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(AuriseTheme.premiumGold.opacity(0.12))
                                )
                        }

                        Spacer()

                        ZStack {
                            Circle()
                                .strokeBorder(isSelected ? .clear : AuriseTheme.radioUnselected, lineWidth: 1.5)
                                .background(Circle().fill(isSelected ? mission.accentColor : .clear))
                                .frame(width: 22, height: 22)

                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }

                    Text(mission.subtitle)
                        .font(.caption)
                        .foregroundStyle(AuriseTheme.secondaryText)
                        .lineLimit(1)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? AuriseTheme.cardSelectedFill : AuriseTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? mission.accentColor.opacity(0.4) : AuriseTheme.subtleBorder, lineWidth: isSelected ? 1.5 : 0.5)
            )
            .shadow(color: isSelected ? mission.accentColor.opacity(0.12) : .clear, radius: 12, y: 4)
        }
        .buttonStyle(CardButtonStyle())
        .sensoryFeedback(.selection, trigger: isSelected)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isSelected)
    }
}
