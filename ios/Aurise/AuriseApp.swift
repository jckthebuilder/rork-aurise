import SwiftUI
import UserNotifications
#if canImport(AlarmKit)
import AlarmKit
#endif

@main
struct AuriseApp: App {
    @AppStorage("appThemeMode") private var themeMode: String = AppThemeMode.system.rawValue
    @State private var notificationDelegate = AppNotificationDelegate()
    private let notificationHandler: NotificationDelegateHandler

    init() {
        let delegate = AppNotificationDelegate()
        let handler = NotificationDelegateHandler(appDelegate: delegate)
        _notificationDelegate = State(initialValue: delegate)
        self.notificationHandler = handler
        UNUserNotificationCenter.current().delegate = handler
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(notificationDelegate)
                .preferredColorScheme(AppThemeMode(rawValue: themeMode)?.colorScheme)
        }
    }
}
