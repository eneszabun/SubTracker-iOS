import SwiftUI

struct SubscriptionDetailView: View {
    @Binding var subscription: Subscription
    let onSave: (Subscription) -> Void
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @AppStorage("reminderDays") private var reminderDays: Int = 3
    @State private var name: String
    @State private var amount: String
    @State private var currency: String
    @State private var cycle: Subscription.BillingCycle
    @State private var category: Subscription.Category
    @State private var nextRenewal: Date
    @State private var hasEndDate: Bool
    @State private var endDate: Date
    @State private var remindMe: Bool = true

    private let currencies = ["USD", "EUR", "GBP", "TRY"]

    init(subscription: Binding<Subscription>, onSave: @escaping (Subscription) -> Void, onDelete: @escaping () -> Void) {
        _subscription = subscription
        self.onSave = onSave
        self.onDelete = onDelete
        let value = subscription.wrappedValue
        _name = State(initialValue: value.name)
        _amount = State(initialValue: value.amount.cleanAmountString())
        _currency = State(initialValue: value.currency)
        _cycle = State(initialValue: value.cycle)
        _category = State(initialValue: value.category)
        _nextRenewal = State(initialValue: value.nextRenewal)
        _hasEndDate = State(initialValue: value.endDate != nil)
        _endDate = State(initialValue: value.endDate ?? Date())
    }

