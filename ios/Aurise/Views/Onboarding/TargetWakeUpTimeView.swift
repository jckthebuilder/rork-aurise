import SwiftUI

struct TargetWakeUpTimeView: View {
    @Binding var targetTime: Date
    let onContinue: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 36) {
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AuriseTheme.accent.opacity(0.12))
                            .frame(width: 56, height: 56)

                        Image(systemName: "alarm.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AuriseTheme.accent)
                    }

                    Text("What time do you want\nto be out of bed?")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AuriseTheme.primaryText)
                        .lineSpacing(3)

                    Text("Your ideal wake-up time")
                        .font(.subheadline)
                        .foregroundStyle(AuriseTheme.secondaryText)
                }

                DatePicker("Wake-up time", selection: $targetTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(height: 180)
                    .padding(.horizontal, 40)

            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 14)

            Spacer()
            Spacer()

            PrimaryCTAButton("Continue", action: onContinue)
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
