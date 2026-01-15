import Foundation

/// Widget ile ana uygulama arasında veri paylaşımı için kullanılan manager.
/// App Group üzerinden UserDefaults ile veri aktarımı yapar.
final class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let appGroupID = "group.com.enesse.SubTracker"
    private let subscriptionsKey = "widget_subscriptions"
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    private init() {}
    
    /// Widget için abonelik verilerini kaydeder
    func saveForWidget(subscriptions: [WidgetSubscription]) {
        guard let defaults = sharedDefaults else { return }
        
        do {
            let data = try JSONEncoder().encode(subscriptions)
            defaults.set(data, forKey: subscriptionsKey)
        } catch {
            print("Widget veri kaydetme hatası: \(error)")
        }
    }
    
    /// Widget için abonelik verilerini yükler
    func loadForWidget() -> [WidgetSubscription] {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: subscriptionsKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([WidgetSubscription].self, from: data)
        } catch {
            print("Widget veri yükleme hatası: \(error)")
            return []
        }
    }
}

/// Widget'ta gösterilecek abonelik verisi (hafif model)
struct WidgetSubscription: Codable, Identifiable {
    let id: UUID
    let name: String
    let amount: Double
    let currency: String
    let nextRenewal: Date
    let cycleMonths: Int // 1 = aylık, 12 = yıllık
    let categoryRaw: String
    let isActive: Bool
    
    var monthlyCost: Double {
        amount / Double(cycleMonths)
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: amount as NSNumber) ?? "\(amount) \(currency)"
    }
    
    /// Bir sonraki yenileme tarihini hesaplar (geçmişte ise ilerletir)
    var upcomingRenewalDate: Date {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        
        if calendar.startOfDay(for: nextRenewal) >= today {
            return nextRenewal
        }
        
        var renewalDate = nextRenewal
        while calendar.startOfDay(for: renewalDate) < today {
            guard let advanced = calendar.date(byAdding: .month, value: cycleMonths, to: renewalDate) else {
                break
            }
            renewalDate = advanced
        }
        
        return renewalDate
    }
    
    /// Yenilemeye kalan gün sayısı
    var daysUntilRenewal: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: upcomingRenewalDate).day ?? 0
    }
}

extension Array where Element == WidgetSubscription {
    var monthlyTotal: Double {
        reduce(0) { $0 + ($1.isActive ? $1.monthlyCost : 0) }
    }
    
    var yearlyTotal: Double {
        monthlyTotal * 12
    }
    
    /// Önümüzdeki 14 gün içinde yenilenecek abonelikler
    var upcoming: [WidgetSubscription] {
        let horizon = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
        return filter { $0.isActive && $0.upcomingRenewalDate <= horizon }
            .sorted { $0.upcomingRenewalDate < $1.upcomingRenewalDate }
    }
}
