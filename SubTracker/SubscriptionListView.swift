import SwiftUI

struct SubscriptionListView: View {
    @Binding var subscriptions: [Subscription]
    /// Spotlight'tan seçilen abonelik ID'si
    @Binding var spotlightSelectedID: UUID?
    @State private var searchText = ""
    @State private var isPresentingAdd = false
    @State private var editingSubscriptionID: UUID?
    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @AppStorage("reminderDays") private var reminderDays: Int = 3
    @State private var categoryFilter: Subscription.Category?
    @State private var sortOption: SortOption = .nearestRenewal
    @State private var selectedChip: SubscriptionChip = .all
    @Environment(\.colorScheme) private var colorScheme
    
    /// Spotlight'tan açılan abonelik detayı için navigation path
    @State private var spotlightNavigationID: UUID?

    private var palette: SubscriptionListPalette {
        SubscriptionListPalette(scheme: colorScheme)
    }
    
    init(subscriptions: Binding<[Subscription]>, spotlightSelectedID: Binding<UUID?> = .constant(nil)) {
        _subscriptions = subscriptions
        _spotlightSelectedID = spotlightSelectedID
    }

    var filtered: [Subscription] {
        var result = subscriptions

        if selectedChip == .inactive {
            result = result.filter { !$0.isActive }
        } else {
            result = result.filter { $0.isActive }
        }

        if selectedChip == .monthly {
            result = result.filter { $0.cycle == .monthly }
        }

        if selectedChip == .yearly {
            result = result.filter { $0.cycle == .yearly }
        }

        if let categoryFilter {
            result = result.filter { $0.category == categoryFilter }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { $0.name.lowercased().contains(query) }
        }

        switch sortOption {
        case .nearestRenewal:
            result = result.sorted { $0.upcomingRenewalDate < $1.upcomingRenewalDate }
        case .highestCost:
            result = result.sorted { $0.monthlyCost > $1.monthlyCost }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    searchSection
                    chipSection
                    listSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 92)
            }
            .scrollIndicators(.hidden)
            .background(palette.background)
            .safeAreaInset(edge: .top, spacing: 0) {
                header
            }
            .overlay(alignment: .bottomTrailing) {
                addButton
            }
            .navigationDestination(item: $spotlightNavigationID) { id in
                if let binding = binding(for: id) {
                    SubscriptionDetailView(subscription: binding, onSave: { updated in
                        Task {
                            await NotificationScheduler.shared.reschedule(subscription: updated, reminderDays: reminderDays)
                        }
                    }) {
                        delete(id)
                        spotlightNavigationID = nil
                    }
                } else {
                    Text("Abonelik bulunamadı")
                }
            }
        }
        .sheet(isPresented: $isPresentingAdd) {
            NewSubscriptionSheet(defaultCurrency: defaultCurrency) { newSubscription in
                subscriptions.append(newSubscription)
                Task {
                    await NotificationScheduler.shared.schedule(subscription: newSubscription, reminderDays: reminderDays)
                }
            }
        }
        .sheet(item: $editingSubscriptionID) { id in
            if let binding = binding(for: id) {
                NavigationStack {
                    SubscriptionDetailView(subscription: binding, onSave: { updated in
                        Task {
                            await NotificationScheduler.shared.reschedule(subscription: updated, reminderDays: reminderDays)
                        }
                    }) {
                        delete(id)
                        editingSubscriptionID = nil
                    }
                }
            }
        }
        // Spotlight'tan gelen seçimi işle
        .onChange(of: spotlightSelectedID) { _, newID in
            guard let id = newID else { return }
            // Eğer abonelik mevcutsa detay sayfasını aç
            if subscriptions.contains(where: { $0.id == id }) {
                spotlightNavigationID = id
            }
            // ID'yi temizle (tekrar kullanılabilir olması için)
            spotlightSelectedID = nil
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Abonelikler")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(palette.textPrimary)
                Spacer()
                Menu {
                    Section("Kategori") {
                        Button("Hepsi") { categoryFilter = nil }
                        ForEach(Subscription.Category.allCases) { category in
                            Button(category.displayName) { categoryFilter = category }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(palette.textPrimary)
                        .frame(width: 40, height: 40)
                        .background(palette.iconButtonBackground, in: Circle())
                }
                .accessibilityLabel("Filtre menüsü")
            }

            summaryCard
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(palette.headerBackground.opacity(0.96))
    }

    private var summaryCard: some View {
        let total = subscriptions.monthlyTotal
        let trendText = formattedTrendText
        let trendValue = trendPercentValue
        let trendColor = trendValue ?? 0 >= 0 ? palette.positive : palette.negative

        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Toplam Aylık")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(palette.summaryTextSecondary)
                    .textCase(.uppercase)
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    Text(formattedAmount(total))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(palette.summaryTextPrimary)
                    if let trendValue {
                        HStack(spacing: 4) {
                            Image(systemName: trendValue >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 12, weight: .bold))
                            Text(trendText)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(trendColor)
                    } else {
                        Text(trendText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(palette.summaryTextSecondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chart.pie.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(palette.primary)
                .frame(width: 48, height: 48)
                .background(palette.primary.opacity(colorScheme == .dark ? 0.2 : 0.1), in: Circle())
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: palette.summaryGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(palette.summaryBorder, lineWidth: 1)
        )
        .shadow(color: palette.summaryShadow, radius: 10, x: 0, y: 4)
    }

    private var searchSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(palette.textSecondary)
            TextField("Abonelik ara...", text: $searchText)
                .textInputAutocapitalization(.words)
                .foregroundStyle(palette.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(palette.searchBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(palette.searchBorder, lineWidth: 1)
        )
    }

    private var chipSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(SubscriptionChip.allCases) { chip in
                    Button {
                        selectedChip = chip
                    } label: {
                        Text(chip.title)
                            .font(.system(size: 13, weight: chip == selectedChip ? .semibold : .medium))
                            .foregroundStyle(chip == selectedChip ? palette.chipActiveText : palette.chipInactiveText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(chip == selectedChip ? palette.chipActiveBackground : palette.chipInactiveBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(palette.chipInactiveBorder, lineWidth: chip == selectedChip ? 0 : 1)
                            )
                            .shadow(color: chip == selectedChip ? palette.chipShadow : .clear, radius: 6, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 2)
        }
    }

    private var listSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(sectionTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(palette.textSecondary)
                    .textCase(.uppercase)
                Spacer()
                Menu {
                    Button("Tarihe göre") { sortOption = .nearestRenewal }
                    Button("Tutar (aylık)") { sortOption = .highestCost }
                } label: {
                    Text("Sırala: \(sortOption.title)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(palette.textSecondary)
                }
                .buttonStyle(.plain)
            }

            if filtered.isEmpty {
                Text("Bu filtrelerde abonelik yok.")
                    .font(.subheadline)
                    .foregroundStyle(palette.textSecondary)
                    .padding(.vertical, 12)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filtered) { subscription in
                        NavigationLink {
                            if let binding = binding(for: subscription.id) {
                                SubscriptionDetailView(subscription: binding, onSave: { updated in
                                    Task {
                                        await NotificationScheduler.shared.reschedule(subscription: updated, reminderDays: reminderDays)
                                    }
                                }) {
                                    delete(subscription.id)
                                }
                            } else {
                                Text("Abonelik bulunamadı")
                            }
                        } label: {
                            SubscriptionListCard(
                                subscription: subscription,
                                palette: palette,
                                nextRenewalText: nextRenewalText(for: subscription)
                            )
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button("Düzenle") {
                                editingSubscriptionID = subscription.id
                            }
                            Button(role: .destructive) {
                                delete(subscription.id)
                            } label: {
                                Text("Sil")
                            }
                        }
                    }
                }
            }
        }
    }

    private var addButton: some View {
        Button {
            isPresentingAdd = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 56, height: 56)
                .background(palette.fabBackground, in: Circle())
                .shadow(color: palette.fabShadow, radius: 12, x: 0, y: 6)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 24)
        .accessibilityLabel("Yeni abonelik ekle")
    }

    private var sectionTitle: String {
        selectedChip == .inactive ? "Pasif Abonelikler" : "Aktif Abonelikler"
    }

    private var trendPercentValue: Double? {
        guard monthlyBreakdown.count >= 2 else { return nil }
        let current = monthlyBreakdown[0].total
        let next = monthlyBreakdown[1].total
        guard next != 0 else { return nil }
        return ((current - next) / next) * 100
    }

    private var formattedTrendText: String {
        guard let trendPercentValue else { return "—" }
        return String(format: "%+.1f%%", trendPercentValue)
    }

    private var monthlyBreakdown: [MonthlyCost] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
        let horizon = calendar.date(byAdding: .month, value: 12, to: startOfMonth) ?? startOfMonth
        var buckets: [String: MonthlyCost] = [:]

        for subscription in subscriptions {
            let stepMonths = subscription.cycle == .monthly ? 1 : 12
            // upcomingRenewalDate zaten güncel bir sonraki tarihi hesaplıyor
            var next = subscription.upcomingRenewalDate

            while next < startOfMonth {
                guard let advanced = calendar.date(byAdding: .month, value: stepMonths, to: next) else { break }
                next = advanced
            }

            while next <= horizon {
                if let end = subscription.endDate, next > end { break }
                let key = monthKey(for: next, calendar: calendar)
                let amount = subscription.amountForCycle
                if let existing = buckets[key] {
                    buckets[key] = MonthlyCost(date: existing.date, total: existing.total + amount)
                } else {
                    buckets[key] = MonthlyCost(date: monthDate(for: next, calendar: calendar), total: amount)
                }
                guard let newDate = calendar.date(byAdding: .month, value: stepMonths, to: next) else { break }
                next = newDate
            }
        }

        var filled: [MonthlyCost] = []
        for offset in 0..<12 {
            guard let monthDate = calendar.date(byAdding: .month, value: offset, to: startOfMonth) else { continue }
            let key = monthKey(for: monthDate, calendar: calendar)
            if let existing = buckets[key] {
                filled.append(existing)
            } else {
                filled.append(MonthlyCost(date: monthDate, total: 0))
            }
        }
        return filled
    }

    private func nextRenewalText(for subscription: Subscription) -> String {
        subscription.upcomingRenewalDate.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, locale: Locale(identifier: "tr_TR")))
    }

    private func formattedAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = defaultCurrency
        return formatter.string(from: value as NSNumber) ?? "\(value)"
    }

    private func delete(_ id: UUID) {
        if let index = subscriptions.firstIndex(where: { $0.id == id }) {
            subscriptions.remove(at: index)
            Task { await NotificationScheduler.shared.cancel(for: id) }
        }
    }

    private func binding(for id: UUID) -> Binding<Subscription>? {
        guard let index = subscriptions.firstIndex(where: { $0.id == id }) else { return nil }
        return $subscriptions[index]
    }

    enum SortOption {
        case nearestRenewal
        case highestCost

        var title: String {
            switch self {
            case .nearestRenewal: return "Tarih"
            case .highestCost: return "Tutar"
            }
        }
    }
}

