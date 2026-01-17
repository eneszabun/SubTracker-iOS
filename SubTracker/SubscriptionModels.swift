import SwiftUI

struct Subscription: Identifiable, Codable, Equatable {
    enum Category: String, CaseIterable, Identifiable, Codable, Equatable {
        case video, music, productivity, storage, utilities, other
        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .video: return "Video"
            case .music: return "Müzik"
            case .productivity: return "Üretkenlik"
            case .storage: return "Depolama"
            case .utilities: return "Servis"
            case .other: return "Diğer"
            }
        }

        var color: Color {
            switch self {
            case .video: return .orange
            case .music: return .pink
            case .productivity: return .blue
            case .storage: return .indigo
            case .utilities: return .green
            case .other: return .gray
            }
        }
    }

    enum BillingCycle: String, CaseIterable, Identifiable, Codable, Equatable {
        case monthly, yearly
        var id: String { rawValue }

        var title: String {
            rawValue == "monthly" ? "Aylık" : "Yıllık"
        }

        var months: Double {
            rawValue == "monthly" ? 1 : 12
        }
    }

    var id: UUID = UUID()
    var name: String
    var amount: Double
    var currency: String
    /// Aboneliğin başlangıç/referans tarihi (ilk ödeme tarihi)
    var nextRenewal: Date
    var endDate: Date?
    var cycle: BillingCycle
    var category: Category

    var icon: String {
        SubscriptionIconProvider.iconName(for: category)
    }

    var monthlyCost: Double {
        amount / cycle.months
    }

    var amountForCycle: Double {
        amount
    }

    var isActive: Bool {
        guard let end = endDate else { return true }
        return end >= Date()
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: amount as NSNumber) ?? "\(amount) \(currency)"
    }
    
    /// Bir sonraki yenileme tarihini hesaplar.
    /// Eğer `nextRenewal` geçmişteyse, döngüye göre (aylık/yıllık) bugüne veya geleceğe kadar ilerletir.
    var upcomingRenewalDate: Date {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        
        // Başlangıç tarihi zaten gelecekteyse, olduğu gibi döndür
        if calendar.startOfDay(for: nextRenewal) >= today {
            return nextRenewal
        }
        
        // Bitiş tarihi varsa ve geçmişteyse, son yenileme tarihini döndür
        if let end = endDate, end < now {
            return nextRenewal
        }
        
        // Döngüye göre adım sayısı (ay cinsinden)
        let stepMonths = cycle == .monthly ? 1 : 12
        
        // Geçmişten bugüne kadar ilerlet
        var renewalDate = nextRenewal
        while calendar.startOfDay(for: renewalDate) < today {
            // Bitiş tarihi kontrolü
            if let end = endDate, renewalDate > end {
                break
            }
            
            guard let advanced = calendar.date(byAdding: .month, value: stepMonths, to: renewalDate) else {
                break
            }
            renewalDate = advanced
        }
        
        return renewalDate
    }
    
    /// Aboneliğin geçmiş ödeme kayıtlarını hesaplar (başlangıçtan bugüne kadar)
    var paymentHistory: [PaymentRecord] {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let startDay = calendar.startOfDay(for: nextRenewal)
        
        // Başlangıç tarihi gelecekteyse, henüz ödeme yapılmamış
        if startDay > today {
            return []
        }
        
        var payments: [PaymentRecord] = []
        let stepMonths = cycle == .monthly ? 1 : 12
        var currentDate = nextRenewal
        
        // Başlangıçtan bugüne kadar tüm ödeme dönemlerini hesapla
        while calendar.startOfDay(for: currentDate) <= today {
            // Bitiş tarihi kontrolü
            if let end = endDate, currentDate > end {
                break
            }
            
            payments.append(PaymentRecord(
                date: currentDate,
                amount: amount,
                currency: currency
            ))
            
            guard let advanced = calendar.date(byAdding: .month, value: stepMonths, to: currentDate) else {
                break
            }
            currentDate = advanced
            
            // Makul bir limit (10 yıl) - sonsuz döngüyü önlemek için
            if payments.count >= 120 {
                break
            }
        }
        
        // En yeni ödemeler en üstte olsun
        return payments.reversed()
    }
    
    /// Toplam yapılan ödeme sayısı
    var totalPaymentCount: Int {
        paymentHistory.count
    }
    
    /// Toplam harcanan tutar
    var totalSpent: Double {
        Double(paymentHistory.count) * amount
    }
    
    var formattedTotalSpent: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: totalSpent as NSNumber) ?? "\(totalSpent) \(currency)"
    }
}

extension Array where Element == Subscription {
    var monthlyTotal: Double { reduce(0) { $0 + ($1.isActive ? $1.monthlyCost : 0) } }

    var yearlyTotal: Double { reduce(0) { $0 + ($1.isActive ? ($1.monthlyCost * 12) : 0) } }

    /// Önümüzdeki 14 gün içinde yenilenecek abonelikler
    var upcoming: [Subscription] {
        let now = Date()
        let horizon = Calendar.current.date(byAdding: .day, value: 14, to: now) ?? now
        return filter { $0.isActive && $0.upcomingRenewalDate <= horizon }
            .sorted { $0.upcomingRenewalDate < $1.upcomingRenewalDate }
    }
}

enum SubscriptionIconProvider {
    static func iconName(for category: Subscription.Category) -> String {
        switch category {
        case .video: return "tv"
        case .music: return "music.note.list"
        case .productivity: return "square.and.pencil"
        case .storage: return "externaldrive.fill"
        case .utilities: return "gearshape.fill"
        case .other: return "star.fill"
        }
    }
}

struct MonthlyCost: Identifiable {
    let id = UUID()
    let date: Date
    let total: Double

    var monthLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "LLL"
        return formatter.string(from: date).capitalized
    }
}

/// Geçmiş ödeme kaydı
struct PaymentRecord: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let amount: Double
    let currency: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: amount as NSNumber) ?? "\(amount) \(currency)"
    }
    
    /// Ödemenin kaç gün önce yapıldığını hesaplar
    var daysAgo: Int {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        let paymentDay = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: paymentDay, to: now).day ?? 0
    }
    
    var relativeTimeText: String {
        let days = daysAgo
        if days == 0 {
            return "Bugün"
        } else if days == 1 {
            return "Dün"
        } else if days < 7 {
            return "\(days) gün önce"
        } else if days < 30 {
            let weeks = days / 7
            return weeks == 1 ? "1 hafta önce" : "\(weeks) hafta önce"
        } else if days < 365 {
            let months = days / 30
            return months == 1 ? "1 ay önce" : "\(months) ay önce"
        } else {
            let years = days / 365
            return years == 1 ? "1 yıl önce" : "\(years) yıl önce"
        }
    }
}


#if DEBUG
extension Subscription {
    static var sample: [Subscription] {
        let calendar = Calendar.current
        let now = Date()
        func date(offset days: Int) -> Date { calendar.date(byAdding: .day, value: days, to: now) ?? now }

        return [
            Subscription(name: "Netflix", amount: 15.99, currency: "USD", nextRenewal: date(offset: 3), cycle: .monthly, category: .video),
            Subscription(name: "Spotify", amount: 9.99, currency: "USD", nextRenewal: date(offset: 10), cycle: .monthly, category: .music),
            Subscription(name: "iCloud+", amount: 119.99, currency: "USD", nextRenewal: date(offset: 25), cycle: .yearly, category: .storage),
            Subscription(name: "Notion", amount: 8.0, currency: "USD", nextRenewal: date(offset: 5), cycle: .monthly, category: .productivity)
        ]
    }
}
#endif
