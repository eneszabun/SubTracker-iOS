import Foundation
import UIKit

/// App-wide constants and configuration
struct AppConstants {
    
    // MARK: - Legal URLs
    
    /// Privacy Policy URL - IMPORTANT: Replace with your actual URL before production
    static let privacyPolicyURL = "https://eneszabun.github.io/SubTracker-iOS/privacy-policy.html"
    
    /// Terms of Service URL - IMPORTANT: Replace with your actual URL before production
    static let termsOfServiceURL = "https://eneszabun.github.io/SubTracker-iOS/terms-of-service.html"
    
    /// Support URL - Web support page
    static let supportURL = "https://eneszabun.github.io/SubTracker-iOS/support.html"
    
    // MARK: - App Store
    
    /// App Store URL (will be available after first submission)
    static let appStoreURL = "https://apps.apple.com/app/idYOUR_APP_ID"
    
    // MARK: - App Information
    
    static let appName = "SubTracker"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    // MARK: - Contact
    
    static let supportEmail = "enes.sefa.zabun@icloud.com"
    static let developerName = "Enes Sefa ZABUN"
    
    // MARK: - Product IDs (must match App Store Connect)
    
    static let proMonthlyProductID = "com.subtracker.pro.monthly"
    static let proYearlyProductID = "com.subtracker.pro.yearly"
}

// MARK: - URL Helpers

extension AppConstants {
    
    /// Open Privacy Policy in Safari
    static func openPrivacyPolicy() {
        guard let url = URL(string: privacyPolicyURL) else { return }
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #endif
    }
    
    /// Open Terms of Service in Safari
    static func openTermsOfService() {
        guard let url = URL(string: termsOfServiceURL) else { return }
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #endif
    }
    
    /// Open Support (email or web)
    static func openSupport() {
        guard let url = URL(string: supportURL) else { return }
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #endif
    }
    
    /// Open App Store page (for rating)
    static func openAppStore() {
        guard let url = URL(string: appStoreURL) else { return }
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #endif
    }
}