private enum SubscriptionChip: String, CaseIterable, Identifiable {
    case all
    case monthly
    case yearly
    case inactive

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "Tümü"
        case .monthly: return "Aylık"
        case .yearly: return "Yıllık"
        case .inactive: return "Pasif"
        }
    }
}

private struct SubscriptionListCard: View {
    let subscription: Subscription
    let palette: SubscriptionListPalette
    let nextRenewalText: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: subscription.icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(width: 56, height: 56)
                .background(subscription.category.color, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(subscription.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(palette.textPrimary)
                HStack(spacing: 6) {
                    Text(subscription.cycle.title)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(badgeTextColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(badgeBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    Text("Sonraki: \(nextRenewalText)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(palette.textSecondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(subscription.formattedAmount)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(palette.textPrimary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(palette.textSecondary)
            }
        }
        .padding(16)
        .background(palette.cardBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(palette.cardBorder, lineWidth: 1)
        )
        .shadow(color: palette.cardShadow, radius: 8, x: 0, y: 2)
        .opacity(subscription.isActive ? 1 : 0.7)
    }

    private var badgeBackground: Color {
        subscription.cycle == .yearly ? palette.badgeYearlyBackground : palette.badgeMonthlyBackground
    }

    private var badgeTextColor: Color {
        subscription.cycle == .yearly ? palette.badgeYearlyText : palette.badgeMonthlyText
    }
}

private struct SubscriptionListPalette {
    let scheme: ColorScheme

    var primary: Color { Color(red: 0.11, green: 0.45, blue: 0.93) }
    var background: Color {
        scheme == .dark ? Color(red: 0.06, green: 0.09, blue: 0.13) : Color(red: 0.97, green: 0.97, blue: 0.97)
    }
    var headerBackground: Color { scheme == .dark ? background : Color.white }
    var textPrimary: Color { scheme == .dark ? Color.white : Color(red: 0.12, green: 0.14, blue: 0.18) }
    var textSecondary: Color { scheme == .dark ? Color(red: 0.62, green: 0.66, blue: 0.72) : Color(red: 0.55, green: 0.58, blue: 0.62) }
    var cardBackground: Color { scheme == .dark ? Color(red: 0.11, green: 0.14, blue: 0.18) : Color.white }
    var cardBorder: Color { scheme == .dark ? Color(red: 0.15, green: 0.19, blue: 0.26) : Color(red: 0.93, green: 0.94, blue: 0.95) }
    var cardShadow: Color { scheme == .dark ? Color.black.opacity(0.2) : Color.black.opacity(0.05) }
    var searchBackground: Color { scheme == .dark ? cardBackground : Color(red: 0.95, green: 0.95, blue: 0.96) }
    var searchBorder: Color { scheme == .dark ? cardBorder : Color.clear }
    var iconButtonBackground: Color { scheme == .dark ? Color(red: 0.14, green: 0.18, blue: 0.24) : Color(red: 0.95, green: 0.95, blue: 0.96) }
    var chipActiveBackground: Color { scheme == .dark ? primary : Color(red: 0.12, green: 0.14, blue: 0.18) }
    var chipActiveText: Color { Color.white }
    var chipInactiveBackground: Color { scheme == .dark ? cardBackground : Color.white }
    var chipInactiveText: Color { scheme == .dark ? Color(red: 0.74, green: 0.78, blue: 0.84) : Color(red: 0.45, green: 0.48, blue: 0.52) }
    var chipInactiveBorder: Color { scheme == .dark ? cardBorder : Color(red: 0.88, green: 0.89, blue: 0.9) }
    var chipShadow: Color { scheme == .dark ? primary.opacity(0.2) : Color.black.opacity(0.1) }
    var summaryGradient: [Color] {
        scheme == .dark
            ? [Color(red: 0.11, green: 0.14, blue: 0.18), Color(red: 0.07, green: 0.09, blue: 0.12)]
            : [Color(red: 0.12, green: 0.14, blue: 0.18), Color(red: 0.18, green: 0.2, blue: 0.24)]
    }
    var summaryTextPrimary: Color { Color.white }
    var summaryTextSecondary: Color { scheme == .dark ? textSecondary : Color.white.opacity(0.65) }
    var summaryBorder: Color { scheme == .dark ? cardBorder : Color.white.opacity(0.2) }
    var summaryShadow: Color { scheme == .dark ? Color.black.opacity(0.2) : Color.black.opacity(0.08) }
    var badgeMonthlyBackground: Color { scheme == .dark ? Color(red: 0.15, green: 0.18, blue: 0.24) : Color(red: 0.95, green: 0.95, blue: 0.96) }
    var badgeMonthlyText: Color { scheme == .dark ? Color(red: 0.7, green: 0.74, blue: 0.8) : Color(red: 0.45, green: 0.48, blue: 0.52) }
    var badgeYearlyBackground: Color { primary.opacity(scheme == .dark ? 0.2 : 0.12) }
    var badgeYearlyText: Color { primary }
    var fabBackground: Color { scheme == .dark ? primary : Color(red: 0.12, green: 0.14, blue: 0.18) }
    var fabShadow: Color { scheme == .dark ? primary.opacity(0.4) : Color.black.opacity(0.2) }
    var positive: Color { scheme == .dark ? Color(red: 0.2, green: 0.78, blue: 0.4) : Color(red: 0.12, green: 0.65, blue: 0.35) }
    var negative: Color { scheme == .dark ? Color(red: 0.95, green: 0.35, blue: 0.3) : Color(red: 0.9, green: 0.29, blue: 0.25) }
}

private func monthKey(for date: Date, calendar: Calendar) -> String {
    let components = calendar.dateComponents([.year, .month], from: date)
    return "\(components.year ?? 0)-\(components.month ?? 0)"
}

private func monthDate(for date: Date, calendar: Calendar) -> Date {
    calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
}
