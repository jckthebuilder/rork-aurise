import SwiftUI

struct CurrentWakeUpTimeView: View {
    @Binding var currentTime: Date
    let onContinue: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 36) {
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AuriseTheme.subtleFill)
                            .frame(width: 56, height: 56)

                        Image(systemName: "bed.double.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AuriseTheme.secondaryText)
                    }

                    Text("What time do you usually\nget out of bed now?")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AuriseTheme.primaryText)
                        .lineSpacing(3)

                    Text("Be honest — no judgment")
                        .font(.subheadline)
                        .foregroundStyle(AuriseTheme.secondaryText)
                }

                DatePicker("Current wake-up time", selection: $currentTime, displayedComponents: .hourAndMinute)
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
