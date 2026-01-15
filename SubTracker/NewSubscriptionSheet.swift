import SwiftUI

struct NewSubscriptionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var draft: NewSubscriptionData
    let defaultCurrency: String
    let onSave: (Subscription) -> Void
    @FocusState private var isNameFieldFocused: Bool
    @State private var remindMe: Bool = true

    private let suggestions: [(name: String, category: Subscription.Category)] = [
        // Video Streaming
        ("Netflix", .video),
        ("Amazon Prime Video", .video),
        ("Disney+", .video),
        ("HBO Max", .video),
        ("YouTube Premium", .video),
        ("iQIYI", .video),
        ("JioCinema", .video),
        ("Hulu", .video),
        ("Peacock", .video),
        ("Apple TV+", .video),
        ("Paramount+", .video),
        ("SonyLIV", .video),
        ("CuriosityStream", .video),
        ("U-Next", .video),
        ("ZEE5", .video),
        ("Shahid", .video),
        ("Eros Now", .video),
        // Sports
        ("ESPN+", .video),
        ("DAZN", .video),
        // Music / Audio
        ("Spotify Premium", .music),
        ("Tencent Music", .music),
        ("YouTube Music", .music),
        ("Apple Music", .music),
        ("Amazon Music Unlimited", .music),
        ("Tidal", .music),
        ("Deezer", .music),
        ("SiriusXM", .music),
        // Books / Audio
        ("Audible", .other),
        // Professional / Productivity / Software
        ("Notion", .productivity),
        ("Figma", .productivity),
        ("Adobe Creative Cloud", .productivity),
        ("Canva Pro", .productivity),
        ("Microsoft 365", .productivity),
        ("LinkedIn Premium", .productivity),
        ("Dropbox", .storage),
        ("Google One", .storage),
        // VPN
        ("NordVPN", .utilities),
        ("ExpressVPN", .utilities),
        // Education
        ("Duolingo Plus", .productivity),
        ("Coursera Plus", .productivity),
        ("MasterClass", .productivity),
        // Food / Wellness / Fitness
        ("HelloFresh", .other),
        ("Blue Apron", .other),
        ("Peloton", .other),
        ("Calm", .other),
        ("Headspace", .other),
        // News
        ("NYTimes Digital", .other),
        ("WSJ Digital", .other),
        // Gaming
        ("Xbox Game Pass", .other),
        ("PlayStation Plus", .other),
        ("Nintendo Switch Online", .other),
        // Live / Misc
        ("Twitch Subscriptions", .other)
    ]

    init(defaultCurrency: String, onSave: @escaping (Subscription) -> Void) {
        self.defaultCurrency = defaultCurrency
        self.onSave = onSave
        _draft = State(initialValue: NewSubscriptionData(currency: defaultCurrency))
    }

    private var palette: NewSubscriptionPalette {
        NewSubscriptionPalette(scheme: colorScheme)
    }

    var isValid: Bool {
        !draft.name.trimmingCharacters(in: .whitespaces).isEmpty && draft.normalizedAmountValue ?? 0 > 0
    }

    var body: some View {
        VStack(spacing: 0) {
            sheetHandle
            header
            ScrollView {
                VStack(spacing: 20) {
                    heroSection
                    amountCard
                    settingsCard
                    billingCycle
                    if draft.hasEndDate {
                        endDateCard
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
        }
        .background(palette.background)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            saveBar
        }
        .onAppear {
            remindMe = true
        }
    }

    private var sheetHandle: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(palette.handle)
                .frame(width: 40, height: 6)
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(palette.background)
    }

    private var header: some View {
        HStack {
            Button("Vazgeç") { dismiss() }
                .font(.system(size: 17))
                .foregroundStyle(palette.primary)

            Spacer()

            Text("Yeni Abonelik")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(palette.textPrimary)

            Spacer()

            Color.clear
                .frame(width: 50, height: 1)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .background(palette.background)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(palette.separator)
                .frame(height: 1)
        }
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(palette.surface)
                    .frame(width: 96, height: 96)
                    .overlay(
                        Circle()
                            .stroke(palette.separator, lineWidth: 1)
                    )
                    .shadow(color: palette.shadow, radius: 8, x: 0, y: 4)

                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 34))
                    .foregroundStyle(palette.textMuted)

                Circle()
                    .fill(palette.primary)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.white)
                    )
                    .overlay(
                        Circle()
                            .stroke(palette.background, lineWidth: 3)
                    )
                    .offset(x: 6, y: 6)
            }

            VStack(spacing: 6) {
                TextField("Abonelik Adı", text: $draft.name)
                    .font(.system(size: 22, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(palette.textPrimary)
                    .focused($isNameFieldFocused)
                    .textInputAutocapitalization(.words)

                Text("Netflix, Spotify, vb.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(palette.textMuted)
            }
            .padding(.horizontal, 12)

            if shouldShowSuggestions {
                VStack(spacing: 6) {
                    ForEach(filteredSuggestions, id: \.name) { suggestion in
                        Button {
                            draft.name = suggestion.name
                            draft.category = suggestion.category
                            isNameFieldFocused = false
                        } label: {
                            HStack {
                                Text(suggestion.name)
                                    .foregroundStyle(palette.textPrimary)
                                Spacer()
                                Text(suggestion.category.displayName)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(palette.textMuted)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(palette.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var amountCard: some View {
        VStack(spacing: 8) {
            Text("Ödeme Tutarı")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(palette.textMuted)
                .textCase(.uppercase)

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(currencySymbol)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(palette.textMuted)
                TextField("0,00", text: $draft.amount)
                    .font(.system(size: 40, weight: .bold))
                    .multilineTextAlignment(.center)
                    .keyboardType(.numbersAndPunctuation)
                    .foregroundStyle(palette.textPrimary)
                    .onChange(of: draft.amount, initial: false) { _, newValue in
                        draft.amount = sanitizeAmountInput(newValue)
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .padding(.horizontal, 16)
        .background(palette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: palette.shadow, radius: 8, x: 0, y: 4)
    }

    private var settingsCard: some View {
        VStack(spacing: 0) {
            rowDivider
            rowButton(
                icon: "square.grid.2x2",
                iconBackground: palette.iconCategoryBackground,
                iconColor: palette.iconCategory,
                title: "Kategori",
                value: draft.category.displayName
            ) {
                Menu {
                    ForEach(Subscription.Category.allCases) { category in
                        Button(category.displayName) { draft.category = category }
                    }
                } label: {
                    rowValueLabel(text: draft.category.displayName)
                }
            }

            rowDivider
            rowButton(
                icon: "calendar",
                iconBackground: palette.iconCalendarBackground,
                iconColor: palette.iconCalendar,
                title: "İlk Ödeme",
                value: nextPaymentText
            ) {
                DatePicker("", selection: $draft.nextRenewal, displayedComponents: .date)
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "tr_TR"))
            }

            rowDivider
            rowButton(
                icon: "banknote",
                iconBackground: palette.iconCurrencyBackground,
                iconColor: palette.iconCurrency,
                title: "Para Birimi",
                value: draft.currency
            ) {
                Menu {
                    Button("USD") { draft.currency = "USD" }
                    Button("EUR") { draft.currency = "EUR" }
                    Button("GBP") { draft.currency = "GBP" }
                    Button("TRY") { draft.currency = "TRY" }
                } label: {
                    rowValueLabel(text: draft.currency)
                }
            }

            rowDivider
            HStack {
                rowLabel(
                    icon: "bell",
                    iconBackground: palette.iconReminderBackground,
                    iconColor: palette.iconReminder,
                    title: "Hatırlat"
                )
                Spacer()
                Toggle("", isOn: $remindMe)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: palette.primary))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            rowDivider
            HStack {
                rowLabel(
                    icon: "calendar.badge.checkmark",
                    iconBackground: palette.iconCalendarBackground,
                    iconColor: palette.iconCalendar,
                    title: "Bitiş Tarihi"
                )
                Spacer()
                Toggle("", isOn: $draft.hasEndDate)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: palette.primary))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(palette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(palette.separator, lineWidth: 1)
        )
        .shadow(color: palette.shadow, radius: 6, x: 0, y: 3)
    }

    private var endDateCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bitiş Tarihi")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(palette.textMuted)
                .textCase(.uppercase)
            DatePicker("", selection: $draft.endDate, in: draft.nextRenewal..., displayedComponents: .date)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "tr_TR"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(palette.textPrimary)
        }
        .padding(16)
        .background(palette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(palette.separator, lineWidth: 1)
        )
    }

    private var billingCycle: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Dönem")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(palette.textMuted)
                .textCase(.uppercase)

            HStack(spacing: 0) {
                ForEach(Subscription.BillingCycle.allCases) { option in
                    Button {
                        draft.cycle = option
                    } label: {
                        Text(option.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(draft.cycle == option ? palette.textPrimary : palette.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                Group {
                                    if draft.cycle == option {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(palette.surface)
                                            .shadow(color: palette.shadow, radius: 3, x: 0, y: 1)
                                    }
                                }
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(palette.segmentBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private var saveBar: some View {
        VStack(spacing: 0) {
            Button {
                if let subscription = draft.build() {
                    onSave(subscription)
                }
                dismiss()
            } label: {
                Text("Aboneliği Kaydet")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(palette.primary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: palette.primary.opacity(0.2), radius: 10, x: 0, y: 4)
            }
            .disabled(!isValid)
            .opacity(isValid ? 1 : 0.6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(palette.background.opacity(0.95))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(palette.separator)
                .frame(height: 1)
        }
    }

    private var filteredSuggestions: [(name: String, category: Subscription.Category)] {
        let query = draft.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return [] }
        return suggestions.filter { $0.name.lowercased().contains(query) }
    }

    private var shouldShowSuggestions: Bool {
        isNameFieldFocused && !filteredSuggestions.isEmpty
    }

    private var nextPaymentText: String {
        draft.nextRenewal.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, locale: Locale(identifier: "tr_TR")))
    }

    private var currencySymbol: String {
        switch draft.currency {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "TRY": return "₺"
        default: return draft.currency
        }
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(palette.separator)
            .frame(height: 1)
    }

    private func rowLabel(icon: String, iconBackground: Color, iconColor: Color, title: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconBackground)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(palette.textPrimary)
        }
    }

    private func rowButton(icon: String, iconBackground: Color, iconColor: Color, title: String, value: String, trailing: () -> some View) -> some View {
        HStack(spacing: 12) {
            rowLabel(icon: icon, iconBackground: iconBackground, iconColor: iconColor, title: title)
            Spacer()
            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func rowValueLabel(text: String) -> some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(palette.textMuted)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(palette.textMuted)
        }
    }
}

struct NewSubscriptionData {
    var name: String = ""
    var amount: String = ""
    var currency: String = "USD"
    var cycle: Subscription.BillingCycle = .monthly
    var category: Subscription.Category = .other
    var nextRenewal: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    var hasEndDate: Bool = false
    var endDate: Date = Date()

    func build() -> Subscription? {
        guard let amountValue = normalizedAmountValue else { return nil }
        let finalEndDate = hasEndDate ? endDate : nil
        return Subscription(name: name, amount: amountValue, currency: currency, nextRenewal: nextRenewal, endDate: finalEndDate, cycle: cycle, category: category)
    }

    var normalizedAmountValue: Double? {
        let normalized = amount.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }
}

private struct NewSubscriptionPalette {
    let scheme: ColorScheme

    var primary: Color { Color(red: 0, green: 0.48, blue: 1.0) }
    var background: Color {
        scheme == .dark ? Color(red: 0.06, green: 0.09, blue: 0.13) : Color(red: 0.95, green: 0.95, blue: 0.97)
    }
    var surface: Color {
        scheme == .dark ? Color(red: 0.1, green: 0.13, blue: 0.17) : Color.white
    }
    var separator: Color {
        scheme == .dark ? Color(red: 0.16, green: 0.19, blue: 0.24) : Color(red: 0.9, green: 0.9, blue: 0.92)
    }
    var textPrimary: Color {
        scheme == .dark ? Color.white : Color(red: 0.1, green: 0.11, blue: 0.13)
    }
    var textMuted: Color {
        scheme == .dark ? Color(red: 0.62, green: 0.66, blue: 0.72) : Color(red: 0.61, green: 0.64, blue: 0.7)
    }
    var handle: Color { scheme == .dark ? Color(red: 0.3, green: 0.34, blue: 0.4) : Color(red: 0.78, green: 0.8, blue: 0.83) }
    var shadow: Color { scheme == .dark ? Color.black.opacity(0.2) : Color.black.opacity(0.06) }
    var segmentBackground: Color { scheme == .dark ? Color(red: 0.12, green: 0.14, blue: 0.19) : Color(red: 0.9, green: 0.91, blue: 0.93) }

    var iconCategoryBackground: Color { scheme == .dark ? Color(red: 0.45, green: 0.32, blue: 0.12).opacity(0.2) : Color(red: 1.0, green: 0.95, blue: 0.88) }
    var iconCategory: Color { scheme == .dark ? Color(red: 1.0, green: 0.78, blue: 0.5) : Color(red: 0.89, green: 0.55, blue: 0.2) }
    var iconCalendarBackground: Color { scheme == .dark ? Color(red: 0.2, green: 0.33, blue: 0.6).opacity(0.2) : Color(red: 0.9, green: 0.94, blue: 1.0) }
    var iconCalendar: Color { scheme == .dark ? Color(red: 0.55, green: 0.7, blue: 1.0) : Color(red: 0.27, green: 0.49, blue: 0.9) }
    var iconCurrencyBackground: Color { scheme == .dark ? Color(red: 0.2, green: 0.5, blue: 0.45).opacity(0.2) : Color(red: 0.9, green: 0.98, blue: 0.93) }
    var iconCurrency: Color { scheme == .dark ? Color(red: 0.42, green: 0.85, blue: 0.7) : Color(red: 0.2, green: 0.65, blue: 0.45) }
    var iconReminderBackground: Color { scheme == .dark ? Color(red: 0.4, green: 0.22, blue: 0.6).opacity(0.2) : Color(red: 0.95, green: 0.9, blue: 1.0) }
    var iconReminder: Color { scheme == .dark ? Color(red: 0.74, green: 0.55, blue: 0.95) : Color(red: 0.55, green: 0.35, blue: 0.8) }
}
