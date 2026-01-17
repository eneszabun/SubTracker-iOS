import SwiftUI
import StoreKit

struct SettingsView: View {
    @ObservedObject var auth: AuthViewModel
    @StateObject private var proManager = ProManager.shared
    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @AppStorage("reminderDays") private var reminderDays: Int = 3
    @AppStorage("colorSchemePreference") private var colorSchemePreference: String = "system"
    @AppStorage("monthlyBudgetEnabled") private var monthlyBudgetEnabled = false
    @AppStorage("monthlyBudgetAmount") private var monthlyBudgetAmount: Double = 0
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var showingNameEditor = false
    @State private var editingName = ""
    @State private var showingBudgetEditor = false
    @State private var showingProUpgrade = false

    private let currencies = ["USD", "EUR", "GBP", "TRY"]

    private var palette: SettingsPalette {
        SettingsPalette(scheme: colorScheme)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    profileSection
                    appearanceSection
                    budgetSection
                    syncSection
                    notificationSection
                    signOutSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .sheet(isPresented: $showingProUpgrade) {
                ProUpgradeSheet(proManager: proManager)
            }
            .scrollIndicators(.hidden)
            .background(palette.background)
            .safeAreaInset(edge: .top, spacing: 0) {
                header
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(palette.primary)
                    .frame(width: 40, height: 40)
            }

            Spacer()

            Text("Ayarlar")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(palette.textPrimary)

            Spacer()

            Color.clear
                .frame(width: 40, height: 1)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(palette.headerBackground)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(palette.divider)
                .frame(height: 1)
        }
    }

    private var profileSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [palette.primary, palette.accentPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 92, height: 92)
                    .blur(radius: 8)
                    .opacity(0.6)

                Circle()
                    .fill(palette.background)
                    .frame(width: 86, height: 86)

                Circle()
                    .fill(palette.surface)
                    .frame(width: 82, height: 82)
                    .overlay(
                        Circle()
                            .stroke(palette.background, lineWidth: 3)
                    )

                if profileInitials.isEmpty {
                    Image(systemName: "person.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(palette.textPrimary)
                } else {
                    Text(profileInitials)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(palette.textPrimary)
                }
            }

            Button {
                editingName = auth.displayName
                showingNameEditor = true
            } label: {
                HStack(spacing: 6) {
                    Text(auth.displayName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(palette.textPrimary)
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(palette.textSecondary)
                }
            }
            .buttonStyle(.plain)

            if proManager.canAccessProFeatures {
                ProBadge()
            } else {
                Button {
                    showingProUpgrade = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "crown")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Pro'ya Yükselt")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(palette.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(palette.primary.opacity(0.1), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showingNameEditor) {
            NameEditorSheet(
                name: $editingName,
                palette: palette,
                onSave: {
                    auth.updateDisplayName(editingName)
                }
            )
            .presentationDetents([.height(220)])
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Görünüm & Para Birimi")

            SettingsCard(palette: palette) {
                NavigationLink {
                    ThemeSelectionView(selection: $colorSchemePreference)
                } label: {
                    SettingsRow(
                        palette: palette,
                        icon: "sun.max.fill",
                        iconBackground: palette.iconThemeBackground,
                        iconColor: palette.iconTheme,
                        title: "Tema",
                        value: themeTitle
                    )
                }
                .buttonStyle(.plain)

                SettingsDivider(palette: palette)

                NavigationLink {
                    CurrencySelectionView(selection: $defaultCurrency)
                } label: {
                    SettingsRow(
                        palette: palette,
                        icon: "creditcard.fill",
                        iconBackground: palette.iconCurrencyBackground,
                        iconColor: palette.iconCurrency,
                        title: "Para Birimi",
                        value: currencyDisplay
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Bütçe Yönetimi")

            SettingsCard(palette: palette) {
                // Bütçe açma/kapama toggle
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(palette.iconBudgetBackground)
                            .frame(width: 40, height: 40)
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(palette.iconBudget)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Aylık Bütçe")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(palette.textPrimary)
                        Text(monthlyBudgetEnabled ? "Aktif" : "Kapalı")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(palette.textSecondary)
                    }

                    Spacer()

                    Toggle("", isOn: $monthlyBudgetEnabled)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: palette.primary))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                if monthlyBudgetEnabled {
                    SettingsDivider(palette: palette)

                    Button {
                        showingBudgetEditor = true
                    } label: {
                        SettingsRow(
                            palette: palette,
                            icon: "turkishlirasign.circle.fill",
                            iconBackground: palette.iconCurrencyBackground,
                            iconColor: palette.iconCurrency,
                            title: "Limit Belirle",
                            value: budgetDisplayValue
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            if monthlyBudgetEnabled {
                Text("Aylık abonelik harcamalarınız belirlediğiniz limiti aştığında uyarı alırsınız.")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
                    .padding(.horizontal, 12)
            }
        }
        .sheet(isPresented: $showingBudgetEditor) {
            BudgetEditorSheet(
                amount: $monthlyBudgetAmount,
                currencyCode: defaultCurrency,
                palette: palette
            )
            .presentationDetents([.height(280)])
        }
    }

    private var budgetDisplayValue: String {
        if monthlyBudgetAmount <= 0 {
            return "Ayarlanmadı"
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = defaultCurrency
        return formatter.string(from: monthlyBudgetAmount as NSNumber) ?? "\(monthlyBudgetAmount)"
    }

    private var syncSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader("Senkronizasyon")
                Spacer()
                if !proManager.canAccessProFeatures {
                    ProBadge()
                }
            }

            SettingsCard(palette: palette) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(palette.iconSyncBackground)
                            .frame(width: 40, height: 40)
                        Image(systemName: "icloud.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(palette.iconSync)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("iCloud Senkronu")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(palette.textPrimary)
                        Text(iCloudSyncEnabled ? "Aktif" : "Kapalı")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(palette.textSecondary)
                    }

                    Spacer()

                    if proManager.canAccessProFeatures {
                        Toggle("", isOn: $iCloudSyncEnabled)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: palette.primary))
                    } else {
                        Button {
                            showingProUpgrade = true
                        } label: {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(palette.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }

            Text(proManager.canAccessProFeatures 
                 ? "Aboneliklerinizi tüm Apple cihazlarınızda senkronize edin."
                 : "iCloud senkronu Pro abonelik gerektiren bir özelliktir.")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(palette.textSecondary)
                .padding(.horizontal, 12)
        }
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Bildirimler")

            SettingsCard(palette: palette) {
                NavigationLink {
                    ReminderSelectionView(selection: $reminderDays)
                } label: {
                    SettingsRow(
                        palette: palette,
                        icon: "bell.fill",
                        iconBackground: palette.iconNotificationBackground,
                        iconColor: palette.iconNotification,
                        title: "Hatırlatma Günü",
                        value: "\(reminderDays) Gün Önce"
                    )
                }
                .buttonStyle(.plain)
            }

            Text("Abonelik yenilenme tarihinden kaç gün önce bildirim almak istediğinizi buradan ayarlayabilirsiniz.")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(palette.textSecondary)
                .padding(.horizontal, 12)
        }
    }

    private var signOutSection: some View {
        VStack(spacing: 16) {
            Button {
                auth.signOut()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Çıkış Yap")
                        .font(.system(size: 14, weight: .bold))
                        .tracking(0.5)
                }
                .foregroundStyle(palette.destructive)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(palette.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(palette.destructiveBorder, lineWidth: 1)
                )
            }

            Text("Sürüm \(appVersion)")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(palette.textSecondary.opacity(0.6))
        }
        .padding(.top, 8)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(palette.textSecondary)
            .textCase(.uppercase)
            .tracking(1.5)
            .padding(.horizontal, 8)
    }

    private var themeTitle: String {
        switch colorSchemePreference {
        case "light": return "Açık"
        case "dark": return "Koyu"
        default: return "Sistem"
        }
    }

    private var currencyDisplay: String {
        switch defaultCurrency {
        case "USD": return "USD ($)"
        case "EUR": return "EUR (€)"
        case "GBP": return "GBP (£)"
        case "TRY": return "TRY (₺)"
        default: return defaultCurrency
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return version ?? "1.0"
    }

    private var profileInitials: String {
        let parts = auth.displayName.split(separator: " ")
        if parts.count >= 2 {
            let first = parts[0].prefix(1)
            let second = parts[1].prefix(1)
            return String(first + second).uppercased()
        }
        if let first = parts.first {
            return String(first.prefix(2)).uppercased()
        }
        return ""
    }
}

