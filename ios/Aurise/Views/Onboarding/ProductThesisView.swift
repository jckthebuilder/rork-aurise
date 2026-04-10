import SwiftUI

struct ProductThesisView: View {
    let onContinue: () -> Void
    @State private var appeared = false
    @State private var showRight = false
    @State private var showGained = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    Text("One alarm. One mission.")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(AuriseTheme.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.top, 32)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)

                    HStack(alignment: .top, spacing: 0) {
                        VStack(spacing: 0) {
                            Text("TYPICAL MORNING")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(AuriseTheme.secondaryText)
                                .tracking(0.8)
                                .padding(.bottom, 20)

                            TimelineStep(
                                time: "7:00",
                                label: "Alarm",
                                icon: "bell.fill",
                                iconBg: Color.orange.opacity(0.15),
                                iconColor: .orange,
                                lineColor: .orange.opacity(0.4),
                                showLine: true,
                                isZigzag: true
                            )

                            TimelineStep(
                                time: "7:09",
                                label: "Snooze",
                                icon: "zzz",
                                iconBg: Color.orange.opacity(0.12),
                                iconColor: .orange.opacity(0.7),
                                lineColor: .orange.opacity(0.3),
                                showLine: true,
                                isZigzag: true
                            )

                            TimelineStep(
                                time: "7:18",
                                label: "Snooze",
                                icon: "zzz",
                                iconBg: Color.red.opacity(0.1),
                                iconColor: .red.opacity(0.6),
                                lineColor: .red.opacity(0.3),
                                showLine: true,
                                isZigzag: true
                            )

                            TimelineStep(
                                time: "7:27",
                                label: "Panic",
                                icon: "exclamationmark.triangle.fill",
                                iconBg: Color.red.opacity(0.12),
                                iconColor: .red,
                                lineColor: .clear,
                                showLine: false,
                                isZigzag: false
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)

                        Rectangle()
                            .fill(AuriseTheme.divider)
                            .frame(width: 1)
                            .padding(.vertical, 4)

                        VStack(spacing: 0) {
                            Text("AURISE MORNING")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(AuriseTheme.accent)
                                .tracking(0.8)
                                .padding(.bottom, 20)

                            TimelineStep(
                                time: "7:00",
                                label: "Alarm",
                                icon: "bell.fill",
                                iconBg: AuriseTheme.accent.opacity(0.12),
                                iconColor: AuriseTheme.accent,
                                lineColor: AuriseTheme.accent.opacity(0.4),
                                showLine: true,
                                isZigzag: false
                            )

                            TimelineStep(
                                time: "7:01",
                                label: "Mission",
                                icon: "checkmark.circle.fill",
                                iconBg: AuriseTheme.accent.opacity(0.12),
                                iconColor: AuriseTheme.accent,
                                lineColor: AuriseTheme.accent.opacity(0.4),
                                showLine: true,
                                isZigzag: false
                            )

                            TimelineStep(
                                time: "7:02",
                                label: "Started",
                                icon: "sun.max.fill",
                                iconBg: AuriseTheme.accent.opacity(0.12),
                                iconColor: AuriseTheme.accent,
                                lineColor: AuriseTheme.accent.opacity(0.3),
                                showLine: true,
                                isZigzag: false
                            )

                            VStack(spacing: 4) {
                                Text("25 MINS")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(AuriseTheme.accent)
                                Text("GAINED")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(AuriseTheme.accent.opacity(0.7))
                                    .tracking(1.0)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AuriseTheme.accent.opacity(0.08))
                            )
                            .padding(.top, 8)
                            .opacity(showGained ? 1 : 0)
                            .scaleEffect(showGained ? 1 : 0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .opacity(showRight ? 1 : 0)
                        .offset(y: showRight ? 0 : 10)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(AuriseTheme.cardFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
                    )
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 24)
            }
            .scrollBounceBehavior(.basedOnSize)

            PrimaryCTAButton("Continue", action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .opacity(showGained ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                showRight = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.9)) {
                showGained = true
            }
        }
    }
}

private struct TimelineStep: View {
    let time: String
    let label: String
    let icon: String
    let iconBg: Color
    let iconColor: Color
    let lineColor: Color
    let showLine: Bool
    let isZigzag: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(iconBg)
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(iconColor)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(time)
                        .font(.system(size: 17, weight: .bold, design: .monospaced))
                        .foregroundStyle(AuriseTheme.primaryText)
                    Text(label)
                        .font(.caption)
                        .foregroundStyle(AuriseTheme.secondaryText)
                }
            }

            if showLine {
                if isZigzag {
                    ZigzagLine(color: lineColor)
                        .frame(width: 2, height: 28)
                        .padding(.leading, -50)
                } else {
                    Rectangle()
                        .fill(lineColor)
                        .frame(width: 2, height: 28)
                        .padding(.leading, -50)
                }
            }
        }
    }
}

private struct ZigzagLine: View {
    let color: Color

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 1, y: 0))
            path.addLine(to: CGPoint(x: -2, y: 7))
            path.addLine(to: CGPoint(x: 4, y: 14))
            path.addLine(to: CGPoint(x: -2, y: 21))
            path.addLine(to: CGPoint(x: 1, y: 28))
        }
        .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
    }
}
