import SwiftUI

struct Subscription: Identifiable {
    enum Category: String, CaseIterable, Identifiable {
        case video, music, productivity, storage, utilities, other
        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .video: return "Video"
            case .music: return "Muzik"
            case .productivity: return "Uretkenlik"
            case .storage: return "Depolama"
            case .utilities: return "Servis"
            case .other: return "Diger"
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

    enum BillingCycle: String, CaseIterable, Identifiable {
        case monthly, yearly
        var id: String { rawValue }

        var title: String {
            rawValue == "monthly" ? "Aylik" : "Yillik"
        }

        var months: Double {
            rawValue == "monthly" ? 1 : 12
        }
    }

    let id = UUID()
    let name: String
    let amount: Double
    let currency: String
    let nextRenewal: Date
    let cycle: BillingCycle
    let category: Category

    var monthlyCost: Double {
        amount / cycle.months
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: amount as NSNumber) ?? "\(amount) \(currency)"
    }
}

extension Array where Element == Subscription {
    var monthlyTotal: Double { reduce(0) { $0 + $1.monthlyCost } }

    var yearlyTotal: Double { reduce(0) { $0 + ($1.monthlyCost * 12) } }

    var upcoming: [Subscription] {
        let now = Date()
        let horizon = Calendar.current.date(byAdding: .day, value: 14, to: now) ?? now
        return filter { $0.nextRenewal <= horizon }.sorted { $0.nextRenewal < $1.nextRenewal }
    }
}

struct ContentView: View {
    @State private var subscriptions = Subscription.sample

    var body: some View {
        TabView {
            SummaryView(subscriptions: subscriptions)
                .tabItem {
                    Label("Ozet", systemImage: "chart.bar.fill")
                }

            SubscriptionListView(subscriptions: subscriptions)
                .tabItem {
                    Label("Abonelikler", systemImage: "creditcard.fill")
                }
        }
    }
}

struct SummaryView: View {
    let subscriptions: [Subscription]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    totalCards
                    upcomingSection
                }
                .padding()
            }
            .navigationTitle("Ozet")
        }
    }

    private var totalCards: some View {
        let monthly = subscriptions.monthlyTotal
        let yearly = subscriptions.yearlyTotal
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"

        return HStack(spacing: 16) {
            SummaryCard(title: "Aylik", value: formatter.string(from: monthly as NSNumber) ?? "-", color: .blue)
            SummaryCard(title: "Yillik", value: formatter.string(from: yearly as NSNumber) ?? "-", color: .purple)
        }
    }

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Yakin Yenilemeler")
                .font(.headline)
            if subscriptions.upcoming.isEmpty {
                Text("Onumuzdeki 14 gun icinde yenileme yok.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(subscriptions.upcoming) { subscription in
                    SubscriptionRow(subscription: subscription)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }
}

struct SubscriptionListView: View {
    let subscriptions: [Subscription]
    @State private var searchText = ""

    var filtered: [Subscription] {
        guard !searchText.isEmpty else { return subscriptions }
        return subscriptions.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { subscription in
                    SubscriptionRow(subscription: subscription)
                }
            }
            .searchable(text: $searchText, prompt: "Abonelik ara")
            .navigationTitle("Abonelikler")
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.bold())
            Spacer(minLength: 8)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding()
        .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct SubscriptionRow: View {
    let subscription: Subscription

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(subscription.category.color.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "arrow.2.circlepath")
                        .foregroundStyle(subscription.category.color)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.headline)
                Text("\(subscription.category.displayName) • \(subscription.cycle.title)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(subscription.formattedAmount)
                    .font(.headline)
                Text(subscription.nextRenewal, style: .date)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
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

#Preview {
    ContentView()
}