private struct ThemeSelectionView: View {
    @Binding var selection: String

    var body: some View {
        SettingsSelectionView(
            title: "Tema",
            options: [
                SettingsOption("Sistem", value: "system"),
                SettingsOption("Açık", value: "light"),
                SettingsOption("Koyu", value: "dark")
            ],
            selection: $selection
        )
    }
}

private struct CurrencySelectionView: View {
    @Binding var selection: String

    var body: some View {
        SettingsSelectionView(
            title: "Para Birimi",
            options: [
                SettingsOption("USD ($)", value: "USD"),
                SettingsOption("EUR (€)", value: "EUR"),
                SettingsOption("GBP (£)", value: "GBP"),
                SettingsOption("TRY (₺)", value: "TRY")
            ],
            selection: $selection
        )
    }
}

private struct ReminderSelectionView: View {
    @Binding var selection: Int
    @StateObject private var proManager = ProManager.shared

    var body: some View {
        let maxDays = proManager.canAccessProFeatures ? 30 : 7
        let options = (1...maxDays).map { day -> SettingsOption<Int> in
            let subtitle = !proManager.canAccessProFeatures && day > 7 ? "Pro Özelliği" : nil
            return SettingsOption("\(day) Gün Önce", subtitle: subtitle, value: day)
        }
        
        return SettingsSelectionView(
            title: "Hatırlatma Günü",
            options: options,
            selection: $selection
        )
    }
}

