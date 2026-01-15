import SwiftUI
import Charts

struct YearlyBreakdownView: View {
    let breakdown: [MonthlyCost]
    let currencyCode: String
    let yearlyTotal: Double
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedIndex: Int?
    
    var body: some View {
        Group {
            if colorScheme == .light {
                lightBody
            } else {
                darkBody
            }
        }
        .navigationTitle("Yıllık Detay")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }
    
    // MARK: - Light Mode
    
    private var lightBody: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                headerCard(
                    background: YearlyLightPalette.surface,
                    border: YearlyLightPalette.border,
                    textPrimary: YearlyLightPalette.textPrimary,
                    textMuted: YearlyLightPalette.textMuted,
                    shadow: YearlyLightPalette.shadow
                )
                
                // Main Chart Card
                chartCard(isLight: true)
                
                // Monthly Details
                monthlyDetailsSection(isLight: true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.hidden)
        .background(YearlyLightPalette.background)
    }
    
    // MARK: - Dark Mode
    
    private var darkBody: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                headerCard(
                    background: YearlyDarkPalette.surface,
                    border: YearlyDarkPalette.border,
                    textPrimary: YearlyDarkPalette.textPrimary,
                    textMuted: YearlyDarkPalette.textMuted,
                    shadow: .clear
                )
                
                // Main Chart Card
                chartCard(isLight: false)
                
                // Monthly Details
                monthlyDetailsSection(isLight: false)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.hidden)
        .background(YearlyDarkPalette.background)
    }
    
    // MARK: - Components
    
    private func headerCard(
        background: Color,
        border: Color,
        textPrimary: Color,
        textMuted: Color,
        shadow: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TOPLAM YILLIK TAHMİNİ")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(textMuted)
                .tracking(0.6)
            
            Text(yearlyText)
                .font(.system(size: 36, weight: .black))
                .foregroundStyle(textPrimary)
            
            Text("Önümüzdeki 12 ay tahmini gider")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(border, lineWidth: 1)
        )
        .shadow(color: shadow, radius: 10, x: 0, y: 2)
    }
    
    private func chartCard(isLight: Bool) -> some View {
        let palette = YearlyPaletteValues.palette(isLight: isLight)
        
        return VStack(alignment: .leading, spacing: 20) {
            // Chart Title
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(palette.primary)
                    .frame(width: 32, height: 32)
                    .background(palette.primary.opacity(0.12), in: Circle())
                
                Text("AYLIK DAĞILIM")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(palette.textMuted)
                    .tracking(0.6)
            }
            
            // Custom Bar Chart
            customBarChart(isLight: isLight)
            
            // Month Labels
            monthLabels(isLight: isLight)
            
            // Selected Month Info
            if let index = selectedIndex, breakdown.indices.contains(index) {
                selectedMonthCard(month: breakdown[index], isLight: isLight)
            }
        }
        .padding(20)
        .background(palette.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        )
        .shadow(color: isLight ? palette.shadow : .clear, radius: 10, x: 0, y: 2)
    }
    
    private func customBarChart(isLight: Bool) -> some View {
        let palette = YearlyPaletteValues.palette(isLight: isLight)
        let values = breakdown.map(\.total)
        let maxValue = values.max() ?? 0
        
        return GeometryReader { proxy in
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(breakdown.indices, id: \.self) { index in
                    let value = breakdown[index].total
                    let ratio = maxValue > 0 ? value / maxValue : 0
                    let barHeight = ratio > 0 ? max(12, ratio * proxy.size.height) : 8
                    let isSelected = selectedIndex == index
                    let hasValue = value > 0
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedIndex = selectedIndex == index ? nil : index
                        }
                    } label: {
                        ZStack(alignment: .bottom) {
                            // Base bar (background)
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(isLight ? palette.chartBase : palette.chartEmpty)
                                .frame(height: proxy.size.height)
                            
                            // Filled bar
                            if hasValue {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: isSelected 
                                                ? [palette.primary, palette.primary.opacity(0.7)]
                                                : [palette.primary.opacity(0.85), palette.primary.opacity(0.6)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(height: barHeight)
                                    .shadow(
                                        color: isSelected ? palette.primary.opacity(0.4) : .clear,
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            }
                        }
                        .scaleEffect(isSelected ? 1.05 : 1.0, anchor: .bottom)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(height: 180)
    }
    
    private func monthLabels(isLight: Bool) -> some View {
        let palette = YearlyPaletteValues.palette(isLight: isLight)
        
        return HStack(spacing: 0) {
            ForEach(breakdown.indices, id: \.self) { index in
                Text(breakdown[index].monthLabel)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(
                        selectedIndex == index 
                            ? palette.primary 
                            : palette.textMuted
                    )
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func selectedMonthCard(month: MonthlyCost, isLight: Bool) -> some View {
        let palette = YearlyPaletteValues.palette(isLight: isLight)
        
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(month.fullMonthLabel.capitalized)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(palette.textPrimary)
                
                Text("Tahmini gider")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(palette.textMuted)
            }
            
            Spacer()
            
            Text(formattedAmount(month.total))
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(palette.primary)
        }
        .padding(16)
        .background(palette.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(palette.primary.opacity(0.2), lineWidth: 1)
        )
        .transition(.asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .opacity
        ))
    }
    
    private func monthlyDetailsSection(isLight: Bool) -> some View {
        let palette = YearlyPaletteValues.palette(isLight: isLight)
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("AYLIK DETAYLAR")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(palette.textMuted)
                .tracking(0.6)
                .padding(.horizontal, 4)
            
            LazyVStack(spacing: 8) {
                ForEach(breakdown.indices, id: \.self) { index in
                    monthlyDetailRow(
                        month: breakdown[index],
                        index: index,
                        isLight: isLight
                    )
                }
            }
        }
    }
    
    private func monthlyDetailRow(month: MonthlyCost, index: Int, isLight: Bool) -> some View {
        let palette = YearlyPaletteValues.palette(isLight: isLight)
        let maxTotal = breakdown.map(\.total).max() ?? 0
        let ratio = maxTotal > 0 ? month.total / maxTotal : 0
        
        return HStack(spacing: 12) {
            // Month indicator
            Text(month.monthLabel)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(palette.textPrimary)
                .frame(width: 36)
            
            // Progress bar
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(isLight ? palette.chartBase : palette.chartEmpty)
                    
                    if month.total > 0 {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [palette.primary, palette.primary.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(8, ratio * proxy.size.width))
                    }
                }
            }
            .frame(height: 8)
            
            // Amount
            Text(formattedAmount(month.total))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(month.total > 0 ? palette.textPrimary : palette.textMuted)
                .frame(width: 90, alignment: .trailing)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(palette.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        )
    }
    
    // MARK: - Helpers
    
    private var yearlyText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: yearlyTotal as NSNumber) ?? "-"
    }
    
    private func formattedAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: value as NSNumber) ?? "\(value)"
    }
}

