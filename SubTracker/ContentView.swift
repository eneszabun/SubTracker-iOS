import SwiftUI
import CoreSpotlight

enum AppTab: Hashable {
    case summary
    case subscriptions
    case settings
}

struct ContentView: View {
    @StateObject private var auth = AuthViewModel()
    @State private var subscriptions: [Subscription]
    @State private var selectedTab: AppTab = .summary
    @AppStorage("colorSchemePreference") private var colorSchemePreference: String = "system"
    @AppStorage("reminderDays") private var reminderDays: Int = 3
    
    /// Spotlight'tan seçilen abonelik ID'si
    @State private var spotlightSelectedID: UUID?

    init(initialSubscriptions: [Subscription] = []) {
        let stored = SubscriptionStore.shared.load()
        _subscriptions = State(initialValue: stored.isEmpty ? initialSubscriptions : stored)
    }

    var body: some View {
        Group {
            if auth.isSignedIn {
                TabView(selection: $selectedTab) {
                    SummaryView(subscriptions: $subscriptions, selectedTab: $selectedTab)
                        .tabItem {
                            Label("Özet", systemImage: "chart.bar.fill")
                        }
                        .tag(AppTab.summary)

                    SubscriptionListView(
                        subscriptions: $subscriptions,
                        spotlightSelectedID: $spotlightSelectedID
                    )
                        .tabItem {
                            Label("Abonelikler", systemImage: "creditcard.fill")
                        }
                        .tag(AppTab.subscriptions)

                    SettingsView(auth: auth)
                        .tabItem {
                            Label("Ayarlar", systemImage: "gearshape.fill")
                        }
                        .tag(AppTab.settings)
                }
                .task {
                    await NotificationScheduler.shared.requestAuthorization()
                }
            } else {
                SignInGateView(auth: auth)
            }
        }
        .animation(.easeInOut, value: auth.isSignedIn)
        .onChange(of: subscriptions, initial: false) { _, newValue in
            Task { await SubscriptionStore.shared.save(newValue) }
            Task {
                await NotificationScheduler.shared.syncAll(subscriptions: newValue, reminderDays: reminderDays)
            }
        }
        .preferredColorScheme(preferredScheme)
        // Spotlight aramasından abonelik seçildiğinde
        .onContinueUserActivity(CSSearchableItemActionType) { userActivity in
            handleSpotlightActivity(userActivity)
        }
    }

    private var preferredScheme: ColorScheme? {
        switch colorSchemePreference {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
    
    /// Spotlight'tan gelen aktiviteyi işler
    private func handleSpotlightActivity(_ userActivity: NSUserActivity) {
        guard let subscriptionID = SpotlightManager.subscriptionID(from: userActivity) else {
            return
        }
        
        // Abonelikler sekmesine geç ve seçili aboneliği ayarla
        selectedTab = .subscriptions
        spotlightSelectedID = subscriptionID
    }
}

#Preview {
    ContentView(initialSubscriptions: Subscription.sample)
}