private struct SettingsOption<Value: Hashable>: Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let value: Value

    init(_ title: String, subtitle: String? = nil, value: Value) {
        self.id = title
        self.title = title
        self.subtitle = subtitle
        self.value = value
    }
}

private struct SettingsSelectionView<Value: Hashable>: View {
    let title: String
    let options: [SettingsOption<Value>]
    @Binding var selection: Value
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private var palette: SettingsPalette {
        SettingsPalette(scheme: colorScheme)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(options) { option in
                    Button {
                        selection = option.value
                        dismiss()
                    } label: {
                        SettingsSelectionRow(
                            palette: palette,
                            title: option.title,
                            subtitle: option.subtitle,
                            isSelected: selection == option.value
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .background(palette.background)
        .safeAreaInset(edge: .top, spacing: 0) {
            SettingsDetailHeader(title: title, palette: palette)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct SettingsDetailHeader: View {
    let title: String
    let palette: SettingsPalette
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(palette.primary)
                    .frame(width: 40, height: 40)
            }

            Spacer()

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(palette.textPrimary)

            Spacer()

            Color.clear
                .frame(width: 40, height: 1)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(palette.headerBackground)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(palette.divider)
                .frame(height: 1)
        }
    }
}

private struct SettingsSelectionRow: View {
    let palette: SettingsPalette
    let title: String
    let subtitle: String?
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(palette.textSecondary)
                }
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(palette.primary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(palette.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(palette.cardBorder, lineWidth: 1)
        )
        .shadow(color: palette.cardShadow, radius: 6, x: 0, y: 2)
    }
}

private struct SettingsCard<Content: View>: View {
    let palette: SettingsPalette
    let content: Content

    init(palette: SettingsPalette, @ViewBuilder content: () -> Content) {
        self.palette = palette
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(palette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(palette.cardBorder, lineWidth: 1)
        )
        .shadow(color: palette.cardShadow, radius: 6, x: 0, y: 2)
    }
}

private struct SettingsDivider: View {
    let palette: SettingsPalette

    var body: some View {
        Rectangle()
            .fill(palette.divider)
            .frame(height: 1)
            .padding(.leading, 72)
    }
}

private struct SettingsRow: View {
    let palette: SettingsPalette
    let icon: String
    let iconBackground: Color
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconBackground)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(palette.textPrimary)

            Spacer()

            HStack(spacing: 6) {
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(palette.textSecondary.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

private struct SettingsPalette {
    let scheme: ColorScheme

    var primary: Color { Color(red: 0.11, green: 0.45, blue: 0.93) }
    var accentPurple: Color { Color(red: 0.55, green: 0.3, blue: 0.85) }
    var background: Color {
        scheme == .dark ? Color(red: 0.06, green: 0.09, blue: 0.13) : Color(red: 0.96, green: 0.97, blue: 0.98)
    }
    var headerBackground: Color { background.opacity(0.95) }
    var surface: Color {
        scheme == .dark ? Color(red: 0.11, green: 0.15, blue: 0.19) : Color.white
    }
    var cardBorder: Color {
        scheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05)
    }
    var divider: Color {
        scheme == .dark ? Color.white.opacity(0.05) : Color(red: 0.92, green: 0.93, blue: 0.95)
    }
    var textPrimary: Color { scheme == .dark ? Color.white : Color(red: 0.09, green: 0.11, blue: 0.13) }
    var textSecondary: Color { scheme == .dark ? Color(red: 0.62, green: 0.66, blue: 0.72) : Color(red: 0.45, green: 0.5, blue: 0.58) }
    var cardShadow: Color { scheme == .dark ? Color.black.opacity(0.2) : Color.black.opacity(0.05) }

    var iconThemeBackground: Color { scheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.5).opacity(0.3) : Color(red: 0.9, green: 0.92, blue: 1.0) }
    var iconTheme: Color { scheme == .dark ? Color(red: 0.5, green: 0.6, blue: 0.95) : Color(red: 0.35, green: 0.45, blue: 0.85) }
    var iconCurrencyBackground: Color { scheme == .dark ? Color(red: 0.1, green: 0.45, blue: 0.32).opacity(0.3) : Color(red: 0.9, green: 0.98, blue: 0.94) }
    var iconCurrency: Color { scheme == .dark ? Color(red: 0.35, green: 0.9, blue: 0.7) : Color(red: 0.2, green: 0.65, blue: 0.45) }
    var iconNotificationBackground: Color { scheme == .dark ? Color(red: 0.5, green: 0.35, blue: 0.1).opacity(0.3) : Color(red: 1.0, green: 0.95, blue: 0.85) }
    var iconNotification: Color { scheme == .dark ? Color(red: 0.95, green: 0.7, blue: 0.35) : Color(red: 0.8, green: 0.55, blue: 0.1) }
    
    var iconBudgetBackground: Color { scheme == .dark ? Color(red: 0.45, green: 0.2, blue: 0.5).opacity(0.3) : Color(red: 0.98, green: 0.92, blue: 1.0) }
    var iconBudget: Color { scheme == .dark ? Color(red: 0.8, green: 0.5, blue: 0.9) : Color(red: 0.6, green: 0.3, blue: 0.75) }
    
    var iconSyncBackground: Color { scheme == .dark ? Color(red: 0.15, green: 0.35, blue: 0.55).opacity(0.4) : Color(red: 0.9, green: 0.95, blue: 1.0) }
    var iconSync: Color { scheme == .dark ? Color(red: 0.4, green: 0.7, blue: 1.0) : Color(red: 0.2, green: 0.5, blue: 0.9) }

    var destructive: Color { scheme == .dark ? Color(red: 0.95, green: 0.4, blue: 0.4) : Color(red: 0.86, green: 0.2, blue: 0.2) }
    var destructiveBorder: Color { scheme == .dark ? Color(red: 0.55, green: 0.18, blue: 0.18).opacity(0.4) : Color(red: 0.95, green: 0.85, blue: 0.85) }
}

private struct NameEditorSheet: View {
    @Binding var name: String
    let palette: SettingsPalette
    let onSave: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Adınız")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(palette.textSecondary)
                    
                    TextField("Adınızı girin", text: $name)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(palette.textPrimary)
                        .padding(14)
                        .background(palette.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(palette.cardBorder, lineWidth: 1)
                        )
                        .focused($isFocused)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .background(palette.background)
            .navigationTitle("İsmi Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
}

private struct BudgetEditorSheet: View {
    @Binding var amount: Double
    let currencyCode: String
    let palette: SettingsPalette
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    @State private var amountText: String = ""
    
    private var currencySymbol: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.currencySymbol ?? currencyCode
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Aylık bütçe limitinizi belirleyin")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(palette.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    HStack(alignment: .center, spacing: 4) {
                        Text(currencySymbol)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(palette.textSecondary)
                        
                        TextField("0", text: $amountText)
                            .font(.system(size: 48, weight: .black))
                            .foregroundStyle(palette.textPrimary)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .focused($isFocused)
                            .onChange(of: amountText, initial: false) { _, newValue in
                                amountText = sanitizeBudgetInput(newValue)
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                
                // Hızlı seçim butonları
                HStack(spacing: 12) {
                    ForEach(quickAmounts, id: \.self) { quickAmount in
                        Button {
                            amountText = String(format: "%.0f", quickAmount)
                        } label: {
                            Text(formattedQuickAmount(quickAmount))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(palette.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(palette.primary.opacity(0.1), in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .background(palette.background)
            .navigationTitle("Bütçe Limiti")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        if let value = normalizedAmount {
                            amount = value
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(normalizedAmount == nil || normalizedAmount! <= 0)
                }
            }
            .onAppear {
                if amount > 0 {
                    amountText = String(format: "%.0f", amount)
                }
                isFocused = true
            }
        }
    }
    
    private var normalizedAmount: Double? {
        amountText.replacingOccurrences(of: ",", with: ".").doubleValue
    }
    
    private var quickAmounts: [Double] {
        switch currencyCode {
        case "TRY": return [500, 1000, 2500, 5000]
        case "EUR", "GBP": return [50, 100, 200, 500]
        default: return [50, 100, 250, 500]
        }
    }
    
    private func formattedQuickAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSNumber) ?? "\(Int(value))"
    }
    
    private func sanitizeBudgetInput(_ input: String) -> String {
        var result = input.filter { $0.isNumber || $0 == "," || $0 == "." }
        let separators = result.filter { $0 == "," || $0 == "." }
        if separators.count > 1 {
            var foundFirst = false
            result = String(result.compactMap { char in
                if char == "," || char == "." {
                    if foundFirst { return nil }
                    foundFirst = true
                }
                return char
            })
        }
        return result
    }
}

// MARK: - Pro Upgrade Sheet

struct ProUpgradeSheet: View {
    @ObservedObject var proManager: ProManager
    @StateObject private var storeManager = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private var palette: SettingsPalette {
        SettingsPalette(scheme: colorScheme)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Hero Section
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 0.95, green: 0.4, blue: 0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .shadow(color: Color(red: 1.0, green: 0.5, blue: 0.25).opacity(0.4), radius: 20, x: 0, y: 10)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text("SubTracker Pro")
                                .font(.system(size: 28, weight: .black))
                                .foregroundStyle(palette.textPrimary)
                            
                            Text("Tüm özelliklerin kilidini açın")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(palette.textSecondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Features List
                    VStack(spacing: 12) {
                        ForEach(ProManager.proFeatures) { feature in
                            ProFeatureRow(feature: feature, palette: palette)
                        }
                    }
                    
                    // Pricing Section
                    if storeManager.isLoading {
                        ProgressView()
                            .padding(.vertical, 40)
                    } else if storeManager.products.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 32, weight: .light))
                                .foregroundStyle(palette.textSecondary.opacity(0.5))
                            Text("Ürünler yüklenemedi")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(palette.textSecondary)
                            Button("Tekrar Dene") {
                                Task { await storeManager.loadProducts() }
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(palette.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(palette.primary.opacity(0.1), in: Capsule())
                        }
                        .padding(.vertical, 40)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(storeManager.products, id: \.id) { product in
                                let isYearly = product.id == StoreManager.ProductID.proYearly.rawValue
                                let isPurchasing: Bool = {
                                    if case .purchasing = storeManager.purchaseState {
                                        return true
                                    }
                                    return false
                                }()
                                
                                ProPlanCard(
                                    title: isYearly ? "Yıllık" : "Aylık",
                                    price: product.displayPrice,
                                    period: isYearly ? "/yıl" : "/ay",
                                    savings: isYearly ? savingsText(for: product) : nil,
                                    isPopular: isYearly,
                                    isPurchasing: isPurchasing,
                                    palette: palette
                                ) {
                                    Task {
                                        await storeManager.purchase(product)
                                        handlePurchaseResult()
                                    }
                                }
                            }
                        }
                    }
                    
                    // Trial Button
                    if !proManager.canAccessProFeatures && proManager.trialEndDate == nil {
                        Button {
                            proManager.startTrial()
                            dismiss()
                        } label: {
                            Text("7 Gün Ücretsiz Dene")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(palette.primary)
                        }
                        .padding(.top, 4)
                    }
                    
                    // Restore Button
                    Button {
                        Task {
                            await storeManager.restorePurchases()
                            handlePurchaseResult()
                        }
                    } label: {
                        Text("Satın Almaları Geri Yükle")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(palette.textSecondary)
                    }
                    .padding(.top, 8)
                    
                    // Terms
                    Text("Satın alma işlemi Apple Kimliğinize faturalandırılır. Abonelik, mevcut dönem sona ermeden en az 24 saat önce iptal edilmediği sürece otomatik olarak yenilenir.")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(palette.textSecondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .background(palette.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(palette.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(palette.surface, in: Circle())
                    }
                }
            }
            .alert("Hata", isPresented: $showingError) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .task {
                await storeManager.loadProducts()
            }
        }
    }
    
    private func savingsText(for product: Product) -> String? {
        guard let monthlyEquivalent = product.monthlyEquivalent else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceFormatStyle.locale
        if let monthlyStr = formatter.string(from: monthlyEquivalent as NSDecimalNumber) {
            return "Ayda sadece \(monthlyStr)"
        }
        return "2 ay ücretsiz"
    }
    
    private func handlePurchaseResult() {
        switch storeManager.purchaseState {
        case .purchased:
            dismiss()
        case .restored:
            dismiss()
        case .failed(let message):
            errorMessage = message
            showingError = true
        case .cancelled:
            // Kullanıcı iptal etti, bir şey yapma
            break
        default:
            break
        }
    }
}

private struct ProFeatureRow: View {
    let feature: ProFeature
    let palette: SettingsPalette
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.15), Color(red: 0.95, green: 0.4, blue: 0.3).opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: feature.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(red: 0.95, green: 0.5, blue: 0.25))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(palette.textPrimary)
                
                Text(feature.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
            }
            
            Spacer()
        }
        .padding(14)
        .background(palette.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(palette.cardBorder, lineWidth: 1)
        )
    }
}

