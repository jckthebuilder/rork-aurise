import SwiftUI

struct AlarmRingingView: View {
    let alarm: Alarm?
    let missionType: MissionType
    let onDismiss: () -> Void
    let onSnooze: () -> Void

    @State private var showMission: Bool = false
    @State private var missionCompleted: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var appeared: Bool = false
    @State private var timeString: String = ""
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if showMission {
                MissionExecutionView(missionType: missionType) {
                    withAnimation(.spring(response: 0.5)) {
                        missionCompleted = true
                        showMission = false
                    }
                    SoundService.shared.stopSound()
                    Task {
                        try? await Task.sleep(for: .seconds(1.5))
                        onDismiss()
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else if missionCompleted {
                completionOverlay
                    .transition(.scale.combined(with: .opacity))
            } else {
                alarmRingingContent
                    .transition(.opacity)
            }
        }
        .onAppear {
            updateTime()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                Task { @MainActor in updateTime() }
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                appeared = true
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .statusBarHidden(true)
    }

    private var alarmRingingContent: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(AuriseTheme.accent.opacity(0.15 - Double(i) * 0.04), lineWidth: 2)
                        .frame(width: CGFloat(120 + i * 50), height: CGFloat(120 + i * 50))
                        .scaleEffect(pulseScale)
                        .animation(
                            .easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.2),
                            value: pulseScale
                        )
                }

                VStack(spacing: 8) {
                    Image(systemName: "alarm.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(AuriseTheme.accent)
                        .symbolEffect(.bounce.byLayer, options: .repeating, value: appeared)

                    Text(timeString)
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }
            }
            .onAppear {
                pulseScale = 1.15
            }

            if let alarm {
                Text(alarm.title)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.top, 16)
            }

            HStack(spacing: 6) {
                Image(systemName: missionType.icon)
                    .font(.caption.weight(.semibold))
                Text(missionType.displayName)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(missionType.accentColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(missionType.accentColor.opacity(0.15)))
            .padding(.top, 12)

            Spacer()

            VStack(spacing: 14) {
                Button {
                    withAnimation(.spring(response: 0.4)) {
                        showMission = true
                    }
                } label: {
                    Text("Start Mission")
                        .font(.body.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AuriseTheme.accentGradient)
                        )
                        .shadow(color: AuriseTheme.accentGlow.opacity(0.4), radius: 20, y: 8)
                }
                .sensoryFeedback(.impact(weight: .heavy), trigger: showMission)

                Button {
                    onSnooze()
                } label: {
                    Text("Snooze 5 min")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(.white.opacity(0.06))
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
        }
    }

    private var completionOverlay: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: missionCompleted)
            }

            Text("Good morning!")
                .font(.title.weight(.bold))
                .foregroundStyle(.white)

            Text("Mission complete. Have a great day.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))

            Spacer()
        }
    }

    private func updateTime() {
        timeString = Date().formatted(date: .omitted, time: .shortened)
    }
}
