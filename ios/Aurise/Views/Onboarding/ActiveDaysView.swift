import SwiftUI

struct ActiveDaysView: View {
    @Binding var activeDays: Set<Weekday>
    let onToggleDay: (Weekday) -> Void
    let onContinue: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 44) {
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AuriseTheme.accent.opacity(0.12))
                            .frame(width: 56, height: 56)

                        Image(systemName: "calendar")
                            .font(.system(size: 24))
                            .foregroundStyle(AuriseTheme.accent)
                    }

                    Text("Which days should\nthis run?")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AuriseTheme.primaryText)
                        .lineSpacing(3)

                    Text("Weekdays are selected by default")
                        .font(.subheadline)
                        .foregroundStyle(AuriseTheme.secondaryText)
                }

                HStack(spacing: 10) {
                    ForEach(Weekday.allCases, id: \.rawValue) { day in
                        DayPill(
                            label: day.shortName,
                            isSelected: activeDays.contains(day)
                        ) {
                            onToggleDay(day)
                        }
                    }
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 14)

            Spacer()
            Spacer()

            PrimaryCTAButton("Continue", enabled: !activeDays.isEmpty, action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                appeared = true
            }
        }
    }
}

struct DayPill: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? Color.white : AuriseTheme.secondaryText)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isSelected ? AuriseTheme.accent : AuriseTheme.subtleFill)
                )
                .overlay(
                    Circle()
                        .strokeBorder(isSelected ? AuriseTheme.accent.opacity(0.5) : AuriseTheme.subtleBorder, lineWidth: isSelected ? 0 : 0.5)
                )
                .shadow(color: isSelected ? AuriseTheme.accentGlow.opacity(0.35) : .clear, radius: 8, y: 3)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
