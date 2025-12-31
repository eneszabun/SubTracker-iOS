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
        await center.removeAllPendingNotificationRequests()
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

        let calendar = Calendar.current
        let now = Date()

        if reminderDays > 0,
           let reminderDate = calendar.date(byAdding: .day, value: -reminderDays, to: subscription.nextRenewal),
           reminderDate > now {
            var content = UNMutableNotificationContent()
            content.title = contentBase.title
            content.body = "\(reminderDays) gün sonra yenileniyor. Tutar: \(amountText)"
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate), repeats: false)
            let request = UNNotificationRequest(identifier: identifiers.reminder, content: content, trigger: trigger)
            try? await center.add(request)
        }

        if subscription.nextRenewal > now {
            var content = UNMutableNotificationContent()
            content.title = contentBase.title
            content.body = "Bugün yenileniyor. Tutar: \(amountText)"
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: subscription.nextRenewal), repeats: false)
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
}
