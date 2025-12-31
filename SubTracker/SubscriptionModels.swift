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
}

extension Array where Element == Subscription {
    var monthlyTotal: Double { reduce(0) { $0 + ($1.isActive ? $1.monthlyCost : 0) } }

    var yearlyTotal: Double { reduce(0) { $0 + ($1.isActive ? ($1.monthlyCost * 12) : 0) } }

    var upcoming: [Subscription] {
        let now = Date()
        let horizon = Calendar.current.date(byAdding: .day, value: 14, to: now) ?? now
        return filter { $0.isActive && $0.nextRenewal <= horizon }.sorted { $0.nextRenewal < $1.nextRenewal }
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

extension UUID: Identifiable {
    public var id: UUID { self }
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
