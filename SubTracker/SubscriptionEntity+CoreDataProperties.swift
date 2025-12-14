import Foundation
import CoreData

extension SubscriptionEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubscriptionEntity> {
        NSFetchRequest<SubscriptionEntity>(entityName: "SubscriptionEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var amount: Double
    @NSManaged public var currency: String?
    @NSManaged public var nextRenewal: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var cycle: String?
    @NSManaged public var category: String?

    func toSubscription() -> Subscription {
        Subscription(
            id: id ?? UUID(),
            name: name ?? "",
            amount: amount,
            currency: currency ?? "USD",
            nextRenewal: nextRenewal ?? Date(),
            endDate: endDate,
            cycle: Subscription.BillingCycle(rawValue: cycle ?? "monthly") ?? .monthly,
            category: Subscription.Category(rawValue: category ?? "other") ?? .other
        )
    }
}

extension SubscriptionEntity: Identifiable {}
