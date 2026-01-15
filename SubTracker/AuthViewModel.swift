import SwiftUI
import AuthenticationServices

final class AuthViewModel: ObservableObject {
    @AppStorage("userIdentifier") private var userIdentifier: String?
    @AppStorage("userDisplayName") var userDisplayName: String?
    @Published var lastError: String?

    var isSignedIn: Bool {
        userIdentifier != nil
    }

    var displayName: String {
        if let userDisplayName, !userDisplayName.isEmpty {
            return userDisplayName
        }
        if let userIdentifier, !userIdentifier.isEmpty {
            let suffix = String(userIdentifier.suffix(4))
            return "Apple Kullanıcısı \(suffix)"
        }
        return "Apple Kullanıcısı"
    }
    
    func updateDisplayName(_ name: String) {
        userDisplayName = name.trimmingCharacters(in: .whitespaces)
    }

    func handleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                userIdentifier = credential.user
                
                // Apple'dan gelen ismi al (sadece ilk girişte gelir)
                if let fullName = credential.fullName {
                    // PersonNameComponentsFormatter ile düzgün formatlama
                    let formatter = PersonNameComponentsFormatter()
                    formatter.style = .default
                    let formattedName = formatter.string(from: fullName)
                    
                    // Eğer formatter boş string döndürdüyse, manuel olarak birleştir
                    if !formattedName.trimmingCharacters(in: .whitespaces).isEmpty {
                        userDisplayName = formattedName
                    } else {
                        // Manuel birleştirme
                        let nameParts = [
                            fullName.givenName,
                            fullName.familyName
                        ].compactMap { $0?.trimmingCharacters(in: .whitespaces) }
                         .filter { !$0.isEmpty }
                        
                        if !nameParts.isEmpty {
                            userDisplayName = nameParts.joined(separator: " ")
                        }
                    }
                }
                
                // İsim hala boşsa ve email varsa, email'i kullan
                if (userDisplayName ?? "").isEmpty, let email = credential.email, !email.isEmpty {
                    // Email'in @ öncesi kısmını kullan
                    let emailName = email.components(separatedBy: "@").first ?? email
                    userDisplayName = emailName
                }
                
                lastError = nil
            }
        case .failure:
            lastError = "Giriş tamamlanamadı. Lütfen tekrar deneyin."
        }
    }

    func signOut() {
        userIdentifier = nil
        userDisplayName = nil
        lastError = nil
    }
}