    private var palette: SubscriptionDetailPalette {
        SubscriptionDetailPalette(scheme: colorScheme)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    heroSection
                    formSection
                    reminderCard
                    endDateSection
                    actionButtons
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .background(palette.background)
            .safeAreaInset(edge: .top, spacing: 0) {
                header
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                remindMe = reminderDays > 0
            }
        }
    }

    private var header: some View {
        HStack {
            Button("Vazgeç") {
                dismiss()
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(palette.textSecondary)

            Spacer()

            Text("Abonelik Düzenle")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(palette.textPrimary)

            Spacer()

            Color.clear
                .frame(width: 50, height: 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(palette.background.opacity(0.95))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(palette.border)
                .frame(height: 1)
        }
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(category.color.gradient)
                    .frame(width: 96, height: 96)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(palette.heroRing, lineWidth: 1)
                    )
                    .shadow(color: palette.heroShadow, radius: 8, x: 0, y: 6)

                Image(systemName: subscription.icon)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.white)
            }

            VStack(spacing: 4) {
                Text(name.isEmpty ? "Abonelik" : name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(palette.textPrimary)
                    .multilineTextAlignment(.center)

                Text("\(formattedAmount(subscription.monthlyCost, currencyCode: currency))/ay")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    private var formSection: some View {
        VStack(spacing: 16) {
            fieldBlock(title: "Abonelik Adı") {
                TextField("Örn: Netflix Premium", text: $name)
                    .textInputAutocapitalization(.words)
                    .foregroundStyle(palette.textPrimary)
            }

            HStack(spacing: 12) {
                fieldBlock(title: "Tutar") {
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(palette.textSecondary)
                        TextField("0,00", text: $amount)
                            .keyboardType(.numbersAndPunctuation)
                            .foregroundStyle(palette.textPrimary)
                            .onChange(of: amount, initial: false) { _, newValue in
                                amount = sanitizeAmountInput(newValue)
                            }
                    }
                }

                fieldBlock(title: "Para Birimi") {
                    Menu {
                        ForEach(currencies, id: \.self) { code in
                            Button(code) { currency = code }
                        }
                    } label: {
                        menuLabel(text: currency)
                    }
                }
            }

            fieldBlock(title: "Dönem") {
                Menu {
                    ForEach(Subscription.BillingCycle.allCases) { cycle in
                        Button(cycle.title) { self.cycle = cycle }
                    }
                } label: {
                    menuLabel(text: cycle.title)
                }
            }

            HStack(spacing: 12) {
                fieldBlock(title: "İlk Ödeme") {
                    DatePicker("", selection: $nextRenewal, displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                        .foregroundStyle(palette.textPrimary)
                }

                fieldBlock(title: "Kategori") {
                    Menu {
                        ForEach(Subscription.Category.allCases) { category in
                            Button(category.displayName) { self.category = category }
                        }
                    } label: {
                        menuLabel(text: category.displayName)
                    }
                }
            }
        }
    }

    private var reminderCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(palette.primary.opacity(0.18))
                    .frame(width: 40, height: 40)
                Image(systemName: "bell.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(palette.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Hatırlat")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(palette.textPrimary)
                Text(remindMe ? "Yenilemeden \(reminderDays) gün önce" : "Hatırlatıcı kapalı")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
            }

            Spacer()

            Toggle("", isOn: $remindMe)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: palette.primary))
        }
        .padding(14)
        .background(palette.inputBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(palette.inputBorder, lineWidth: 1)
        )
    }

    private var endDateSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(palette.primary.opacity(0.18))
                        .frame(width: 40, height: 40)
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(palette.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Bitiş Tarihi")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(palette.textPrimary)
                    Text(hasEndDate ? "Belirlendi" : "Yok")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(palette.textSecondary)
                }

                Spacer()

                Toggle("", isOn: $hasEndDate)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: palette.primary))
            }
            .padding(14)
            .background(palette.inputBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(palette.inputBorder, lineWidth: 1)
            )

            if hasEndDate {
                fieldBlock(title: "Bitiş Tarihi") {
                    DatePicker("", selection: $endDate, in: nextRenewal..., displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                        .foregroundStyle(palette.textPrimary)
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                saveChanges()
                dismiss()
            } label: {
                Text("Değişiklikleri Kaydet")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background(isValid ? palette.primary : palette.primary.opacity(0.4), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: palette.primary.opacity(isValid ? 0.35 : 0), radius: 10, x: 0, y: 6)
            }
            .disabled(!isValid)

            Button(role: .destructive) {
                onDelete()
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Aboneliği Sil")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(palette.destructiveText)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(palette.destructiveBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(.top, 4)
    }

    private func fieldBlock(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(palette.textPrimary)
            content()
                .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                .padding(.horizontal, 12)
                .background(palette.inputBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(palette.inputBorder, lineWidth: 1)
                )
        }
    }

    private func menuLabel(text: String) -> some View {
        HStack {
            Text(text)
                .foregroundStyle(palette.textPrimary)
                .font(.system(size: 15, weight: .medium))
            Spacer()
            Image(systemName: "chevron.down")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(palette.textSecondary)
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && normalizedAmountValue != nil && normalizedAmountValue! > 0
    }

    private var normalizedAmountValue: Double? {
        amount.replacingOccurrences(of: ",", with: ".").doubleValue
    }

    private func formattedAmount(_ value: Double, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode.isEmpty ? defaultCurrency : currencyCode
        return formatter.string(from: value as NSNumber) ?? "\(value)"
    }

    private func saveChanges() {
        guard let amountValue = normalizedAmountValue else { return }
        subscription.name = name
        subscription.amount = amountValue
        subscription.currency = currency.isEmpty ? defaultCurrency : currency
        subscription.cycle = cycle
        subscription.category = category
        subscription.nextRenewal = nextRenewal
        subscription.endDate = hasEndDate ? endDate : nil
        onSave(subscription)
    }
}

private struct SubscriptionDetailPalette {
    let scheme: ColorScheme

    var primary: Color { Color(red: 0.11, green: 0.45, blue: 0.93) }
    var background: Color {
        scheme == .dark ? Color(red: 0.06, green: 0.09, blue: 0.13) : Color(red: 0.96, green: 0.97, blue: 0.98)
    }
    var inputBackground: Color {
        scheme == .dark ? Color(red: 0.16, green: 0.18, blue: 0.22) : Color.white
    }
    var textPrimary: Color {
        scheme == .dark ? Color.white : Color(red: 0.07, green: 0.08, blue: 0.09)
    }
    var textSecondary: Color {
        scheme == .dark ? Color(red: 0.62, green: 0.66, blue: 0.73) : Color(red: 0.39, green: 0.46, blue: 0.53)
    }
    var border: Color {
        scheme == .dark ? Color(red: 0.16, green: 0.19, blue: 0.24) : Color(red: 0.88, green: 0.9, blue: 0.92)
    }
    var inputBorder: Color {
        scheme == .dark ? Color.clear : Color(red: 0.92, green: 0.93, blue: 0.95)
    }
    var heroRing: Color {
        scheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.05)
    }
    var heroShadow: Color {
        scheme == .dark ? Color.black.opacity(0.4) : Color.black.opacity(0.12)
    }
    var destructiveText: Color {
        scheme == .dark ? Color(red: 0.95, green: 0.35, blue: 0.3) : Color(red: 0.86, green: 0.2, blue: 0.2)
    }
    var destructiveBackground: Color {
        scheme == .dark ? Color(red: 0.95, green: 0.35, blue: 0.3).opacity(0.12) : Color(red: 0.98, green: 0.9, blue: 0.9)
    }
}
