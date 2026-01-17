import Foundation
import UserNotifications

actor NotificationScheduler {
    static let shared = NotificationScheduler()
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async {
        do {
            _ = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            // ignore errors silently for now
        }
    }

    func schedule(subscription: Subscription, reminderDays: Int) async {
        await scheduleInternal(subscription: subscription, reminderDays: reminderDays)
    }

    func reschedule(subscription: Subscription, reminderDays: Int) async {
        await cancelInternal(for: subscription.id)
        await scheduleInternal(subscription: subscription, reminderDays: reminderDays)
    }

    func cancel(for id: UUID) async {
        await cancelInternal(for: id)
    }

    func syncAll(subscriptions: [Subscription], reminderDays: Int) async {
        center.removeAllPendingNotificationRequests()
        for subscription in subscriptions {
            await scheduleInternal(subscription: subscription, reminderDays: reminderDays)
        }
    }

    private func scheduleInternal(subscription: Subscription, reminderDays: Int) async {
        let identifiers = identifiers(for: subscription.id)
        await cancelInternal(for: subscription.id)

        let contentBase = UNMutableNotificationContent()
        contentBase.title = "\(subscription.name) yenilemesi"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = subscription.currency
        let amountText = formatter.string(from: subscription.amount as NSNumber) ?? ""
        
        // Deep link için abonelik ID'sini userInfo'ya ekle
        let userInfo: [String: String] = ["subscriptionId": subscription.id.uuidString]

        let calendar = Calendar.current
        let now = Date()

        let renewalDate = subscription.upcomingRenewalDate
        
        if reminderDays > 0,
           let reminderDate = calendar.date(byAdding: .day, value: -reminderDays, to: renewalDate),
           reminderDate > now {
            let content = UNMutableNotificationContent()
            content.title = contentBase.title
            content.body = "\(reminderDays) gün sonra yenileniyor. Tutar: \(amountText)"
            content.sound = .default
            content.userInfo = userInfo
            let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate), repeats: false)
            let request = UNNotificationRequest(identifier: identifiers.reminder, content: content, trigger: trigger)
            try? await center.add(request)
        }

        if renewalDate > now {
            let content = UNMutableNotificationContent()
            content.title = contentBase.title
            content.body = "Bugün yenileniyor. Tutar: \(amountText)"
            content.sound = .default
            content.userInfo = userInfo
            let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: renewalDate), repeats: false)
            let request = UNNotificationRequest(identifier: identifiers.renewal, content: content, trigger: trigger)
            try? await center.add(request)
        }
    }

    private func cancelInternal(for id: UUID) async {
        let ids = identifiers(for: id)
        center.removePendingNotificationRequests(withIdentifiers: [ids.reminder, ids.renewal])
    }

    private func identifiers(for id: UUID) -> (reminder: String, renewal: String) {
        let base = id.uuidString
        return ("\(base)-reminder", "\(base)-renewal")
    }
    
    // MARK: - Test Functions
    
    /// Test bildirimi gönderir (5 saniye sonra)
    func sendTestNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "SubTracker Test Bildirimi"
        content.body = "Bildirimler düzgün çalışıyor! 🎉"
        content.sound = .default
        
        // 5 saniye sonra tetikle
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test-notification", content: content, trigger: trigger)
        
        try? await center.add(request)
    }
    
    /// Belirli bir abonelik için hemen test bildirimi gönderir
    func sendTestReminderNotification(for subscription: Subscription, reminderDays: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "\(subscription.name) yenilemesi"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = subscription.currency
        let amountText = formatter.string(from: subscription.amount as NSNumber) ?? "\(subscription.amount)"
        
        content.body = "\(reminderDays) gün sonra yenileniyor. Tutar: \(amountText)"
        content.sound = .default
        content.userInfo = ["subscriptionId": subscription.id.uuidString]
        
        // 3 saniye sonra tetikle
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "test-reminder-\(subscription.id.uuidString)", content: content, trigger: trigger)
        
        try? await center.add(request)
    }
    
    /// Bekleyen bildirimleri listeler (debug için)
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }
}
