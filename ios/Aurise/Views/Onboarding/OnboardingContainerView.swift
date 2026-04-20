import SwiftUI

struct OnboardingContainerView: View {
    @State private var vm = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool
    let alarmStore: AlarmStore

    var body: some View {
        ZStack {
            AuriseTheme.pageBg.ignoresSafeArea()

            AdaptiveMeshBackground().opacity(0.8)

            VStack(spacing: 0) {
                if vm.currentStep > 0 && vm.currentStep != 16 && vm.currentStep != 18 {
                    OnboardingProgressBar(progress: vm.progress)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                TabView(selection: $vm.currentStep) {
                    IdentityOpenerView { vm.advance() }
                        .tag(0)

                    MorningEaseView(selection: $vm.morningEase) { vm.advance() }
                        .tag(1)

                    BedReasonView(selection: $vm.bedReason) { vm.advance() }
                        .tag(2)

                    AlarmCountView(selection: $vm.alarmCount) { vm.advance() }
                        .tag(3)

                    ReliabilityCheckView(selection: $vm.singleAlarmWorks) { vm.advance() }
                        .tag(4)

                    EmotionalReframeView { vm.advance() }
                        .tag(5)

                    ProductThesisView { vm.advance() }
                        .tag(6)

                    TargetWakeUpTimeView(targetTime: $vm.targetWakeUpTime) { vm.advance() }
                        .tag(7)

                    CurrentWakeUpTimeView(currentTime: $vm.currentWakeUpTime) { vm.advance() }
                        .tag(8)

                    TimeSavingsView(
                        targetTime: vm.targetWakeUpTime,
                        currentTime: vm.currentWakeUpTime
                    ) { vm.advance() }
                    .tag(9)

                    MotivationInterstitialView { vm.advance() }
                        .tag(10)

                    MissionSelectionView(selection: $vm.selectedMission) { vm.advance() }
                        .tag(11)

                    MissionExplanationView(mission: vm.selectedMission ?? .math) { vm.advance() }
                        .tag(12)

                    AlarmSoundSelectionView(selectedSoundId: $vm.selectedSoundId, playingSoundId: $vm.playingSoundId) { vm.advance() }
                        .tag(13)

                    AlarmIntensityView(selection: $vm.alarmIntensity) { vm.advance() }
                        .tag(14)

                    ActiveDaysView(activeDays: $vm.activeDays, onToggleDay: vm.toggleDay) { vm.advance() }
                        .tag(15)

                    BuildingPlanView { vm.advance() }
                        .tag(16)

                    PlanSummaryView(vm: vm) { vm.advance() }
                        .tag(17)

                    CommitmentView(targetTime: vm.targetTimeFormatted) {
                        vm.advance()
                    }
                    .tag(18)

                    PremiumPaywallView(
                        onUpgrade: {
                            vm.isPremium = true
                            vm.advance()
                        },
                        onContinueFree: { vm.advance() }
                    )
                    .tag(19)

                    NotificationPermissionView(
                        onEnable: { await vm.requestNotifications() },
                        onContinue: { vm.advance() }
                    )
                    .tag(20)

                    AlarmKitPermissionView(
                        onEnable: { await vm.requestAlarmKitAuthorization() },
                        onContinue: { vm.advance() }
                    )
                    .tag(21)

                    CompletionView(vm: vm) {
                        vm.completeOnboarding()
                        alarmStore.createAlarmFromOnboarding(vm: vm)
                        withAnimation(.smooth(duration: 0.5)) {
                            hasCompletedOnboarding = true
                        }
                    }
                    .tag(22)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.smooth(duration: 0.45), value: vm.currentStep)
            }
        }
    }
}
