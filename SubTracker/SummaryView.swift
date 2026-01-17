import SwiftUI

struct SummaryView: View {
    @Binding var subscriptions: [Subscription]
    @Binding var selectedTab: AppTab
    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @AppStorage("reminderDays") private var reminderDays: Int = 3
    @AppStorage("monthlyBudgetEnabled") private var monthlyBudgetEnabled = false
    @AppStorage("monthlyBudgetAmount") private var monthlyBudgetAmount: Double = 0
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedPeriod: SummaryPeriod = .yearly
    @State private var isPresentingAdd = false
    @State private var cachedMonthlyBreakdown: [MonthlyCost] = []
    
    /// Subscription ID'sine göre binding döndürür
    private func binding(for id: UUID) -> Binding<Subscription>? {
        guard let index = subscriptions.firstIndex(where: { $0.id == id }) else { return nil }
        return $subscriptions[index]
    }
    
    /// Abonelik silme
    private func delete(_ id: UUID) {
        if let index = subscriptions.firstIndex(where: { $0.id == id }) {
            subscriptions.remove(at: index)
            Task { await NotificationScheduler.shared.cancel(for: id) }
        }
    }

    var body: some View {
        NavigationStack {
            if colorScheme == .light {
                lightBody
                    .toolbar(.hidden, for: .navigationBar)
            } else {
                darkBody
                    .toolbar(.hidden, for: .navigationBar)
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
        .onAppear {
            cachedMonthlyBreakdown = computeMonthlyBreakdown()
        }
        .onChange(of: subscriptions) { _, _ in
            cachedMonthlyBreakdown = computeMonthlyBreakdown()
        }
    }

    private var lightBody: some View {
        ScrollView {
            VStack(spacing: 18) {
                periodToggle
                totalExpenseCard
                if monthlyBudgetEnabled && monthlyBudgetAmount > 0 {
                    budgetStatusCard
                }
                statsGrid
                upcomingLightSection
                highestCostSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 92)
        }
        .scrollIndicators(.hidden)
        .background(SummaryLightPalette.background)
        .safeAreaInset(edge: .top, spacing: 0) {
            lightHeader
        }
        .overlay(alignment: .bottomTrailing) {
            addButton
        }
    }

    private var legacyBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                totalCards
                analyticsSection
                upcomingSection
            }
            .padding()
        }
        .navigationTitle("Özet")
    }

    private var darkBody: some View {
        ScrollView {
            VStack(spacing: 18) {
                darkPeriodToggle
                darkTotalExpenseCard
                if monthlyBudgetEnabled && monthlyBudgetAmount > 0 {
                    darkBudgetStatusCard
                }
                darkStatsGrid
                darkUpcomingSection
                darkHighestCostSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 92)
        }
        .scrollIndicators(.hidden)
        .background(SummaryDarkPalette.background)
        .safeAreaInset(edge: .top, spacing: 0) {
            darkHeader
        }
        .overlay(alignment: .bottomTrailing) {
            darkAddButton
        }
    }

    private var lightHeader: some View {
        HStack {
            Text("Özet")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(SummaryLightPalette.textPrimary)
            Spacer()
            Button {
                selectedTab = .settings
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(SummaryLightPalette.textMuted)
                    .frame(width: 40, height: 40)
                    .background(SummaryLightPalette.segmentBackground, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Ayarlar")
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(SummaryLightPalette.background.opacity(0.96))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(SummaryLightPalette.border.opacity(0.6))
                .frame(height: 1)
        }
    }

    private var darkHeader: some View {
        HStack {
            Text("Özet")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(SummaryDarkPalette.textPrimary)
            Spacer()
            Button {
                selectedTab = .settings
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(SummaryDarkPalette.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(SummaryDarkPalette.surfaceHighlight, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Ayarlar")
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(SummaryDarkPalette.background.opacity(0.95))
    }

    private var periodToggle: some View {
        HStack(spacing: 4) {
            ForEach(SummaryPeriod.allCases) { period in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(selectedPeriod == period ? SummaryLightPalette.textPrimary : SummaryLightPalette.textMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(selectedPeriod == period ? SummaryLightPalette.surface : Color.clear)
                                .shadow(color: selectedPeriod == period ? SummaryLightPalette.shadow : .clear, radius: 3, x: 0, y: 1)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .frame(height: 44)
        .background(SummaryLightPalette.segmentBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var darkPeriodToggle: some View {
        HStack(spacing: 4) {
            ForEach(SummaryPeriod.allCases) { period in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(selectedPeriod == period ? SummaryDarkPalette.textPrimary : SummaryDarkPalette.textMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(selectedPeriod == period ? SummaryDarkPalette.surfaceHighlight : Color.clear)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .frame(height: 48)
        .background(SummaryDarkPalette.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var totalExpenseCard: some View {
        let totalValue = selectedPeriod == .yearly ? subscriptions.yearlyTotal : subscriptions.monthlyTotal
        let title = selectedPeriod == .yearly ? "Toplam Yıllık Gider" : "Toplam Aylık Gider"

        return NavigationLink {
            YearlyBreakdownView(breakdown: monthlyBreakdown, currencyCode: defaultCurrency, yearlyTotal: subscriptions.yearlyTotal, subscriptions: subscriptions)
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title.uppercased())
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(SummaryLightPalette.textMuted)
                        .tracking(0.6)
                    Text(formattedAmount(totalValue))
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(SummaryLightPalette.textPrimary)
                }

                SummaryLightBarChart(
                    values: monthlyBreakdown.map(\.total),
                    highlightedIndex: highlightedMonthIndex,
                    primary: SummaryLightPalette.primary,
                    base: SummaryLightPalette.chartBase,
                    highlightShadow: SummaryLightPalette.primary.opacity(0.25)
                )

                HStack {
                    ForEach(monthLabelIndices, id: \.self) { index in
                        Text(monthLabel(at: index).uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(labelHighlightColor(for: index))
                        if index != monthLabelIndices.last {
                            Spacer()
                        }
                    }
                }
            }
            .padding(20)
            .background(SummaryLightPalette.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(SummaryLightPalette.border, lineWidth: 1)
            )
            .shadow(color: SummaryLightPalette.shadow, radius: 10, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var darkTotalExpenseCard: some View {
        let totalValue = selectedPeriod == .yearly ? subscriptions.yearlyTotal : subscriptions.monthlyTotal
        let title = selectedPeriod == .yearly ? "Toplam Yıllık Gider" : "Toplam Aylık Gider"

        return NavigationLink {
            YearlyBreakdownView(breakdown: monthlyBreakdown, currencyCode: defaultCurrency, yearlyTotal: subscriptions.yearlyTotal, subscriptions: subscriptions)
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(SummaryDarkPalette.textMuted)
                    Text(formattedAmount(totalValue))
                        .font(.system(size: 30, weight: .black))
                        .foregroundStyle(SummaryDarkPalette.textPrimary)
                }

                SummaryDarkBarChart(
                    values: monthlyBreakdown.map(\.total),
                    highlightedIndex: highlightedMonthIndex,
                    primary: SummaryDarkPalette.primary,
                    filledBase: SummaryDarkPalette.primary.opacity(0.2),
                    emptyBase: SummaryDarkPalette.chartEmpty,
                    highlightShadow: SummaryDarkPalette.primary.opacity(0.35)
                )

                HStack {
                    ForEach(monthLabelIndices, id: \.self) { index in
                        Text(monthLabel(at: index).uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(labelHighlightColorDark(for: index))
                        if index != monthLabelIndices.last {
                            Spacer()
                        }
                    }
                }
            }
            .padding(18)
            .background(SummaryDarkPalette.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(SummaryDarkPalette.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Budget Status Cards
    
    /// Tüm aboneliklerin varsayılan para birimine çevrilmiş aylık toplamı
    private var convertedMonthlyTotal: Double {
        subscriptions.convertedMonthlyTotal(to: defaultCurrency)
    }
    
    private var budgetUsagePercent: Double {
        guard monthlyBudgetAmount > 0 else { return 0 }
        return min(convertedMonthlyTotal / monthlyBudgetAmount, 1.5)
    }
    
    private var budgetRemaining: Double {
        max(0, monthlyBudgetAmount - convertedMonthlyTotal)
    }
    
    private var isOverBudget: Bool {
        convertedMonthlyTotal > monthlyBudgetAmount
    }
    
    private var budgetStatusCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isOverBudget ? SummaryLightPalette.negative.opacity(0.12) : SummaryLightPalette.positive.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: isOverBudget ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(isOverBudget ? SummaryLightPalette.negative : SummaryLightPalette.positive)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(isOverBudget ? "Bütçe Aşıldı!" : "Bütçe Durumu")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(SummaryLightPalette.textPrimary)
                    Text(isOverBudget ? "Limitin \(formattedAmount(convertedMonthlyTotal - monthlyBudgetAmount)) üzerinde" : "\(formattedAmount(budgetRemaining)) kaldı")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(SummaryLightPalette.textMuted)
                }
                
                Spacer()
                
                Text(String(format: "%.0f%%", min(budgetUsagePercent * 100, 150)))
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(isOverBudget ? SummaryLightPalette.negative : SummaryLightPalette.primary)
            }
            
            // Progress bar
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(SummaryLightPalette.chartBase)
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: isOverBudget 
                                    ? [SummaryLightPalette.negative.opacity(0.8), SummaryLightPalette.negative]
                                    : [SummaryLightPalette.positive.opacity(0.8), SummaryLightPalette.positive],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: min(budgetUsagePercent, 1.0) * proxy.size.width, height: 10)
                }
            }
            .frame(height: 10)
            
            HStack {
                Text("\(formattedAmount(convertedMonthlyTotal))")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(SummaryLightPalette.textMuted)
                Spacer()
                Text("/ \(formattedAmount(monthlyBudgetAmount))")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(SummaryLightPalette.textMuted)
            }
        }
        .padding(16)
        .background(SummaryLightPalette.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isOverBudget ? SummaryLightPalette.negative.opacity(0.3) : SummaryLightPalette.border, lineWidth: 1)
        )
        .shadow(color: SummaryLightPalette.shadow, radius: 8, x: 0, y: 2)
    }
    
    private var darkBudgetStatusCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isOverBudget ? SummaryDarkPalette.negative.opacity(0.2) : SummaryDarkPalette.positive.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: isOverBudget ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(isOverBudget ? SummaryDarkPalette.negative : SummaryDarkPalette.positive)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(isOverBudget ? "Bütçe Aşıldı!" : "Bütçe Durumu")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(SummaryDarkPalette.textPrimary)
                    Text(isOverBudget ? "Limitin \(formattedAmount(convertedMonthlyTotal - monthlyBudgetAmount)) üzerinde" : "\(formattedAmount(budgetRemaining)) kaldı")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(SummaryDarkPalette.textMuted)
                }
                
                Spacer()
                
                Text(String(format: "%.0f%%", min(budgetUsagePercent * 100, 150)))
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(isOverBudget ? SummaryDarkPalette.negative : SummaryDarkPalette.primary)
            }
            
            // Progress bar
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(SummaryDarkPalette.chartEmpty)
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: isOverBudget 
                                    ? [SummaryDarkPalette.negative.opacity(0.8), SummaryDarkPalette.negative]
                                    : [SummaryDarkPalette.positive.opacity(0.8), SummaryDarkPalette.positive],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: min(budgetUsagePercent, 1.0) * proxy.size.width, height: 10)
                }
            }
            .frame(height: 10)
            
            HStack {
                Text("\(formattedAmount(convertedMonthlyTotal))")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(SummaryDarkPalette.textMuted)
                Spacer()
                Text("/ \(formattedAmount(monthlyBudgetAmount))")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(SummaryDarkPalette.textMuted)
            }
        }
        .padding(16)
        .background(SummaryDarkPalette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isOverBudget ? SummaryDarkPalette.negative.opacity(0.3) : SummaryDarkPalette.border, lineWidth: 1)
        )
    }

    private var statsGrid: some View {
        HStack(spacing: 12) {
            SummaryLightStatCard(
                title: "Trend",
                value: trendValueText,
                subtitle: "gelecek aya göre",
                iconName: "chart.line.uptrend.xyaxis",
                accent: trendAccent
            )

            SummaryLightStatCard(
                title: "Ortalama Tutar",
                value: formattedAmount(averageMonthlyCost),
                subtitle: "abonelik başına",
                iconName: "chart.pie.fill",
                accent: SummaryLightPalette.primary
            )
        }
    }

    private var darkStatsGrid: some View {
        HStack(spacing: 12) {
            SummaryDarkStatCard(
                title: "Trend",
                value: trendValueText,
                subtitle: "gelecek aya göre",
                iconName: "chart.line.uptrend.xyaxis",
                accent: trendAccent
            )

            SummaryDarkStatCard(
                title: "Ortalama Tutar",
                value: formattedAmount(averageMonthlyCost),
                subtitle: "abonelik başına",
                iconName: "chart.pie.fill",
                accent: SummaryDarkPalette.primary
            )
        }
    }

    private var upcomingLightSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Yakın Yenilemeler")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(SummaryLightPalette.textPrimary)
                Spacer()
                if !subscriptions.upcoming.isEmpty {
                    NavigationLink {
                        UpcomingRenewalsView(subscriptions: subscriptions.upcoming)
                    } label: {
                        Text("Tümünü Gör")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(SummaryLightPalette.primary)
                    }
                    .buttonStyle(.plain)
                }
            }

            if subscriptions.upcoming.isEmpty {
                Text("Önümüzdeki 14 gün içinde yenileme yok.")
                    .font(.subheadline)
                    .foregroundStyle(SummaryLightPalette.textMuted)
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(subscriptions.upcoming) { subscription in
                            if let subBinding = binding(for: subscription.id) {
                                NavigationLink {
                                    SubscriptionDetailView(subscription: subBinding, onSave: { updated in
                                        Task {
                                            await NotificationScheduler.shared.reschedule(subscription: updated, reminderDays: reminderDays)
                                        }
                                    }) {
                                        delete(subscription.id)
                                    }
                                } label: {
                                    SummaryUpcomingCard(
                                        subscription: subscription,
                                        badge: dueBadge(for: subscription)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.bottom, 6)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private var darkUpcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Yakın Yenilemeler")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(SummaryDarkPalette.textPrimary)
                Spacer()
                if !subscriptions.upcoming.isEmpty {
                    NavigationLink {
                        UpcomingRenewalsView(subscriptions: subscriptions.upcoming)
                    } label: {
                        Text("Tümünü Gör")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(SummaryDarkPalette.primary)
                    }
                    .buttonStyle(.plain)
                }
            }

            if subscriptions.upcoming.isEmpty {
                Text("Önümüzdeki 14 gün içinde yenileme yok.")
                    .font(.subheadline)
                    .foregroundStyle(SummaryDarkPalette.textMuted)
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(subscriptions.upcoming) { subscription in
                            if let subBinding = binding(for: subscription.id) {
                                NavigationLink {
                                    SubscriptionDetailView(subscription: subBinding, onSave: { updated in
                                        Task {
                                            await NotificationScheduler.shared.reschedule(subscription: updated, reminderDays: reminderDays)
                                        }
                                    }) {
                                        delete(subscription.id)
                                    }
                                } label: {
                                    SummaryDarkUpcomingCard(
                                        subscription: subscription,
                                        badge: dueBadgeDark(for: subscription)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.bottom, 6)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private var highestCostSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("En Yüksek Tutar")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(SummaryLightPalette.textPrimary)

            if topFive.isEmpty {
                Text("Henüz abonelik yok.")
                    .font(.subheadline)
                    .foregroundStyle(SummaryLightPalette.textMuted)
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 10) {
                    ForEach(topFive) { subscription in
                        if let subBinding = binding(for: subscription.id) {
                            NavigationLink {
                                SubscriptionDetailView(subscription: subBinding, onSave: { updated in
                                    Task {
                                        await NotificationScheduler.shared.reschedule(subscription: updated, reminderDays: reminderDays)
                                    }
                                }) {
                                    delete(subscription.id)
                                }
                            } label: {
                                SummaryHighestCostRow(
                                    subscription: subscription,
                                    monthlyAmount: formattedAmount(subscription.monthlyCost, currencyCode: subscription.currency)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var darkHighestCostSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("En Yüksek Tutar")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(SummaryDarkPalette.textPrimary)

            if topFive.isEmpty {
                Text("Henüz abonelik yok.")
                    .font(.subheadline)
                    .foregroundStyle(SummaryDarkPalette.textMuted)
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 10) {
                    ForEach(topFive) { subscription in
                        if let subBinding = binding(for: subscription.id) {
                            NavigationLink {
                                SubscriptionDetailView(subscription: subBinding, onSave: { updated in
                                    Task {
                                        await NotificationScheduler.shared.reschedule(subscription: updated, reminderDays: reminderDays)
                                    }
                                }) {
                                    delete(subscription.id)
                                }
                            } label: {
                                SummaryDarkHighestCostRow(
                                    subscription: subscription,
                                    monthlyAmount: formattedAmount(subscription.monthlyCost, currencyCode: subscription.currency)
                                )
                            }
                            .buttonStyle(.plain)
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
                .background(SummaryLightPalette.primary, in: Circle())
                .shadow(color: SummaryLightPalette.primary.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 24)
        .accessibilityLabel("Yeni abonelik ekle")
    }

    private var darkAddButton: some View {
        Button {
            isPresentingAdd = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 56, height: 56)
                .background(SummaryDarkPalette.primary, in: Circle())
                .shadow(color: SummaryDarkPalette.primary.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 24)
        .accessibilityLabel("Yeni abonelik ekle")
    }

    private var totalCards: some View {
        let monthly = subscriptions.monthlyTotal
        let yearly = monthlyBreakdown.reduce(0) { $0 + $1.total }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = defaultCurrency

        return HStack(spacing: 12) {
            SummaryCard(title: "Aylık", value: formatter.string(from: monthly as NSNumber) ?? "-", color: .blue)
            NavigationLink {
                YearlyBreakdownView(breakdown: monthlyBreakdown, currencyCode: defaultCurrency, yearlyTotal: yearly, subscriptions: subscriptions)
            } label: {
                SummaryCard(title: "Yıllık", value: formatter.string(from: yearly as NSNumber) ?? "-", color: .purple)
            }
            .buttonStyle(.plain)
        }
    }

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Yakın Yenilemeler")
                .font(.headline)
            if subscriptions.upcoming.isEmpty {
                Text("Önümüzdeki 14 gün içinde yenileme yok.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(subscriptions.upcoming) { subscription in
                    SubscriptionRow(subscription: subscription, highlight: "")
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    private var analyticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analitik")
                .font(.headline)

            HStack(spacing: 12) {
                AnalyticsCard(title: "Son 30 gün", value: formattedAmount(next30Total), color: .teal)
                AnalyticsCard(title: "Son 90 gün", value: formattedAmount(next90Total), color: .indigo)
            }

            HStack(spacing: 12) {
                AnalyticsCard(title: "İptal tasarrufu (aylık)", value: formattedAmount(canceledSavingsMonthly), color: .green)
                AnalyticsCard(title: "Aktif abonelik", value: "\(activeCount)", color: .orange)
            }

            if !topFive.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("En pahalı 5")
                        .font(.subheadline.bold())
                    ForEach(topFive) { subscription in
                        HStack {
                            Text(subscription.name)
                                .font(.body)
                            Spacer()
                            Text(formattedAmount(subscription.monthlyCost))
                                .font(.body.bold())
                        }
                        .padding(.vertical, 4)
                        Divider()
                    }
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var monthlyBreakdown: [MonthlyCost] {
        cachedMonthlyBreakdown.isEmpty ? computeMonthlyBreakdown() : cachedMonthlyBreakdown
    }
    
    private func computeMonthlyBreakdown() -> [MonthlyCost] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
        let horizon = calendar.date(byAdding: .month, value: 12, to: startOfMonth) ?? startOfMonth
        var buckets: [String: MonthlyCost] = [:]

        for subscription in subscriptions {
            let stepMonths = subscription.cycle == .monthly ? 1 : 12
            // upcomingRenewalDate zaten güncel bir sonraki tarihi hesaplıyor
            var next = subscription.upcomingRenewalDate

            // ileriye sar: ilk tarih görünür aralıktan küçükse, ileri taşı
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

    private var topFive: [Subscription] {
        subscriptions.filter { $0.isActive }.sorted { $0.monthlyCost > $1.monthlyCost }.prefix(5).map { $0 }
    }

    private var next30Total: Double {
        let horizon = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        return subscriptions.reduce(0) { acc, sub in
            guard sub.isActive, sub.upcomingRenewalDate <= horizon else { return acc }
            return acc + sub.amountForCycle
        }
    }

    private var next90Total: Double {
        let horizon = Calendar.current.date(byAdding: .day, value: 90, to: Date()) ?? Date()
        return subscriptions.reduce(0) { acc, sub in
            guard sub.isActive, sub.upcomingRenewalDate <= horizon else { return acc }
            return acc + sub.amountForCycle
        }
    }

    private var canceledSavingsMonthly: Double {
        let now = Date()
        return subscriptions
            .filter { ($0.endDate ?? now) < now }
            .reduce(0) { $0 + $1.monthlyCost }
    }

    private var activeCount: Int {
        subscriptions.filter { $0.isActive }.count
    }

    private func formattedAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = defaultCurrency
        return formatter.string(from: value as NSNumber) ?? "\(value)"
    }

    private func formattedAmount(_ value: Double, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: value as NSNumber) ?? "\(value)"
    }

    private var averageMonthlyCost: Double {
        guard activeCount > 0 else { return 0 }
        return subscriptions.monthlyTotal / Double(activeCount)
    }

    private var trendPercent: Double? {
        guard monthlyBreakdown.count >= 2 else { return nil }
        let current = monthlyBreakdown[0].total
        let next = monthlyBreakdown[1].total
        guard next != 0 else { return nil }
        return ((current - next) / next) * 100
    }

    private var trendValueText: String {
        guard let trendPercent else { return "—" }
        return String(format: "%+.0f%%", trendPercent)
    }

    private var trendAccent: Color {
        guard let trendPercent else { return SummaryLightPalette.primary }
        return trendPercent >= 0 ? SummaryLightPalette.positive : SummaryLightPalette.negative
    }

    private var highlightedMonthIndex: Int {
        let totals = monthlyBreakdown.map(\.total)
        guard let maxValue = totals.max(),
              maxValue > 0,
              let index = totals.firstIndex(of: maxValue) else {
            return 0
        }
        return index
    }

    private var monthLabelIndices: [Int] {
        [0, 3, 7, 11].filter { $0 < monthlyBreakdown.count }
    }

    private func monthLabel(at index: Int) -> String {
        guard monthlyBreakdown.indices.contains(index) else { return "" }
        return monthlyBreakdown[index].monthLabel
    }

    private func labelHighlightColor(for index: Int) -> Color {
        index == highlightedMonthIndex ? SummaryLightPalette.primary : SummaryLightPalette.textMuted
    }

    private func dueBadge(for subscription: Subscription) -> SummaryUpcomingCard.Badge {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: subscription.upcomingRenewalDate).day ?? 0
        if days <= 0 {
            return .init(text: "Bugün", textColor: SummaryLightPalette.negative, background: SummaryLightPalette.negative.opacity(0.12))
        } else if days == 1 {
            return .init(text: "Yarın", textColor: SummaryLightPalette.negative, background: SummaryLightPalette.negative.opacity(0.12))
        } else {
            return .init(text: "\(days)g", textColor: SummaryLightPalette.textMuted, background: SummaryLightPalette.segmentBackground)
        }
    }

    private func labelHighlightColorDark(for index: Int) -> Color {
        index == highlightedMonthIndex ? SummaryDarkPalette.primary : SummaryDarkPalette.textMuted
    }

    private func dueBadgeDark(for subscription: Subscription) -> SummaryDarkUpcomingCard.Badge {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: subscription.upcomingRenewalDate).day ?? 0
        if days <= 0 {
            return .init(text: "Bugün", textColor: SummaryDarkPalette.negative, background: SummaryDarkPalette.negative.opacity(0.2))
        } else if days == 1 {
            return .init(text: "Yarın", textColor: SummaryDarkPalette.negative, background: SummaryDarkPalette.negative.opacity(0.2))
        } else {
            return .init(text: "\(days)g", textColor: SummaryDarkPalette.textMuted, background: SummaryDarkPalette.surfaceHighlight)
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
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.16), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold())
        }
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private enum SummaryPeriod: String, CaseIterable, Identifiable {
    case monthly
    case yearly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .monthly: return "Aylık"
        case .yearly: return "Yıllık"
        }
    }
}

private enum SummaryLightPalette {
    static let primary = Color(red: 0.11, green: 0.45, blue: 0.93)
    static let background = Color(red: 0.95, green: 0.96, blue: 0.97)
    static let surface = Color.white
    static let border = Color(red: 0.94, green: 0.95, blue: 0.96)
    static let segmentBackground = Color(red: 0.89, green: 0.91, blue: 0.93)
    static let chartBase = Color(red: 0.95, green: 0.96, blue: 0.98)
    static let textPrimary = Color(red: 0.10, green: 0.12, blue: 0.15)
    static let textMuted = Color(red: 0.55, green: 0.59, blue: 0.64)
    static let shadow = Color.black.opacity(0.05)
    static let positive = Color(red: 0.12, green: 0.65, blue: 0.35)
    static let negative = Color(red: 0.90, green: 0.29, blue: 0.25)
}

private enum SummaryDarkPalette {
    static let primary = Color(red: 0.11, green: 0.45, blue: 0.93)
    static let background = Color(red: 0.06, green: 0.09, blue: 0.13)
    static let surface = Color(red: 0.11, green: 0.14, blue: 0.19)
    static let surfaceHighlight = Color(red: 0.16, green: 0.20, blue: 0.27)
    static let border = Color(red: 0.12, green: 0.16, blue: 0.23)
    static let textPrimary = Color.white
    static let textMuted = Color(red: 0.58, green: 0.64, blue: 0.72)
    static let chartEmpty = Color.white.opacity(0.06)
    static let positive = Color(red: 0.15, green: 0.75, blue: 0.43)
    static let negative = Color(red: 0.95, green: 0.35, blue: 0.30)
}

private struct SummaryLightBarChart: View {
    let values: [Double]
    let highlightedIndex: Int
    let primary: Color
    let base: Color
    let highlightShadow: Color

    var body: some View {
        GeometryReader { proxy in
            let maxValue = values.max() ?? 0
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(values.indices, id: \.self) { index in
                    let ratio = maxValue > 0 ? values[index] / maxValue : 0
                    let barHeight = ratio > 0 ? max(8, ratio * proxy.size.height) : 4
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(base)
                        if ratio > 0 {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(primary.opacity(index == highlightedIndex ? 1 : 0.8))
                                .frame(height: barHeight)
                                .shadow(color: index == highlightedIndex ? highlightShadow : .clear, radius: 10, x: 0, y: 6)
                        }
                    }
                    .frame(height: barHeight)
                }
            }
        }
        .frame(height: 130)
    }
}

private struct SummaryDarkBarChart: View {
    let values: [Double]
    let highlightedIndex: Int
    let primary: Color
    let filledBase: Color
    let emptyBase: Color
    let highlightShadow: Color

    var body: some View {
        GeometryReader { proxy in
            let maxValue = values.max() ?? 0
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(values.indices, id: \.self) { index in
                    let ratio = maxValue > 0 ? values[index] / maxValue : 0
                    let barHeight = ratio > 0 ? max(8, ratio * proxy.size.height) : 4
                    let baseColor = values[index] > 0 ? filledBase : emptyBase
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(baseColor)
                        if ratio > 0 {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(primary.opacity(index == highlightedIndex ? 1 : 0.85))
                                .frame(height: barHeight)
                                .shadow(color: index == highlightedIndex ? highlightShadow : .clear, radius: 10, x: 0, y: 6)
                        }
                    }
                    .frame(height: barHeight)
                }
            }
        }
        .frame(height: 130)
    }
}

private struct SummaryLightStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let iconName: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(accent)
                    .frame(width: 28, height: 28)
                    .background(accent.opacity(0.12), in: Circle())
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(SummaryLightPalette.textMuted)
                    .tracking(0.6)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(SummaryLightPalette.textPrimary)
                Text(subtitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(SummaryLightPalette.textMuted)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .padding(16)
        .background(SummaryLightPalette.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(SummaryLightPalette.border, lineWidth: 1)
        )
        .shadow(color: SummaryLightPalette.shadow, radius: 8, x: 0, y: 2)
    }
}

private struct SummaryDarkStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let iconName: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(accent)
                    .frame(width: 28, height: 28)
                    .background(accent.opacity(0.12), in: Circle())
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(SummaryDarkPalette.textMuted)
                    .tracking(0.6)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(SummaryDarkPalette.textPrimary)
                Text(subtitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(SummaryDarkPalette.textMuted)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .padding(16)
        .background(SummaryDarkPalette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(SummaryDarkPalette.border, lineWidth: 1)
        )
    }
}

private struct SummaryUpcomingCard: View {
    struct Badge {
        let text: String
        let textColor: Color
        let background: Color
    }

    let subscription: Subscription
    let badge: Badge

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: subscription.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 40)
                    .background(subscription.category.color, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                Spacer()
                Text(badge.text)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(badge.textColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badge.background, in: Capsule())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(SummaryLightPalette.textPrimary)
                Text(subscription.formattedAmount)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(SummaryLightPalette.textMuted)
            }
        }
        .padding(14)
        .frame(width: 144, height: 132, alignment: .leading)
        .background(SummaryLightPalette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(SummaryLightPalette.border, lineWidth: 1)
        )
        .shadow(color: SummaryLightPalette.shadow, radius: 6, x: 0, y: 2)
    }
}

private struct SummaryDarkUpcomingCard: View {
    struct Badge {
        let text: String
        let textColor: Color
        let background: Color
    }

    let subscription: Subscription
    let badge: Badge

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: subscription.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 40)
                    .background(subscription.category.color, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                Spacer()
                Text(badge.text)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(badge.textColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badge.background, in: Capsule())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(SummaryDarkPalette.textPrimary)
                Text(subscription.formattedAmount)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(SummaryDarkPalette.textMuted)
            }
        }
        .padding(14)
        .frame(width: 156, height: 132, alignment: .leading)
        .background(SummaryDarkPalette.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(SummaryDarkPalette.border, lineWidth: 1)
        )
    }
}

private struct SummaryHighestCostRow: View {
    let subscription: Subscription
    let monthlyAmount: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: subscription.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 48, height: 48)
                .background(subscription.category.color, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(SummaryLightPalette.textPrimary)
                Text(subscription.cycle == .yearly ? "Yıllık" : "Aylık")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(SummaryLightPalette.textMuted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(monthlyAmount)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(SummaryLightPalette.textPrimary)
                Text("/ay")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(SummaryLightPalette.textMuted)
            }
        }
        .padding(12)
        .background(SummaryLightPalette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(SummaryLightPalette.border, lineWidth: 1)
        )
        .shadow(color: SummaryLightPalette.shadow, radius: 6, x: 0, y: 2)
    }
}

