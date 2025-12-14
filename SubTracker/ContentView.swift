import SwiftUI
import AuthenticationServices

struct Subscription: Identifiable, Codable, Equatable {
    enum Category: String, CaseIterable, Identifiable, Codable, Equatable {
        case video, music, productivity, storage, utilities, other
        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .video: return "Video"
            case .music: return "Müzik"
            case .productivity: return "Üretkenlik"
            case .storage: return "Depolama"
            case .utilities: return "Servis"
            case .other: return "Diğer"
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

    enum BillingCycle: String, CaseIterable, Identifiable, Codable, Equatable {
        case monthly, yearly
        var id: String { rawValue }

        var title: String {
            rawValue == "monthly" ? "Aylık" : "Yıllık"
        }

        var months: Double {
            rawValue == "monthly" ? 1 : 12
        }
    }

    var id: UUID = UUID()
    var name: String
    var amount: Double
    var currency: String
    var nextRenewal: Date
    var cycle: BillingCycle
    var category: Category

    var icon: String {
        SubscriptionIconProvider.iconName(for: name, category: category)
    }

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

final class AuthViewModel: ObservableObject {
    @AppStorage("userIdentifier") private var userIdentifier: String?
    @Published var lastError: String?

    var isSignedIn: Bool {
        userIdentifier != nil
    }

    func handleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                userIdentifier = credential.user
                lastError = nil
            }
        case .failure:
            lastError = "Giriş tamamlanamadı. Lütfen tekrar deneyin."
        }
    }

    func signOut() {
        userIdentifier = nil
        lastError = nil
    }
}

struct ContentView: View {
    @StateObject private var auth = AuthViewModel()
    @State private var subscriptions: [Subscription]

    init(initialSubscriptions: [Subscription] = []) {
        let stored = SubscriptionStore.shared.load()
        _subscriptions = State(initialValue: stored.isEmpty ? initialSubscriptions : stored)
    }

    var body: some View {
        Group {
            if auth.isSignedIn {
                TabView {
                    SummaryView(subscriptions: subscriptions)
                        .tabItem {
                            Label("Özet", systemImage: "chart.bar.fill")
                        }

                    SubscriptionListView(subscriptions: $subscriptions)
                        .tabItem {
                            Label("Abonelikler", systemImage: "creditcard.fill")
                        }

                    SettingsView(auth: auth)
                        .tabItem {
                            Label("Ayarlar", systemImage: "gearshape.fill")
                        }
                }
            } else {
                SignInGateView(auth: auth)
            }
        }
        .animation(.easeInOut, value: auth.isSignedIn)
        .onChange(of: subscriptions) { newValue in
            SubscriptionStore.shared.save(newValue)
        }
    }
}