// MARK: - Palette Values Struct

private struct YearlyPaletteValues {
    let primary: Color
    let background: Color
    let surface: Color
    let border: Color
    let chartBase: Color
    let chartEmpty: Color
    let textPrimary: Color
    let textMuted: Color
    let shadow: Color
    
    static let light = YearlyPaletteValues(
        primary: Color(red: 0.11, green: 0.45, blue: 0.93),
        background: Color(red: 0.95, green: 0.96, blue: 0.97),
        surface: Color.white,
        border: Color(red: 0.94, green: 0.95, blue: 0.96),
        chartBase: Color(red: 0.93, green: 0.94, blue: 0.96),
        chartEmpty: Color(red: 0.93, green: 0.94, blue: 0.96),
        textPrimary: Color(red: 0.10, green: 0.12, blue: 0.15),
        textMuted: Color(red: 0.55, green: 0.59, blue: 0.64),
        shadow: Color.black.opacity(0.05)
    )
    
    static let dark = YearlyPaletteValues(
        primary: Color(red: 0.11, green: 0.45, blue: 0.93),
        background: Color(red: 0.06, green: 0.09, blue: 0.13),
        surface: Color(red: 0.11, green: 0.14, blue: 0.19),
        border: Color(red: 0.12, green: 0.16, blue: 0.23),
        chartBase: Color.white.opacity(0.06),
        chartEmpty: Color.white.opacity(0.06),
        textPrimary: Color.white,
        textMuted: Color(red: 0.58, green: 0.64, blue: 0.72),
        shadow: Color.clear
    )
    
    static func palette(isLight: Bool) -> YearlyPaletteValues {
        isLight ? .light : .dark
    }
}

// MARK: - Light Palette (for direct access)

private enum YearlyLightPalette {
    static let primary = Color(red: 0.11, green: 0.45, blue: 0.93)
    static let background = Color(red: 0.95, green: 0.96, blue: 0.97)
    static let surface = Color.white
    static let border = Color(red: 0.94, green: 0.95, blue: 0.96)
    static let chartBase = Color(red: 0.93, green: 0.94, blue: 0.96)
    static let textPrimary = Color(red: 0.10, green: 0.12, blue: 0.15)
    static let textMuted = Color(red: 0.55, green: 0.59, blue: 0.64)
    static let shadow = Color.black.opacity(0.05)
    static let chartEmpty = Color(red: 0.93, green: 0.94, blue: 0.96)
}

// MARK: - Dark Palette (for direct access)

private enum YearlyDarkPalette {
    static let primary = Color(red: 0.11, green: 0.45, blue: 0.93)
    static let background = Color(red: 0.06, green: 0.09, blue: 0.13)
    static let surface = Color(red: 0.11, green: 0.14, blue: 0.19)
    static let surfaceHighlight = Color(red: 0.16, green: 0.20, blue: 0.27)
    static let border = Color(red: 0.12, green: 0.16, blue: 0.23)
    static let textPrimary = Color.white
    static let textMuted = Color(red: 0.58, green: 0.64, blue: 0.72)
    static let chartEmpty = Color.white.opacity(0.06)
    static let shadow = Color.clear
    static let chartBase = Color.white.opacity(0.06)
}

// MARK: - MonthlyCost Extension

extension MonthlyCost {
    var fullMonthLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}
