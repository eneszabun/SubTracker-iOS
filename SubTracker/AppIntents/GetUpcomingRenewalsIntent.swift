import AppIntents
import Foundation
import SwiftUI

/// Siri: "SubTracker'da yaklaşan yenilemelerim var mı?"
@available(iOS 16.0, *)
struct GetUpcomingRenewalsIntent: AppIntent {
    static var title: LocalizedStringResource = "Yaklaşan Yenilemeler"
    static var description = IntentDescription("Önümüzdeki 7 gün içinde yenilenecek abonelikleri gösterir.")
    
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Gün Sayısı", default: 7)
    var days: Int
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let dataManager = SubscriptionDataManager.shared
        let subscriptions = dataManager.allSubscriptions.filter { $0.isActive }
        
        guard !subscriptions.isEmpty else {
            return .result(
                dialog: "Henüz hiç aktif aboneliğiniz yok.",
                view: UpcomingRenewalsSnippetView(renewals: [])
            )
        }
        
        // Yaklaşan yenilemeleri filtrele
        let calendar = Calendar.current
        let now = Date()
        let targetDate = calendar.date(byAdding: .day, value: days, to: now) ?? now
        
        let upcomingRenewals = subscriptions
            .filter { subscription in
                guard let nextRenewal = subscription.nextRenewal else { return false }
                return nextRenewal >= now && nextRenewal <= targetDate
            }
            .sorted { $0.nextRenewal ?? Date() < $1.nextRenewal ?? Date() }
        
        let dialog: String
        if upcomingRenewals.isEmpty {
            dialog = "Önümüzdeki \(days) gün içinde yenilenecek abonelik yok."
        } else if upcomingRenewals.count == 1 {
            let sub = upcomingRenewals[0]
            let daysUntil = calendar.dateComponents([.day], from: now, to: sub.nextRenewal ?? now).day ?? 0
            if daysUntil == 0 {
                dialog = "\(sub.name) bugün yenilenecek."
            } else {
                dialog = "\(sub.name) \(daysUntil) gün içinde yenilenecek."
            }
        } else {
            dialog = "Önümüzdeki \(days) gün içinde \(upcomingRenewals.count) abonelik yenilenecek."
        }
        
        let renewalData = upcomingRenewals.prefix(5).map { sub in
            RenewalData(
                name: sub.name,
                date: sub.nextRenewal ?? Date(),
                amount: sub.amount,
                currency: sub.currency
            )
        }
        
        return .result(
            dialog: dialog,
            view: UpcomingRenewalsSnippetView(renewals: Array(renewalData))
        )
    }
}

@available(iOS 16.0, *)
struct RenewalData: Identifiable {
    let id = UUID()
    let name: String
    let date: Date
    let amount: Double
    let currency: String
}

@available(iOS 16.0, *)
struct UpcomingRenewalsSnippetView: View {
    let renewals: [RenewalData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 24))
                    .foregroundStyle(.orange)
                
                Text("Yaklaşan Yenilemeler")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            if renewals.isEmpty {
                Text("Yaklaşan yenileme yok")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(renewals) { renewal in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(renewal.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                
                                Text(renewal.date, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(formattedAmount(renewal.amount, currency: renewal.currency))
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(.orange)
                        }
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
