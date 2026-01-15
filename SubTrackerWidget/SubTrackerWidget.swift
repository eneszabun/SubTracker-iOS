import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct SubTrackerEntry: TimelineEntry {
    let date: Date
    let monthlyTotal: Double
    let yearlyTotal: Double
    let currency: String
    let upcomingSubscriptions: [WidgetSubscription]
    let activeCount: Int
}

// MARK: - Timeline Provider

struct SubTrackerProvider: TimelineProvider {
    func placeholder(in context: Context) -> SubTrackerEntry {
        SubTrackerEntry(
            date: Date(),
            monthlyTotal: 299.99,
            yearlyTotal: 3599.88,
            currency: "TRY",
            upcomingSubscriptions: [],
            activeCount: 5
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SubTrackerEntry) -> Void) {
        let entry = createEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SubTrackerEntry>) -> Void) {
        let entry = createEntry()
        
        // Her 30 dakikada bir güncelle
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func createEntry() -> SubTrackerEntry {
        let subscriptions = WidgetDataManager.shared.loadForWidget()
        let activeSubscriptions = subscriptions.filter { $0.isActive }
        
        // En çok kullanılan para birimini bul
        let currencyCounts = Dictionary(grouping: activeSubscriptions, by: { $0.currency })
        let primaryCurrency = currencyCounts.max(by: { $0.value.count < $1.value.count })?.key ?? "TRY"
        
        return SubTrackerEntry(
            date: Date(),
            monthlyTotal: activeSubscriptions.monthlyTotal,
            yearlyTotal: activeSubscriptions.yearlyTotal,
            currency: primaryCurrency,
            upcomingSubscriptions: Array(activeSubscriptions.upcoming.prefix(3)),
            activeCount: activeSubscriptions.count
        )
    }
}

// MARK: - Widget Views

struct SubTrackerWidgetEntryView: View {
    var entry: SubTrackerEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [
                            Color(red: 0.11, green: 0.45, blue: 0.93),
                            Color(red: 0.08, green: 0.35, blue: 0.78)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        case .systemMedium:
            MediumWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color.clear
                }
        default:
            SmallWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [
                            Color(red: 0.11, green: 0.45, blue: 0.93),
                            Color(red: 0.08, green: 0.35, blue: 0.78)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: SubTrackerEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                Text("SubTracker")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Aylık Toplam")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                
                Text(formattedAmount(entry.monthlyTotal))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 10, weight: .semibold))
                Text("\(entry.activeCount) aktif abonelik")
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    
    private func formattedAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = entry.currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSNumber) ?? "\(Int(value))"
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: SubTrackerEntry
    
    var body: some View {
        HStack(spacing: 0) {
            // Sol taraf - Toplam
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("SubTracker")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(.white.opacity(0.9))
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Aylık Toplam")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Text(formattedAmount(entry.monthlyTotal))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 10, weight: .semibold))
                    Text("\(entry.activeCount) aktif")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.11, green: 0.45, blue: 0.93),
                        Color(red: 0.08, green: 0.35, blue: 0.78)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            // Sağ taraf - Yakın yenilemeler
            VStack(alignment: .leading, spacing: 8) {
                Text("Yakın Yenilemeler")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                if entry.upcomingSubscriptions.isEmpty {
                    Spacer()
                    Text("14 gün içinde yenileme yok")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    ForEach(entry.upcomingSubscriptions.prefix(3)) { subscription in
                        UpcomingRow(subscription: subscription)
                    }
                    Spacer(minLength: 0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(.systemBackground))
        }
    }
    
    private func formattedAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = entry.currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSNumber) ?? "\(Int(value))"
    }
}

struct UpcomingRow: View {
    let subscription: WidgetSubscription
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(categoryColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(subscription.name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(daysText)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(daysColor)
            }
            
            Spacer()
            
            Text(subscription.formattedAmount)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.primary)
        }
    }
    
    private var daysText: String {
        let days = subscription.daysUntilRenewal
        if days <= 0 {
            return "Bugün"
        } else if days == 1 {
            return "Yarın"
        } else {
            return "\(days) gün"
        }
    }
    
    private var daysColor: Color {
        let days = subscription.daysUntilRenewal
        if days <= 1 {
            return .red
        } else if days <= 3 {
            return .orange
        } else {
            return .secondary
        }
    }
    
    private var categoryColor: Color {
        switch subscription.categoryRaw {
        case "video": return .orange
        case "music": return .pink
        case "productivity": return .blue
        case "storage": return .indigo
        case "utilities": return .green
        default: return .gray
        }
    }
}

// MARK: - Widget Configuration

@main
struct SubTrackerWidget: Widget {
    let kind: String = "SubTrackerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SubTrackerProvider()) { entry in
            SubTrackerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SubTracker")
        .description("Aylık abonelik giderlerinizi ve yakın yenilemeleri görün.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    SubTrackerWidget()
} timeline: {
    SubTrackerEntry(
        date: Date(),
        monthlyTotal: 459.99,
        yearlyTotal: 5519.88,
        currency: "TRY",
        upcomingSubscriptions: [],
        activeCount: 6
    )
}

#Preview(as: .systemMedium) {
    SubTrackerWidget()
} timeline: {
    SubTrackerEntry(
        date: Date(),
        monthlyTotal: 459.99,
        yearlyTotal: 5519.88,
        currency: "TRY",
        upcomingSubscriptions: [
            WidgetSubscription(id: UUID(), name: "Netflix", amount: 120, currency: "TRY", nextRenewal: Date(), cycleMonths: 1, categoryRaw: "video", isActive: true),
            WidgetSubscription(id: UUID(), name: "Spotify", amount: 60, currency: "TRY", nextRenewal: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, cycleMonths: 1, categoryRaw: "music", isActive: true)
        ],
        activeCount: 6
    )
}