struct SummaryView: View {
    let subscriptions: [Subscription]
    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    totalCards
                    upcomingSection
                }
                .padding()
            }
            .navigationTitle("Özet")
        }
    }

    private var totalCards: some View {
        let monthly = subscriptions.monthlyTotal
        let yearly = subscriptions.yearlyTotal
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = defaultCurrency

        return HStack(spacing: 12) {
            SummaryCard(title: "Aylık", value: formatter.string(from: monthly as NSNumber) ?? "-", color: .blue)
            SummaryCard(title: "Yıllık", value: formatter.string(from: yearly as NSNumber) ?? "-", color: .purple)
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
    @Binding var subscriptions: [Subscription]
    @State private var searchText = ""
    @State private var isPresentingAdd = false
    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"

    var filtered: [Subscription] {
        guard !searchText.isEmpty else { return subscriptions }
        return subscriptions.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach($subscriptions) { $subscription in
                    NavigationLink {
                        SubscriptionDetailView(subscription: $subscription) {
                            delete(subscription.id)
                        }
                    } label: {
                        SubscriptionRow(subscription: subscription)
                    }
                }
                .onDelete(perform: delete)
            }
            .searchable(text: $searchText, prompt: "Abonelik ara")
            .navigationTitle("Abonelikler")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresentingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel("Yeni abonelik ekle")
                }
            }
            .sheet(isPresented: $isPresentingAdd) {
                NewSubscriptionSheet(defaultCurrency: defaultCurrency) { newSubscription in
                    subscriptions.append(newSubscription)
                }
            }
        }
    }

    private func delete(_ offsets: IndexSet) {
        subscriptions.remove(atOffsets: offsets)
    }

    private func delete(_ id: UUID) {
        if let index = subscriptions.firstIndex(where: { $0.id == id }) {
            subscriptions.remove(at: index)
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .center)
        .padding(.vertical, 14)
        .background(color.opacity(0.16), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct SubscriptionRow: View {
    let subscription: Subscription

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(subscription.category.color.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: subscription.icon)
                        .font(.system(size: 18, weight: .medium))
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

struct SignInGateView: View {
    @ObservedObject var auth: AuthViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
            Text("Devam etmek için Apple ile giriş yap")
                .font(.title3.bold())
            Text("Abonelik verilerin seninle eşleşsin ve cihazın değişse bile senkronize kalsın.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = []
            } onCompletion: { result in
                auth.handleCompletion(result)
            }
            .frame(height: 50)
            .padding(.horizontal, 32)
            .signInWithAppleButtonStyle(.black)
            .alert("Giriş başarısız", isPresented: .constant(auth.lastError != nil), actions: {
                Button("Kapat") {
                    auth.lastError = nil
                }
            }, message: {
                Text(auth.lastError ?? "Bilinmeyen hata")
            })

            Spacer()
        }
        .padding()
    }
}

struct NewSubscriptionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: NewSubscriptionData
    let defaultCurrency: String
    let onSave: (Subscription) -> Void
    @FocusState private var isNameFieldFocused: Bool
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

    var isValid: Bool {
        !draft.name.trimmingCharacters(in: .whitespaces).isEmpty && draft.normalizedAmountValue ?? 0 > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Manuel Ekle")) {
                    TextField("İsim", text: $draft.name)
                        .focused($isNameFieldFocused)
                        .onChange(of: draft.name) { _ in }

                    if shouldShowSuggestions {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(filteredSuggestions, id: \.name) { suggestion in
                                Button {
                                    draft.name = suggestion.name
                                    draft.category = suggestion.category
                                    isNameFieldFocused = false
                                } label: {
                                    HStack {
                                        Text(suggestion.name)
                                        Spacer()
                                        Text(suggestion.category.displayName)
                                            .foregroundStyle(.secondary)
                                            .font(.footnote)
                                    }
                                    .padding(.vertical, 6)
                                }
                            }
                        }
                    }

                    TextField("Tutar", text: $draft.amount)
                        .keyboardType(.numbersAndPunctuation)
                        .onChange(of: draft.amount) { newValue in
                            draft.amount = sanitizeAmountInput(newValue)
                        }
                    TextField("Para birimi (USD, EUR)", text: $draft.currency)
                        .textInputAutocapitalization(.characters)
                    Picker("Dönem", selection: $draft.cycle) {
                        ForEach(Subscription.BillingCycle.allCases) { cycle in
                            Text(cycle.title).tag(cycle)
                        }
                    }
                }

                Section(header: Text("Kategori ve Tarih")) {
                    Picker("Kategori", selection: $draft.category) {
                        ForEach(Subscription.Category.allCases) { category in
                            Text(category.displayName).tag(category)
                        }
                    }

                    DatePicker("Sonraki yenileme", selection: $draft.nextRenewal, displayedComponents: .date)
                }

            }
            .navigationTitle("Yeni Abonelik")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        if let subscription = draft.build() {
                            onSave(subscription)
                        }
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
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

    private func sanitizeAmountInput(_ text: String) -> String {
        var result = ""
        var separatorUsed = false
        for char in text {
            if char.isNumber {
                result.append(char)
            } else if char == "." || char == "," {
                if !separatorUsed {
                    separatorUsed = true
                    result.append(",") // normalize to comma for UI
                }
            }
        }
        return result
    }
}

struct NewSubscriptionData {
    var name: String = ""
    var amount: String = ""
    var currency: String = "USD"
    var cycle: Subscription.BillingCycle = .monthly
    var category: Subscription.Category = .other
    var nextRenewal: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()

    func build() -> Subscription? {
        guard let amountValue = normalizedAmountValue else { return nil }
        return Subscription(name: name, amount: amountValue, currency: currency, nextRenewal: nextRenewal, cycle: cycle, category: category)
    }

    var normalizedAmountValue: Double? {
        let normalized = amount.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }
}

struct SubscriptionDetailView: View {
    @Binding var subscription: Subscription
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @State private var name: String
    @State private var amount: String
    @State private var currency: String
    @State private var cycle: Subscription.BillingCycle
    @State private var category: Subscription.Category
    @State private var nextRenewal: Date

    init(subscription: Binding<Subscription>, onDelete: @escaping () -> Void) {
        _subscription = subscription
        self.onDelete = onDelete
        let value = subscription.wrappedValue
        _name = State(initialValue: value.name)
        _amount = State(initialValue: value.amount.cleanAmountString())
        _currency = State(initialValue: value.currency)
        _cycle = State(initialValue: value.cycle)
        _category = State(initialValue: value.category)
        _nextRenewal = State(initialValue: value.nextRenewal)
    }

