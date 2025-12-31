import SwiftUI
import AuthenticationServices

final class AuthViewModel: ObservableObject {
    @AppStorage("userIdentifier") private var userIdentifier: String?
    @AppStorage("userDisplayName") private var userDisplayName: String?
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

    func handleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                userIdentifier = credential.user
                let nameParts = [credential.fullName?.givenName, credential.fullName?.familyName].compactMap { $0 }
                if !nameParts.isEmpty {
                    userDisplayName = nameParts.joined(separator: " ")
                } else if let email = credential.email, !email.isEmpty {
                    userDisplayName = email
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
