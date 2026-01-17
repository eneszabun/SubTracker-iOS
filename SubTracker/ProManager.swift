import Foundation
import SwiftUI

/// Pro abonelik durumu yöneticisi
/// StoreKit entegrasyonu için hazır altyapı
class ProManager: ObservableObject {
    static let shared = ProManager()
    
    // MARK: - Published Properties
    
    /// Kullanıcının Pro üyelik durumu
    @Published private(set) var isPro: Bool = false
    
    /// Pro deneme süresi aktif mi
    @Published private(set) var isTrialActive: Bool = false
    
    /// Deneme bitiş tarihi
    @Published private(set) var trialEndDate: Date?
    
    // MARK: - UserDefaults Keys
    
    private let proStatusKey = "isProUser"
    private let trialStartKey = "trialStartDate"
    private let trialDurationDays = 7
    
    // MARK: - Initialization
    
    init() {
        loadProStatus()
    }
    
    // MARK: - Pro Status Management
    
    /// Pro durumunu UserDefaults'tan yükle
    private func loadProStatus() {
        isPro = UserDefaults.standard.bool(forKey: proStatusKey)
        
        // Deneme süresini kontrol et
        if let trialStart = UserDefaults.standard.object(forKey: trialStartKey) as? Date {
            let calendar = Calendar.current
            if let trialEnd = calendar.date(byAdding: .day, value: trialDurationDays, to: trialStart) {
                trialEndDate = trialEnd
                isTrialActive = trialEnd > Date()
            }
        }
    }
    
    /// Pro üyeliği aktifleştir (satın alma sonrası çağrılır)
    func activatePro() {
        isPro = true
        UserDefaults.standard.set(true, forKey: proStatusKey)
    }
    
    /// Pro üyeliği deaktif et
    func deactivatePro() {
        isPro = false
        UserDefaults.standard.set(false, forKey: proStatusKey)
    }
    
    /// 7 günlük deneme süresini başlat
    func startTrial() {
        guard !isPro && trialEndDate == nil else { return }
        
        let now = Date()
        UserDefaults.standard.set(now, forKey: trialStartKey)
        
        let calendar = Calendar.current
        trialEndDate = calendar.date(byAdding: .day, value: trialDurationDays, to: now)
        isTrialActive = true
    }
    
    /// Deneme süresinden kalan gün sayısı
    var trialDaysRemaining: Int {
        guard let endDate = trialEndDate else { return 0 }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return max(0, days)
    }
    
    /// Kullanıcı Pro özelliklerine erişebilir mi (Pro veya deneme aktif)
    var canAccessProFeatures: Bool {
        isPro || isTrialActive
    }
    
    // MARK: - Pro Features
    
    /// Pro özellikleri listesi
    static let proFeatures: [ProFeature] = [
        ProFeature(
            icon: "icloud.fill",
            title: "iCloud Senkronu",
            description: "Tüm cihazlarınızda aboneliklerinizi senkronize edin"
        ),
        ProFeature(
            icon: "chart.bar.xaxis",
            title: "Gelişmiş Raporlar",
            description: "Kategori bazlı dağılım grafikleri ve nakit akış analizi"
        ),
        ProFeature(
            icon: "paintpalette.fill",
            title: "Premium Temalar",
            description: "Özel temalar ve uygulama ikonları"
        ),
        ProFeature(
            icon: "bell.badge.fill",
            title: "Geniş Bildirim Ufku",
            description: "30 güne kadar önceden hatırlatma alın"
        )
    ]
}

// MARK: - Pro Feature Model

struct ProFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

// MARK: - Pro Feature Gate View

/// Pro özelliği kilitli olduğunda gösterilecek view
struct ProFeatureGate: View {
    let featureName: String
    let onUpgrade: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var palette: ProGatePalette {
        ProGatePalette(scheme: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [palette.proGradientStart, palette.proGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            VStack(spacing: 8) {
                Text("Pro Özellik")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(palette.textPrimary)
                
                Text("\(featureName) özelliği Pro abonelik gerektirir.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                onUpgrade()
            } label: {
                Text("Pro'ya Yükselt")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(
                        LinearGradient(
                            colors: [palette.proGradientStart, palette.proGradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                    .shadow(color: palette.proGradientStart.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(palette.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        )
    }
}

// MARK: - Pro Badge View

/// Pro rozeti
struct ProBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: 10, weight: .bold))
            Text("PRO")
                .font(.system(size: 10, weight: .black))
                .tracking(0.5)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
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
}

// MARK: - Pro Gate Palette

private struct ProGatePalette {
    let scheme: ColorScheme
    
    var proGradientStart: Color { Color(red: 1.0, green: 0.6, blue: 0.2) }
    var proGradientEnd: Color { Color(red: 0.95, green: 0.4, blue: 0.3) }
    
    var surface: Color {
        scheme == .dark ? Color(red: 0.11, green: 0.14, blue: 0.19) : Color.white
    }
    var border: Color {
        scheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05)
    }
    var textPrimary: Color {
        scheme == .dark ? Color.white : Color(red: 0.09, green: 0.11, blue: 0.13)
    }
    var textSecondary: Color {
        scheme == .dark ? Color(red: 0.62, green: 0.66, blue: 0.72) : Color(red: 0.45, green: 0.5, blue: 0.58)
    }
}

// MARK: - View Extension for Pro Features

extension View {
    /// Pro özelliği gerektiren view'ları kısıtlar
    @ViewBuilder
    func requiresPro(
        isProUser: Bool,
        featureName: String,
        onUpgrade: @escaping () -> Void
    ) -> some View {
        if isProUser {
            self
        } else {
            ProFeatureGate(featureName: featureName, onUpgrade: onUpgrade)
        }
    }
}
