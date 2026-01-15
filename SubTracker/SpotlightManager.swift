import Foundation
import CoreSpotlight
import MobileCoreServices
import UniformTypeIdentifiers

/// Abonelikleri sistem Spotlight aramasına indeksleyen yönetici.
/// Kullanıcılar iOS arama ekranından aboneliklerini bulabilir.
actor SpotlightManager {
    static let shared = SpotlightManager()
    
    private let domainIdentifier = "com.subtracker.subscriptions"
    
    /// Tek bir aboneliği Spotlight'a indeksler
    func index(subscription: Subscription) async {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
        attributeSet.title = subscription.name
        attributeSet.contentDescription = buildDescription(for: subscription)
        attributeSet.keywords = buildKeywords(for: subscription)
        
        // Kategori ikonu için thumbnail
        attributeSet.thumbnailData = categoryThumbnailData(for: subscription.category)
        
        // Ek metadata
        attributeSet.identifier = subscription.id.uuidString
        attributeSet.relatedUniqueIdentifier = subscription.id.uuidString
        
        let item = CSSearchableItem(
            uniqueIdentifier: subscription.id.uuidString,
            domainIdentifier: domainIdentifier,
            attributeSet: attributeSet
        )
        
        // 30 gün sonra süresi dolsun (kullanıcı uygulamayı açmazsa)
        item.expirationDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())
        
        do {
            try await CSSearchableIndex.default().indexSearchableItems([item])
        } catch {
            print("Spotlight index error: \(error.localizedDescription)")
        }
    }
    
    /// Birden fazla aboneliği toplu olarak indeksler
    func indexAll(subscriptions: [Subscription]) async {
        let items = subscriptions.map { subscription -> CSSearchableItem in
            let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
            attributeSet.title = subscription.name
            attributeSet.contentDescription = buildDescription(for: subscription)
            attributeSet.keywords = buildKeywords(for: subscription)
            attributeSet.thumbnailData = categoryThumbnailData(for: subscription.category)
            attributeSet.identifier = subscription.id.uuidString
            attributeSet.relatedUniqueIdentifier = subscription.id.uuidString
            
            let item = CSSearchableItem(
                uniqueIdentifier: subscription.id.uuidString,
                domainIdentifier: domainIdentifier,
                attributeSet: attributeSet
            )
            item.expirationDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())
            return item
        }
        
        guard !items.isEmpty else { return }
        
        do {
            // Önce mevcut indeksi temizle, sonra yeniden indeksle
            try await CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [domainIdentifier])
            try await CSSearchableIndex.default().indexSearchableItems(items)
        } catch {
            print("Spotlight batch index error: \(error.localizedDescription)")
        }
    }
    
    /// Tek bir aboneliği indeksten kaldırır
    func remove(subscriptionID: UUID) async {
        do {
            try await CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [subscriptionID.uuidString])
        } catch {
            print("Spotlight remove error: \(error.localizedDescription)")
        }
    }
    
    /// Tüm abonelik indeksini temizler
    func removeAll() async {
        do {
            try await CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [domainIdentifier])
        } catch {
            print("Spotlight remove all error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Helpers
    
    private func buildDescription(for subscription: Subscription) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = subscription.currency
        let amount = formatter.string(from: subscription.amount as NSNumber) ?? "\(subscription.amount)"
        
        let cycleText = subscription.cycle == .monthly ? "aylık" : "yıllık"
        let categoryText = subscription.category.displayName
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "tr_TR")
        dateFormatter.dateStyle = .medium
        let renewalText = dateFormatter.string(from: subscription.upcomingRenewalDate)
        
        return "\(amount) \(cycleText) • \(categoryText) • Yenileme: \(renewalText)"
    }
    
    private func buildKeywords(for subscription: Subscription) -> [String] {
        var keywords = [
            subscription.name,
            subscription.category.displayName,
            subscription.cycle == .monthly ? "aylık" : "yıllık",
            "abonelik",
            "subscription",
            subscription.currency
        ]
        
        // Abonelik adını kelimelere böl
        let nameWords = subscription.name.split(separator: " ").map(String.init)
        keywords.append(contentsOf: nameWords)
        
        // Kategori bazlı ek anahtar kelimeler
        switch subscription.category {
        case .video:
            keywords.append(contentsOf: ["video", "film", "dizi", "streaming", "izle"])
        case .music:
            keywords.append(contentsOf: ["müzik", "music", "şarkı", "podcast"])
        case .productivity:
            keywords.append(contentsOf: ["üretkenlik", "iş", "work", "productivity"])
        case .storage:
            keywords.append(contentsOf: ["depolama", "bulut", "cloud", "storage"])
        case .utilities:
            keywords.append(contentsOf: ["servis", "utility", "araç"])
        case .other:
            break
        }
        
        return keywords
    }
    
    private func categoryThumbnailData(for category: Subscription.Category) -> Data? {
        // SF Symbols'dan basit bir thumbnail oluştur
        // Gerçek uygulamada özel görseller kullanılabilir
        nil
    }
}

// MARK: - Spotlight Activity Identifier

extension SpotlightManager {
    /// Spotlight'tan gelen activity tipini tanımlar
    static let activityType = CSSearchableItemActionType
    
    /// Spotlight sonucundan abonelik ID'sini çıkarır
    static func subscriptionID(from userActivity: NSUserActivity) -> UUID? {
        guard userActivity.activityType == CSSearchableItemActionType,
              let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
              let uuid = UUID(uuidString: identifier) else {
            return nil
        }
        return uuid
    }
}