private struct ProPlanCard: View {
    let title: String
    let price: String
    let period: String
    var savings: String? = nil
    let isPopular: Bool
    var isPurchasing: Bool = false
    let palette: SettingsPalette
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                if isPopular {
                    Text("EN POPÜLER")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.white)
                        .tracking(0.5)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 0.95, green: 0.4, blue: 0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(palette.textPrimary)
                        
                        if let savings = savings {
                            Text(savings)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color(red: 0.2, green: 0.7, blue: 0.4))
                        }
                    }
                    
                    Spacer()
                    
                    if isPurchasing {
                        ProgressView()
                            .tint(palette.textSecondary)
                    } else {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text(price)
                                .font(.system(size: 24, weight: .black))
                                .foregroundStyle(palette.textPrimary)
                            
                            Text(period)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(palette.textSecondary)
                        }
                    }
                }
            }
            .padding(16)
            .background(palette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        isPopular 
                            ? LinearGradient(
                                colors: [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 0.95, green: 0.4, blue: 0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(colors: [palette.cardBorder], startPoint: .top, endPoint: .bottom),
                        lineWidth: isPopular ? 2 : 1
                    )
            )
            .shadow(color: isPopular ? Color(red: 1.0, green: 0.5, blue: 0.25).opacity(0.2) : palette.cardShadow, radius: isPopular ? 12 : 6, x: 0, y: isPopular ? 6 : 2)
        }
        .buttonStyle(.plain)
    }
}
