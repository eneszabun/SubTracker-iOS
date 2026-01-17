import SwiftUI
import UserNotifications

// MARK: - Notification Manager
class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    @Published var selectedSubscriptionId: UUID?
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Bildirime tıklandığında çağrılır
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let subscriptionIdString = userInfo["subscriptionId"] as? String,
           let subscriptionId = UUID(uuidString: subscriptionIdString) {
            DispatchQueue.main.async {
                self.selectedSubscriptionId = subscriptionId
            }
        }
        
        completionHandler()
    }
    
    // Uygulama ön plandayken bildirim gelirse
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Ön plandayken de bildirimi göster
        completionHandler([.banner, .sound, .badge])
    }
}

@main
struct SubTrackerApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
        }
    }
}
