import SwiftUI

struct TimeSavingsView: View {
    let targetTime: Date
    let currentTime: Date
    let onContinue: () -> Void
    @State private var appeared = false
    @State private var showStats = false
    @State private var countUp: Int = 0

    private var minutesSaved: Int {
        let diff = Calendar.current.dateComponents([.minute], from: targetTime, to: currentTime).minute ?? 0
        return max(diff, 0)
    }

    private var hoursSavedMonthly: Double {
        Double(minutesSaved * 30) / 60.0
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("Waking up at ")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AuriseTheme.primaryText)
                    +
                    Text(targetTime.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AuriseTheme.accent)
                    +
                    Text("\nis your target.")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AuriseTheme.primaryText)
                }
                .multilineTextAlignment(.center)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)

                VStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Text("+\(countUp)")
                            .font(.system(size: 44, weight: .heavy, design: .rounded))
                            .foregroundStyle(AuriseTheme.accent)
                            .contentTransition(.numericText(value: Double(countUp)))
                        Text(" min")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(AuriseTheme.accent.opacity(0.8))
                    }

                    Text("every morning")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AuriseTheme.accent.opacity(0.7))
                }
                .opacity(showStats ? 1 : 0)
                .scaleEffect(showStats ? 1 : 0.85)

                if minutesSaved > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.subheadline)
                            .foregroundStyle(AuriseTheme.secondaryText)
                        Text("+\(String(format: "%.0f", hoursSavedMonthly)) hours this month")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AuriseTheme.secondaryText)
                    }
                    .opacity(showStats ? 1 : 0)
                    .offset(y: showStats ? 0 : 8)
                }
            }

            Spacer()
            Spacer()

            PrimaryCTAButton("Continue", action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .opacity(showStats ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4)) {
                showStats = true
            }
            animateCount()
        }
    }

    private func animateCount() {
        let target = minutesSaved
        guard target > 0 else {
            countUp = 0
            return
        }
        let steps = min(target, 30)
        let interval = 0.8 / Double(steps)
        for i in 1...steps {
            let value = Int(Double(i) / Double(steps) * Double(target))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * interval) {
                withAnimation(.spring(response: 0.2)) {
                    countUp = value
                }
            }
        }
    }
}
