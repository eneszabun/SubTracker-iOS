import AppIntents

/// Siri'ye önerilen kısayollar
@available(iOS 16.0, *)
struct SubTrackerAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        // 1. Aylık toplam harcama
        AppShortcut(
            intent: GetMonthlyTotalIntent(),
            phrases: [
                "Aylık harcamam ne kadar \(.applicationName)'da",
                "Toplam abonelik harcamam \(.applicationName)'da",
                "\(.applicationName)'da aylık toplam",
                "Abonelik toplamı \(.applicationName)"
            ],
            shortTitle: "Aylık Toplam",
            systemImageName: "chart.bar.fill"
        )
        
        // 2. Yaklaşan yenilemeler
        AppShortcut(
            intent: GetUpcomingRenewalsIntent(),
            phrases: [
                "Yaklaşan yenilemelerim \(.applicationName)'da",
                "\(.applicationName)'da hangi abonelikler yenilenecek",
                "Yenilenecek abonelikler \(.applicationName)",
                "\(.applicationName) yenileme bildirimleri"
            ],
            shortTitle: "Yaklaşan Yenilemeler",
            systemImageName: "calendar.badge.clock"
        )
        
        // 3. Aboneliklerimi göster
        AppShortcut(
            intent: GetSubscriptionsIntent(),
            phrases: [
                "Aboneliklerimi göster \(.applicationName)'da",
                "\(.applicationName)'da aboneliklerim",
                "\(.applicationName) abonelik listesi",
                "Aktif aboneliklerim \(.applicationName)"
            ],
            shortTitle: "Aboneliklerim",
            systemImageName: "list.bullet.rectangle"
        )
    }
    
    static var shortcutTileColor: ShortcutTileColor {
        .blue
    }
}
