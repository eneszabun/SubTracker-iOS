import AppIntents
import Foundation
import SwiftUI

/// Siri: "SubTracker'da toplam aylık harcamam ne kadar?"
@available(iOS 16.0, *)
struct GetMonthlyTotalIntent: AppIntent {
    static var title: LocalizedStringResource = "Aylık Toplam Harcama"
    static var description = IntentDescription("Toplam aylık abonelik harcamanızı gösterir.")
    
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        // Core Data'dan aktif abonelikleri çek
        let dataManager = SubscriptionDataManager.shared
        let subscriptions = dataManager.allSubscriptions.filter { $0.isActive }
        
        guard !subscriptions.isEmpty else {
            return .result(
                dialog: "Henüz hiç aktif aboneliğiniz yok.",
                view: MonthlyTotalSnippetView(total: 0, currency: "TRY", count: 0)
            )
        }
        
        // Para birimi çevirme
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
        
        let dialog = "Toplam aylık abonelik harcamanız \(formattedTotal). \(subscriptions.count) aktif aboneliğiniz var."
        
        return .result(
            dialog: dialog,
            view: MonthlyTotalSnippetView(
                total: totalMonthly,
                currency: defaultCurrency,
                count: subscriptions.count
            )
        )
    }
}

@available(iOS 16.0, *)
struct MonthlyTotalSnippetView: View {
    let total: Double
    let currency: String
    let count: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.blue)
                
                Text("Aylık Toplam")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            Text(formattedAmount)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.blue)
            
            Text("\(count) aktif abonelik")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
    }
    
    private var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: total as NSNumber) ?? "\(total)"
    }
}
