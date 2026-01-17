import Foundation

/// Döviz kuru dönüştürme servisi
/// Farklı para birimlerindeki tutarları varsayılan para birimine çevirir
actor CurrencyConverter {
    static let shared = CurrencyConverter()
    
    /// Sabit döviz kurları (USD bazlı)
    /// Gerçek uygulamada API'den güncel kurlar çekilebilir
    private var exchangeRates: [String: Double] = [
        "USD": 1.0,
        "EUR": 0.92,
        "GBP": 0.79,
        "TRY": 34.5
    ]
    
    /// Son güncelleme tarihi
    private var lastUpdated: Date = Date()
    
    /// Kurları güncelle (API'den çekmek için hazır altyapı)
    func updateRates() async {
        // TODO: Gerçek API entegrasyonu için
        // Şimdilik sabit kurları kullanıyoruz
        lastUpdated = Date()
    }
    
    /// Bir tutarı kaynak para biriminden hedef para birimine çevirir
    /// - Parameters:
    ///   - amount: Dönüştürülecek tutar
    ///   - from: Kaynak para birimi kodu (örn: "USD")
    ///   - to: Hedef para birimi kodu (örn: "TRY")
    /// - Returns: Dönüştürülmüş tutar
    func convert(_ amount: Double, from sourceCurrency: String, to targetCurrency: String) -> Double {
        // Aynı para birimi ise dönüşüm yok
        if sourceCurrency == targetCurrency {
            return amount
        }
        
        // Kaynak ve hedef kurları al
        guard let sourceRate = exchangeRates[sourceCurrency],
              let targetRate = exchangeRates[targetCurrency] else {
            // Bilinmeyen para birimi, olduğu gibi döndür
            return amount
        }
        
        // Önce USD'ye çevir, sonra hedef para birimine
        let amountInUSD = amount / sourceRate
        let amountInTarget = amountInUSD * targetRate
        
        return amountInTarget
    }
    
    /// Birden fazla aboneliğin toplam tutarını hedef para birimine çevirir
    func convertTotal(subscriptions: [Subscription], to targetCurrency: String, monthly: Bool = true) -> Double {
        subscriptions.reduce(0) { total, subscription in
            guard subscription.isActive else { return total }
            let amount = monthly ? subscription.monthlyCost : subscription.amount
            let converted = convert(amount, from: subscription.currency, to: targetCurrency)
            return total + converted
        }
    }
    
    /// Para birimi sembolünü döndürür
    static func symbol(for currencyCode: String) -> String {
        switch currencyCode {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "TRY": return "₺"
        default: return currencyCode
        }
    }
    
    /// Desteklenen para birimleri
    static let supportedCurrencies = ["USD", "EUR", "GBP", "TRY"]
    
    /// Kur bilgisini formatlanmış şekilde döndürür
    func rateInfo(from sourceCurrency: String, to targetCurrency: String) -> String {
        let rate = convert(1.0, from: sourceCurrency, to: targetCurrency)
        let sourceSymbol = CurrencyConverter.symbol(for: sourceCurrency)
        let targetSymbol = CurrencyConverter.symbol(for: targetCurrency)
        return "1 \(sourceSymbol) = \(String(format: "%.2f", rate)) \(targetSymbol)"
    }
}

// MARK: - Subscription Extension for Currency Conversion

extension Subscription {
    /// Aboneliğin tutarını belirtilen para birimine çevirir (senkron versiyon, sabit kurlarla)
    func convertedAmount(to targetCurrency: String) -> Double {
        CurrencyConverterSync.shared.convert(amount, from: currency, to: targetCurrency)
    }
    
    /// Aylık maliyeti belirtilen para birimine çevirir
    func convertedMonthlyCost(to targetCurrency: String) -> Double {
        CurrencyConverterSync.shared.convert(monthlyCost, from: currency, to: targetCurrency)
    }
}

// MARK: - Synchronous Currency Converter (for UI)

/// UI'da kullanım için senkron döviz çevirici
class CurrencyConverterSync {
    static let shared = CurrencyConverterSync()
    
    private let exchangeRates: [String: Double] = [
        "USD": 1.0,
        "EUR": 0.92,
        "GBP": 0.79,
        "TRY": 34.5
    ]
    
    func convert(_ amount: Double, from sourceCurrency: String, to targetCurrency: String) -> Double {
        if sourceCurrency == targetCurrency {
            return amount
        }
        
        guard let sourceRate = exchangeRates[sourceCurrency],
              let targetRate = exchangeRates[targetCurrency] else {
            return amount
        }
        
        let amountInUSD = amount / sourceRate
        return amountInUSD * targetRate
    }
    
    func convertTotal(subscriptions: [Subscription], to targetCurrency: String, monthly: Bool = true) -> Double {
        subscriptions.reduce(0) { total, subscription in
            guard subscription.isActive else { return total }
            let amount = monthly ? subscription.monthlyCost : subscription.amount
            let converted = convert(amount, from: subscription.currency, to: targetCurrency)
            return total + converted
        }
    }
}

// MARK: - Array Extension for Converted Totals

extension Array where Element == Subscription {
    /// Tüm aboneliklerin aylık toplamını belirtilen para birimine çevirir
    func convertedMonthlyTotal(to targetCurrency: String) -> Double {
        CurrencyConverterSync.shared.convertTotal(subscriptions: self, to: targetCurrency, monthly: true)
    }
    
    /// Tüm aboneliklerin yıllık toplamını belirtilen para birimine çevirir
    func convertedYearlyTotal(to targetCurrency: String) -> Double {
        convertedMonthlyTotal(to: targetCurrency) * 12
    }
}
