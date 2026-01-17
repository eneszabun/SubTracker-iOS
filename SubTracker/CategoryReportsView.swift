import SwiftUI
import Charts

/// Kategori bazlı raporlar (Pro özelliği)
struct CategoryReportsView: View {
    let subscriptions: [Subscription]
    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    private var palette: ReportsPalette {
        ReportsPalette(scheme: colorScheme)
    }
    
    private var categoryData: [(category: Subscription.Category, total: Double, count: Int)] {
        let grouped = Dictionary(grouping: subscriptions.filter { $0.isActive }) { $0.category }
        return grouped.map { category, subs in
            let total = subs.reduce(0) { $0 + $1.convertedMonthlyCost(to: defaultCurrency) }
            return (category, total, subs.count)
        }
        .sorted { $0.total > $1.total }
    }
    
    private var totalMonthly: Double {
        categoryData.reduce(0) { $0 + $1.total }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Pie Chart
                    pieChartSection
                    
                    // Category List
                    categoryListSection
                }
                .padding(16)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .background(palette.background)
            .navigationTitle("Kategori Raporları")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundStyle(palette.textSecondary)
                }
                
                ToolbarItem(placement: .principal) {
                    ProBadge()
                }
            }
        }
    }
    
    private var pieChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Aylık Dağılım")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(palette.textPrimary)
            
            VStack(spacing: 20) {
                // Chart
                if #available(iOS 16.0, *) {
                    Chart(categoryData, id: \.category) { data in
                        SectorMark(
                            angle: .value("Tutar", data.total),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(data.category.color)
                        .cornerRadius(4)
                    }
                    .frame(height: 250)
                } else {
                    // iOS 16 altı için basit görsel
                    Circle()
                        .fill(palette.primary.opacity(0.2))
                        .frame(height: 250)
                        .overlay(
                            Text("iOS 16+")
                                .foregroundStyle(palette.textSecondary)
                        )
                }
                
                // Total
                VStack(spacing: 4) {
                    Text("Toplam Aylık")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(palette.textSecondary)
                    Text(formattedAmount(totalMonthly))
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(palette.textPrimary)
                }
            }
            .padding(20)
            .background(palette.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(palette.border, lineWidth: 1)
            )
        }
    }
    
    private var categoryListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Kategori Detayları")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(palette.textPrimary)
            
            VStack(spacing: 10) {
                ForEach(categoryData, id: \.category) { data in
                    categoryRow(data)
                }
            }
        }
    }
    
    private func categoryRow(_ data: (category: Subscription.Category, total: Double, count: Int)) -> some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(data.category.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: SubscriptionIconProvider.iconName(for: data.category))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(data.category.color)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(data.category.displayName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(palette.textPrimary)
                
                Text("\(data.count) abonelik")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
            }
            
            Spacer()
            
            // Amount and percentage
            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedAmount(data.total))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(palette.textPrimary)
                
                let percentage = totalMonthly > 0 ? (data.total / totalMonthly) * 100 : 0
                Text(String(format: "%.0f%%", percentage))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(palette.textSecondary)
            }
        }
        .padding(14)
        .background(palette.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        )
    }
    
    private func formattedAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = defaultCurrency
        return formatter.string(from: value as NSNumber) ?? "\(value)"
    }
}

// MARK: - Reports Palette

private struct ReportsPalette {
    let scheme: ColorScheme
    
    var primary: Color { Color(red: 0.11, green: 0.45, blue: 0.93) }
    var background: Color {
        scheme == .dark ? Color(red: 0.06, green: 0.09, blue: 0.13) : Color(red: 0.96, green: 0.97, blue: 0.98)
    }
    var surface: Color {
        scheme == .dark ? Color(red: 0.11, green: 0.14, blue: 0.19) : Color.white
    }
    var border: Color {
        scheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05)
    }
    var textPrimary: Color {
        scheme == .dark ? Color.white : Color(red: 0.09, green: 0.11, blue: 0.13)
    }
    var textSecondary: Color {
        scheme == .dark ? Color(red: 0.62, green: 0.66, blue: 0.72) : Color(red: 0.45, green: 0.5, blue: 0.58)
    }
}
