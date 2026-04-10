import SwiftUI

struct AuriseProgressView: View {
    let progressStore: ProgressStore
    let alarmStore: AlarmStore
    @State private var appeared: Bool = false
    @State private var selectedMonth: Date = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                AuriseTheme.pageBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        streakHeroCard
                        monthCalendarCard
                        statsGrid
                        badgesSection
                        insightsSection
                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Progress")
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    appeared = true
                }
            }
        }
    }

    private var streakHeroCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .orange.opacity(0.2),
                                .orange.opacity(0.05),
                                .clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 120, height: 120)

                VStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.title)
                        .foregroundStyle(.orange)
                        .symbolEffect(.bounce, value: appeared)

                    Text("\(progressStore.currentStreak)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(AuriseTheme.primaryText)
                }
            }

            Text(progressStore.currentStreak == 1 ? "day streak" : "day streak")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AuriseTheme.secondaryText)

            if progressStore.longestStreak > progressStore.currentStreak {
                Text("Best: \(progressStore.longestStreak) days")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AuriseTheme.tertiaryText)
            }

            if let nextBadge = progressStore.nextBadge {
                HStack(spacing: 6) {
                    Image(systemName: nextBadge.icon)
                        .font(.caption)
                        .foregroundStyle(AuriseTheme.accent)
                    Text("Next: \(nextBadge.name)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AuriseTheme.secondaryText)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(AuriseTheme.accent.opacity(0.08))
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AuriseTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private var monthCalendarCard: some View {
        let calendar = Calendar.current
        let today = Date()
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) ?? today
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
        let firstWeekday = (calendar.component(.weekday, from: monthStart) + 5) % 7
        let completedDates = progressStore.completedDatesThisMonth

        let monthName = monthStart.formatted(.dateTime.month(.wide).year())

        return VStack(spacing: 14) {
            HStack {
                Button {
                    withAnimation(.snappy) {
                        selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AuriseTheme.secondaryText)
                        .frame(width: 32, height: 32)
                }

                Spacer()

                Text(monthName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AuriseTheme.primaryText)

                Spacer()

                Button {
                    withAnimation(.snappy) {
                        selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AuriseTheme.secondaryText)
                        .frame(width: 32, height: 32)
                }
            }

            let dayHeaders = ["M", "T", "W", "T", "F", "S", "S"]
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                ForEach(dayHeaders, id: \.self) { day in
                    Text(day)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(AuriseTheme.tertiaryText)
                        .frame(height: 20)
                }

                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Color.clear.frame(height: 32)
                }

                ForEach(1...daysInMonth, id: \.self) { day in
                    let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) ?? monthStart
                    let isCompleted = completedDates.contains(calendar.startOfDay(for: date))
                    let isToday = calendar.isDateInToday(date)
                    let isFuture = date > today

                    ZStack {
                        if isCompleted {
                            Circle()
                                .fill(AuriseTheme.accent)
                                .frame(width: 32, height: 32)
                        } else if isToday {
                            Circle()
                                .strokeBorder(AuriseTheme.accent.opacity(0.5), lineWidth: 1.5)
                                .frame(width: 32, height: 32)
                        }

                        Text("\(day)")
                            .font(.caption.weight(isToday ? .bold : .medium))
                            .foregroundStyle(
                                isCompleted ? .white :
                                    (isFuture ? AuriseTheme.tertiaryText :
                                        (isToday ? AuriseTheme.accent : AuriseTheme.primaryText))
                            )
                    }
                    .frame(height: 32)
                }
            }
        }
        .padding(16)
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

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatTile(
                icon: "sunrise.fill",
                label: "Total mornings",
                value: "\(progressStore.totalWakeUps)",
                color: .orange
            )

            StatTile(
                icon: "chart.bar.fill",
                label: "This week",
                value: "\(progressStore.thisWeekCount)/7",
                color: AuriseTheme.accent
            )

            StatTile(
                icon: "clock.fill",
                label: "Avg. wake time",
                value: progressStore.averageWakeUpTime ?? "—",
                color: .purple
            )

            StatTile(
                icon: "percent",
                label: "Consistency",
                value: "\(Int(progressStore.weeklyConsistency * 100))%",
                color: .green
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BADGES")
                .font(.caption.weight(.bold))
                .foregroundStyle(AuriseTheme.tertiaryText)
                .tracking(1.2)

            if progressStore.earnedBadges.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "trophy")
                        .font(.title2)
                        .foregroundStyle(AuriseTheme.tertiaryText)
                    Text("Complete your first morning\nto earn your first badge")
                        .font(.subheadline)
                        .foregroundStyle(AuriseTheme.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AuriseTheme.cardFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
                )
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(progressStore.earnedBadges) { badge in
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(AuriseTheme.accent.opacity(0.12))
                                    .frame(width: 48, height: 48)
                                Image(systemName: badge.icon)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(AuriseTheme.accent)
                            }
                            Text(badge.name)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(AuriseTheme.primaryText)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AuriseTheme.cardFill)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
                        )
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Badge.allBadges) { badge in
                        let isEarned = progressStore.earnedBadges.contains { $0.id == badge.id }
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(isEarned ? AuriseTheme.accent.opacity(0.12) : AuriseTheme.subtleFill)
                                    .frame(width: 36, height: 36)
                                Image(systemName: badge.icon)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(isEarned ? AuriseTheme.accent : AuriseTheme.tertiaryText)
                            }
                            Text(badge.name)
                                .font(.caption2)
                                .foregroundStyle(isEarned ? AuriseTheme.primaryText : AuriseTheme.tertiaryText)
                                .lineLimit(1)
                        }
                        .frame(width: 72)
                    }
                }
            }
            .contentMargins(.horizontal, 0)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("INSIGHTS")
                .font(.caption.weight(.bold))
                .foregroundStyle(AuriseTheme.tertiaryText)
                .tracking(1.2)

            if let favMission = progressStore.favoriteMission, let mType = MissionType(rawValue: favMission) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(mType.accentColor.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: mType.icon)
                            .font(.body.weight(.medium))
                            .foregroundStyle(mType.accentColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Favorite mission")
                            .font(.caption)
                            .foregroundStyle(AuriseTheme.tertiaryText)
                        Text(mType.displayName)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(AuriseTheme.primaryText)
                    }

                    Spacer()
                }
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

            if progressStore.totalWakeUps == 0 {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title3)
                        .foregroundStyle(AuriseTheme.tertiaryText)
                    Text("Complete your first morning to see insights")
                        .font(.subheadline)
                        .foregroundStyle(AuriseTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AuriseTheme.cardFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
                )
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }
}

struct StatTile: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(AuriseTheme.tertiaryText)
            }
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(AuriseTheme.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
}
