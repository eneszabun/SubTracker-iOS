import SwiftUI
import Charts

/// Kategori bazlı raporlar (Pro özelliği)
struct CategoryReportsView: View {
    let subscriptions: [Subscription]
    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: Subscription.Category?
    @State private var selectedAngle: Double?
    
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
                // Chart with interactive popup
                GeometryReader { geometry in
                    ZStack {
                        if #available(iOS 17.0, *) {
                            Chart(categoryData, id: \.category) { data in
                                SectorMark(
                                    angle: .value("Tutar", data.total),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 2
                                )
                                .foregroundStyle(data.category.color)
                                .cornerRadius(4)
                            }
                            .chartAngleSelection(value: $selectedAngle)
                            .onChange(of: selectedAngle) { oldValue, newValue in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if let angle = newValue {
                                        selectedCategory = findCategory(for: angle)
                                    } else {
                                        selectedCategory = nil
                                    }
                                }
                            }
                        } else if #available(iOS 16.0, *) {
                            Chart(categoryData, id: \.category) { data in
                                SectorMark(
                                    angle: .value("Tutar", data.total),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 2
                                )
                                .foregroundStyle(data.category.color)
                                .cornerRadius(4)
                            }
                            .overlay(
                                chartTapOverlay(in: geometry)
                            )
                        } else {
                            // iOS 16 altı için basit görsel
                            Circle()
                                .fill(palette.primary.opacity(0.2))
                                .overlay(
                                    Text("iOS 16+")
                                        .foregroundStyle(palette.textSecondary)
                                )
                        }
                        
                        // Category popup
                        if let category = selectedCategory,
                           let data = categoryData.first(where: { $0.category == category }) {
                            categoryPopup(for: data)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .frame(height: 250)
                
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
    
    // MARK: - Interactive Chart Helpers
    
    private func findCategory(for angle: Double) -> Subscription.Category? {
        var accumulatedAngle: Double = 0
        
        for data in categoryData {
            let segmentAngle = (data.total / totalMonthly) * 360
            accumulatedAngle += segmentAngle
            
            if angle <= accumulatedAngle {
                return data.category
            }
        }
        
        return categoryData.first?.category
    }
    
    private func categoryPopup(for data: (category: Subscription.Category, total: Double, count: Int)) -> some View {
        VStack(spacing: 8) {
            // Icon
            Image(systemName: SubscriptionIconProvider.iconName(for: data.category))
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(data.category.color)
                .frame(width: 48, height: 48)
                .background(data.category.color.opacity(0.15), in: Circle())
            
            // Category name
            Text(data.category.displayName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(palette.textPrimary)
            
            // Amount
            Text(formattedAmount(data.total))
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(data.category.color)
            
            // Percentage and count
            HStack(spacing: 12) {
                let percentage = totalMonthly > 0 ? (data.total / totalMonthly) * 100 : 0
                Text(String(format: "%.0f%%", percentage))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(palette.textSecondary)
                
                Text("•")
                    .foregroundStyle(palette.textSecondary.opacity(0.5))
                
                Text("\(data.count) abonelik")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(palette.surface)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(data.category.color.opacity(0.3), lineWidth: 2)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCategory = nil
                selectedAngle = nil
            }
        }
    }
    
    @available(iOS 16.0, *)
    private func chartTapOverlay(in geometry: GeometryProxy) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        let center = CGPoint(
                            x: geometry.size.width / 2,
                            y: geometry.size.height / 2
                        )
                        let angle = calculateAngle(from: value.location, center: center)
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if let currentAngle = selectedAngle, abs(currentAngle - angle) < 5 {
                                // Same category tapped, close popup
                                selectedAngle = nil
                                selectedCategory = nil
                            } else {
                                selectedAngle = angle
                                selectedCategory = findCategory(for: angle)
                            }
                        }
                    }
            )
    }
    
    private func calculateAngle(from point: CGPoint, center: CGPoint) -> Double {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let radians = atan2(dy, dx)
        var angle = radians * 180 / .pi
        
        // Convert to 0-360 degrees, starting from top (12 o'clock)
        angle += 90
        if angle < 0 {
            angle += 360
        }
        
        return angle
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