    var body: some View {
        Form {
            Section(header: Text("Detay")) {
                TextField("İsim", text: $name)
                TextField("Tutar", text: $amount)
                    .keyboardType(.numbersAndPunctuation)
                    .onChange(of: amount) { newValue in
                        amount = sanitizeAmountInput(newValue)
                    }
                TextField("Para birimi", text: $currency)
                    .textInputAutocapitalization(.characters)
                Picker("Dönem", selection: $cycle) {
                    ForEach(Subscription.BillingCycle.allCases) { cycle in
                        Text(cycle.title).tag(cycle)
                    }
                }
            }

            Section(header: Text("Kategori ve Tarih")) {
                Picker("Kategori", selection: $category) {
                    ForEach(Subscription.Category.allCases) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                DatePicker("Sonraki yenileme", selection: $nextRenewal, displayedComponents: .date)
            }

            Section {
                Button(role: .destructive) {
                    onDelete()
                    dismiss()
                } label: {
                    Label("Sil", systemImage: "trash")
                }
            }
        }
        .navigationTitle(name.isEmpty ? "Abonelik" : name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Kaydet") {
                    saveChanges()
                    dismiss()
                }
                .disabled(!isValid)
            }
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && normalizedAmountValue != nil && normalizedAmountValue! > 0
    }

    private var normalizedAmountValue: Double? {
        amount.replacingOccurrences(of: ",", with: ".").doubleValue
    }

    private func saveChanges() {
        guard let amountValue = normalizedAmountValue else { return }
        subscription.name = name
        subscription.amount = amountValue
        subscription.currency = currency.isEmpty ? defaultCurrency : currency
        subscription.cycle = cycle
        subscription.category = category
        subscription.nextRenewal = nextRenewal
    }
}

private func sanitizeAmountInput(_ text: String) -> String {
    var result = ""
    var separatorUsed = false
    for char in text {
        if char.isNumber {
            result.append(char)
        } else if char == "." || char == "," {
            if !separatorUsed {
                separatorUsed = true
                result.append(",") // normalize to comma for UI
            }
        }
    }
    return result
}

private extension Double {
    func cleanAmountString() -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        return formatter.string(from: self as NSNumber) ?? "\(self)"
    }
}

private extension String {
    var doubleValue: Double? { Double(self) }
}

struct SubscriptionStore {
    static let shared = SubscriptionStore()
    private let fileURL: URL

    private init() {
        let fm = FileManager.default
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        if !fm.fileExists(atPath: base.path) {
            try? fm.createDirectory(at: base, withIntermediateDirectories: true)
        }
        fileURL = base.appendingPathComponent("subscriptions.json")
    }

    func load() -> [Subscription] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder().decode([Subscription].self, from: data)) ?? []
    }

    func save(_ subscriptions: [Subscription]) {
        guard let data = try? JSONEncoder().encode(subscriptions) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}

enum SubscriptionIconProvider {
    static func iconName(for name: String, category: Subscription.Category) -> String {
        let lower = name.lowercased()
        let map: [(keyword: String, symbol: String)] = [
            ("netflix", "film.fill"),
            ("prime", "play.tv"),
            ("disney", "sparkles.tv"),
            ("hbo", "tv"),
            ("youtube", "play.rectangle.fill"),
            ("spotify", "music.note.list"),
            ("music", "music.quarternote.3"),
            ("icloud", "icloud.fill"),
            ("drive", "externaldrive.fill.badge.icloud"),
            ("dropbox", "shippingbox.fill"),
            ("google one", "circle.grid.2x2"),
            ("notion", "note.text"),
            ("figma", "square.on.square"),
            ("adobe", "paintbrush.pointed.fill"),
            ("canva", "paintpalette.fill"),
            ("microsoft", "square.grid.3x3.square"),
            ("office", "square.grid.3x3.square"),
            ("ps", "gamecontroller.fill"),
            ("playstation", "gamecontroller.fill"),
            ("xbox", "gamecontroller.fill"),
            ("nintendo", "gamecontroller.fill"),
            ("vpn", "lock.shield.fill"),
            ("nord", "lock.shield.fill"),
            ("express", "lock.shield.fill"),
            ("nytimes", "newspaper.fill"),
            ("wsj", "newspaper.fill"),
            ("twitch", "bubble.left.and.bubble.right.fill")
        ]

        if let match = map.first(where: { lower.contains($0.keyword) }) {
            return match.symbol
        }

        switch category {
        case .video: return "tv"
        case .music: return "music.note"
        case .productivity: return "square.and.pencil"
        case .storage: return "externaldrive.fill"
        case .utilities: return "gearshape.fill"
        case .other: return "star.fill"
        }
    }
}

struct SettingsView: View {
    @ObservedObject var auth: AuthViewModel
    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @AppStorage("reminderDays") private var reminderDays: Int = 3

    private let currencies = ["USD", "EUR", "GBP", "TRY"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Para Birimi")) {
                    Picker("Varsayilan", selection: $defaultCurrency) {
                        ForEach(currencies, id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }
                }

                Section(header: Text("Bildirim")) {
                    Stepper(value: $reminderDays, in: 1...30) {
                        Text("Yenilemeden \(reminderDays) gün önce hatırlat")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        auth.signOut()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Çıkış yap")
                        }
                    }
                }
            }
            .navigationTitle("Ayarlar")
        }
    }
}

#Preview {
    ContentView(initialSubscriptions: Subscription.sample)
}
