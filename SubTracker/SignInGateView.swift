import SwiftUI
import AuthenticationServices

struct SignInGateView: View {
    @ObservedObject var auth: AuthViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
            Text("Devam etmek için Apple ile giriş yap")
                .font(.title3.bold())
            Text("Abonelik verilerin seninle eşleşsin ve cihazın değişse bile senkronize kalsın.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                auth.handleCompletion(result)
            }
            .frame(height: 50)
            .padding(.horizontal, 32)
            .signInWithAppleButtonStyle(.black)
            .alert("Giriş başarısız", isPresented: .constant(auth.lastError != nil), actions: {
                Button("Kapat") {
                    auth.lastError = nil
                }
            }, message: {
                Text(auth.lastError ?? "Bilinmeyen hata")
            })

            Spacer()
        }
        .padding()
    }
}
