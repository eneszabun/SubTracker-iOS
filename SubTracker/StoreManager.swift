import Foundation
import StoreKit
import SwiftUI

/// StoreKit 2 ile in-app purchase yönetimi
@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    // MARK: - Published Properties
    
    /// Mevcut ürünler
    @Published private(set) var products: [Product] = []
    
    /// Satın alma durumu
    @Published private(set) var purchaseState: PurchaseState = .idle
    
    /// Aktif abonelikler
    @Published private(set) var activeSubscriptions: Set<String> = []
    
    /// Yükleme durumu
    @Published private(set) var isLoading = false
    
    // MARK: - Product IDs
    
    enum ProductID: String, CaseIterable {
        case proMonthly = "com.subtracker.pro.monthly"
        case proYearly = "com.subtracker.pro.yearly"
        
        var displayName: String {
            switch self {
            case .proMonthly: return "Pro Aylık"
            case .proYearly: return "Pro Yıllık"
            }
        }
    }
    
    // MARK: - Purchase State
    
    enum PurchaseState: Equatable {
        case idle
        case purchasing
        case purchased(ProductID)
        case restored
        case failed(String)
        case cancelled
    }
    
    // MARK: - Transaction Listener
    
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Initialization
    
    init() {
        // Transaction listener'ı başlat
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updateActiveSubscriptions()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    /// Ürünleri App Store'dan yükle
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIDs)
                .sorted { lhs, rhs in
                    // Yıllık planı önce göster
                    if lhs.id == ProductID.proYearly.rawValue { return true }
                    if rhs.id == ProductID.proYearly.rawValue { return false }
                    return lhs.price < rhs.price
                }
        } catch {
            print("Failed to load products: \(error)")
            purchaseState = .failed("Ürünler yüklenemedi")
        }
    }
    
    // MARK: - Purchase
    
    /// Ürün satın al
    func purchase(_ product: Product) async {
        purchaseState = .purchasing
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                
                // Transaction'ı tamamla
                await transaction.finish()
                
                // Aktif abonelikleri güncelle
                await updateActiveSubscriptions()
                
                // Pro durumunu aktifleştir
                if let productID = ProductID(rawValue: product.id) {
                    ProManager.shared.activatePro()
                    purchaseState = .purchased(productID)
                }
                
            case .userCancelled:
                purchaseState = .cancelled
                
            case .pending:
                purchaseState = .failed("Satın alma beklemede")
                
            @unknown default:
                purchaseState = .failed("Bilinmeyen durum")
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
        }
    }
    
    // MARK: - Restore Purchases
    
    /// Satın almaları geri yükle
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            await updateActiveSubscriptions()
            
            if !activeSubscriptions.isEmpty {
                ProManager.shared.activatePro()
                purchaseState = .restored
            } else {
                purchaseState = .failed("Geri yüklenecek satın alma bulunamadı")
            }
        } catch {
            purchaseState = .failed("Geri yükleme başarısız")
        }
    }
    
    // MARK: - Active Subscriptions
    
    /// Aktif abonelikleri güncelle
    private func updateActiveSubscriptions() async {
        var active: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if transaction.productType == .autoRenewable {
                    active.insert(transaction.productID)
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        activeSubscriptions = active
        
        // Pro durumunu güncelle
        if !active.isEmpty {
            ProManager.shared.activatePro()
        } else {
            ProManager.shared.deactivatePro()
        }
    }
    
    // MARK: - Transaction Verification
    
    /// Transaction'ı doğrula
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Transaction Listener
    
    /// Transaction güncellemelerini dinle
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    await self.updateActiveSubscriptions()
                    await transaction.finish()
                } catch {
                    print("Transaction update failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Ürün ID'sine göre ürünü bul
    func product(for id: ProductID) -> Product? {
        products.first { $0.id == id.rawValue }
    }
    
    /// Kullanıcının aktif aboneliği var mı?
    var hasActiveSubscription: Bool {
        !activeSubscriptions.isEmpty
    }
    
    /// Belirli bir ürün aktif mi?
    func isSubscribed(to productID: ProductID) -> Bool {
        activeSubscriptions.contains(productID.rawValue)
    }
}

// MARK: - Store Error

enum StoreError: Error, LocalizedError {
    case failedVerification
    case unknownProduct
    case purchaseFailed
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Satın alma doğrulaması başarısız"
        case .unknownProduct:
            return "Ürün bulunamadı"
        case .purchaseFailed:
            return "Satın alma başarısız"
        }
    }
}

// MARK: - Product Extension

extension Product {
    /// Yıllık planda aylık tasarruf hesapla
    var monthlySavings: Decimal? {
        guard id == StoreManager.ProductID.proYearly.rawValue else { return nil }
        let monthlyPrice = price / 12
        // Aylık planın fiyatını varsayalım (örnek: 49.99)
        let assumedMonthlyPrice = Decimal(49.99)
        return (assumedMonthlyPrice - monthlyPrice) * 12
    }
    
    /// Aylık fiyat (yıllık plan için)
    var monthlyEquivalent: Decimal? {
        guard id == StoreManager.ProductID.proYearly.rawValue else { return nil }
        return price / 12
    }
}