private struct SummaryDarkHighestCostRow: View {
    let subscription: Subscription
    let monthlyAmount: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: subscription.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 48, height: 48)
                .background(subscription.category.color, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(SummaryDarkPalette.textPrimary)
                Text(subscription.cycle == .yearly ? "Yıllık" : "Aylık")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(SummaryDarkPalette.textMuted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(monthlyAmount)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(SummaryDarkPalette.textPrimary)
                Text("/ay")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(SummaryDarkPalette.textMuted)
            }
        }
        .padding(12)
        .background(SummaryDarkPalette.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(SummaryDarkPalette.border, lineWidth: 1)
        )
    }
}

private struct UpcomingRenewalsView: View {
    let subscriptions: [Subscription]

    var body: some View {
        List {
            if subscriptions.isEmpty {
                Text("Önümüzdeki 14 gün içinde yenileme yok.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(subscriptions) { subscription in
                    SubscriptionRow(subscription: subscription, highlight: "")
                }
            }
        }
        .navigationTitle("Yakın Yenilemeler")
        .toolbar(.visible, for: .navigationBar)
    }
}

private func monthKey(for date: Date, calendar: Calendar) -> String {
    let components = calendar.dateComponents([.year, .month], from: date)
    return "\(components.year ?? 0)-\(components.month ?? 0)"
}

private func monthDate(for date: Date, calendar: Calendar) -> Date {
    calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
}
