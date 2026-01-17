import AppIntents
import Foundation
import SwiftUI

/// Siri: "SubTracker'da aboneliklerimi göster"
@available(iOS 16.0, *)
struct GetSubscriptionsIntent: AppIntent {
    static var title: LocalizedStringResource = "Aboneliklerimi Göster"
    static var description = IntentDescription("Tüm aktif aboneliklerinizi listeler.")
    
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Kategori")
    var category: SubscriptionCategoryEntity?
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let dataManager = SubscriptionDataManager.shared
        var subscriptions = dataManager.allSubscriptions.filter { $0.isActive }
        
        guard !subscriptions.isEmpty else {
            return .result(
                dialog: "Henüz hiç aktif aboneliğiniz yok.",
                view: SubscriptionsListSnippetView(subscriptions: [])
            )
        }
        
        // Kategori filtresi
        if let category = category {
            subscriptions = subscriptions.filter { $0.category.displayName == category.name }
        }
        
        let defaultCurrency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "TRY"
        var totalMonthly: Double = 0
        
        for subscription in subscriptions {
            let convertedAmount = CurrencyConverterSync.shared.convert(
                amount: subscription.monthlyCost,
                from: subscription.currency,
                to: defaultCurrency
            )
            totalMonthly += convertedAmount
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = defaultCurrency
        let formattedTotal = formatter.string(from: totalMonthly as NSNumber) ?? "\(totalMonthly)"
        
        let dialog: String
        if let category = category {
            dialog = "\(category.name) kategorisinde \(subscriptions.count) aktif aboneliğiniz var. Toplam \(formattedTotal)."
        } else {
            dialog = "\(subscriptions.count) aktif aboneliğiniz var. Toplam aylık \(formattedTotal)."
        }
        
        let subscriptionData = subscriptions.prefix(10).map { sub in
            SubscriptionData(
                name: sub.name,
                amount: sub.amount,
                currency: sub.currency,
                cycle: sub.cycle.displayName,
                nextRenewal: sub.nextRenewal
            )
        }
        
        return .result(
            dialog: dialog,
            view: SubscriptionsListSnippetView(subscriptions: Array(subscriptionData))
        )
    }
}

@available(iOS 16.0, *)
struct SubscriptionCategoryEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Kategori")
    static var defaultQuery = SubscriptionCategoryQuery()
    
    let id: String
    let name: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

@available(iOS 16.0, *)
struct SubscriptionCategoryQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [SubscriptionCategoryEntity] {
        identifiers.compactMap { id in
            guard let category = Subscription.Category.allCases.first(where: { $0.rawValue == id }) else {
                return nil
            }
            return SubscriptionCategoryEntity(id: id, name: category.displayName)
        }
    }
    
    func suggestedEntities() async throws -> [SubscriptionCategoryEntity] {
        Subscription.Category.allCases.map { category in
            SubscriptionCategoryEntity(id: category.rawValue, name: category.displayName)
        }
    }
}

@available(iOS 16.0, *)
struct SubscriptionData: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let currency: String
    let cycle: String
    let nextRenewal: Date?
}

@available(iOS 16.0, *)
struct SubscriptionsListSnippetView: View {
    let subscriptions: [SubscriptionData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 24))
                    .foregroundStyle(.blue)
                
                Text("Aboneliklerim")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            if subscriptions.isEmpty {
                Text("Aktif abonelik yok")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(subscriptions) { sub in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(sub.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                
                                Text(sub.cycle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(formattedAmount(sub.amount, currency: sub.currency))
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    if subscriptions.count >= 10 {
                        Text("...ve daha fazlası")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(16)
    }
    
    private func formattedAmount(_ value: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: value as NSNumber) ?? "\(value)"
    }
}
