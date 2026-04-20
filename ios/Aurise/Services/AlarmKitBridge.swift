import Foundation
#if canImport(AlarmKit)
import AlarmKit
#endif

@available(iOS 26.0, *)
@MainActor
final class AlarmKitBridge {
    static let shared = AlarmKitBridge()
    private var task: Task<Void, Never>?
    private weak var alarmStore: AlarmStore?
    private weak var notificationDelegate: AppNotificationDelegate?
    private var lastAlertedId: UUID?

    private init() {}

    func start(alarmStore: AlarmStore, notificationDelegate: AppNotificationDelegate) {
        self.alarmStore = alarmStore
        self.notificationDelegate = notificationDelegate
        guard task == nil else { return }
        task = Task { [weak self] in
            await self?.observe()
        }
    }

    private func observe() async {
        for await alarms in AlarmManager.shared.alarmUpdates {
            handle(alarms: alarms)
        }
    }

    private func handle(alarms: [AlarmKit.Alarm]) {
        guard let store = alarmStore, let delegate = notificationDelegate else { return }

        let alerting = alarms.first { $0.state == .alerting }

        if let alerting {
            if lastAlertedId == alerting.id { return }
            lastAlertedId = alerting.id

            guard let model = store.alarmById(alerting.id.uuidString) else { return }
            delegate.triggerAlarm(
                alarmId: model.id.uuidString,
                missionType: model.missionType,
                soundId: model.soundId,
                intensity: model.intensity
            )
        } else {
            lastAlertedId = nil
        }
    }
}
