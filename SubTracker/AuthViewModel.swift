import SwiftUI
import AuthenticationServices
import Security

// MARK: - Keychain Helper
private enum KeychainHelper {
    static let service = "com.enesse.SubTracker"
    
    static func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        // Önce mevcut değeri sil
        delete(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Auth View Model
final class AuthViewModel: ObservableObject {
    private static let userIdKey = "apple_user_id"
    private static let userNameKey = "apple_user_name"
    
    @Published var lastError: String?
    
    private var cachedUserId: String?
    private var cachedUserName: String?
    
    init() {
        // Önce Keychain'den değerleri yükle
        cachedUserId = KeychainHelper.load(key: Self.userIdKey)
        cachedUserName = KeychainHelper.load(key: Self.userNameKey)
        
        // AppStorage'dan Keychain'e migration (eski kullanıcılar için)
        migrateFromAppStorage()
    }
    
    private func migrateFromAppStorage() {
        let defaults = UserDefaults.standard
        
        // Eski userIdentifier varsa ve Keychain'de yoksa, migrate et
        if cachedUserId == nil, let oldUserId = defaults.string(forKey: "userIdentifier"), !oldUserId.isEmpty {
            cachedUserId = oldUserId
            KeychainHelper.save(key: Self.userIdKey, value: oldUserId)
            // Eski veriyi temizle
            defaults.removeObject(forKey: "userIdentifier")
        }
        
        // Eski userDisplayName varsa ve Keychain'de yoksa, migrate et
        if cachedUserName == nil, let oldUserName = defaults.string(forKey: "userDisplayName"), !oldUserName.isEmpty {
            cachedUserName = oldUserName
            KeychainHelper.save(key: Self.userNameKey, value: oldUserName)
            // Eski veriyi temizle
            defaults.removeObject(forKey: "userDisplayName")
        }
    }

    var isSignedIn: Bool {
        cachedUserId != nil
    }
    
    var userDisplayName: String? {
        get { cachedUserName }
        set {
            cachedUserName = newValue
            if let name = newValue {
                KeychainHelper.save(key: Self.userNameKey, value: name)
            } else {
                KeychainHelper.delete(key: Self.userNameKey)
            }
            objectWillChange.send()
        }
    }

    var displayName: String {
        if let cachedUserName, !cachedUserName.isEmpty {
            return cachedUserName
        }
        if let cachedUserId, !cachedUserId.isEmpty {
            let suffix = String(cachedUserId.suffix(4))
            return "Apple Kullanıcısı \(suffix)"
        }
        return "Apple Kullanıcısı"
    }
    
    func updateDisplayName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        userDisplayName = trimmed.isEmpty ? nil : trimmed
    }

    func handleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                // User ID'yi kaydet
                cachedUserId = credential.user
                KeychainHelper.save(key: Self.userIdKey, value: credential.user)
                
                // Apple'dan gelen ismi al (sadece ilk girişte gelir)
                // Eğer zaten kayıtlı bir isim varsa, üzerine yazma
                if cachedUserName == nil || cachedUserName?.isEmpty == true {
                    if let fullName = credential.fullName {
                        let extractedName = extractName(from: fullName)
                        if !extractedName.isEmpty {
                            userDisplayName = extractedName
                        }
                    }
                    
                    // İsim hala boşsa ve email varsa, email'i kullan
                    if (cachedUserName ?? "").isEmpty, let email = credential.email, !email.isEmpty {
                        let emailName = email.components(separatedBy: "@").first ?? email
                        userDisplayName = emailName
                    }
                }
                
                lastError = nil
                objectWillChange.send()
            }
        case .failure:
            lastError = "Giriş tamamlanamadı. Lütfen tekrar deneyin."
        }
    }
    
    private func extractName(from fullName: PersonNameComponents) -> String {
        // PersonNameComponentsFormatter ile düzgün formatlama
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .default
        let formattedName = formatter.string(from: fullName).trimmingCharacters(in: .whitespaces)
        
        if !formattedName.isEmpty {
            return formattedName
        }
        
        // Manuel birleştirme
        let nameParts = [
            fullName.givenName,
            fullName.familyName
        ].compactMap { $0?.trimmingCharacters(in: .whitespaces) }
         .filter { !$0.isEmpty }
        
        return nameParts.joined(separator: " ")
    }

    func signOut() {
        KeychainHelper.delete(key: Self.userIdKey)
        KeychainHelper.delete(key: Self.userNameKey)
        cachedUserId = nil
        cachedUserName = nil
        lastError = nil
        objectWillChange.send()
    }
}
