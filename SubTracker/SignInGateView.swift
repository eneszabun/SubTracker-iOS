import SwiftUI
import AuthenticationServices

struct SignInGateView: View {
    @ObservedObject var auth: AuthViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // App Icon/Logo
            VStack(spacing: 12) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)
                
                Text("SubTracker")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)
            }
            .padding(.bottom, 20)
            
            // Başlık ve Açıklama
            VStack(spacing: 12) {
                Text("Aboneliklerinizi Takip Edin")
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                
                Text("Tüm aboneliklerinizi tek yerden yönetin, hatırlatmalar alın ve harcamalarınızı kontrol edin.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
            }
            .padding(.bottom, 20)

            // Sign in with Apple Button
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                auth.handleCompletion(result)
            }
            .frame(height: 50)
            .padding(.horizontal, 32)
            .signInWithAppleButtonStyle(.black)
            
            // iCloud Senkronizasyon Bilgisi
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 14))
                Text("iCloud ile tüm cihazlarınızda senkronize")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 32)
            
            // Divider
            HStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 1)
                Text("veya")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 8)
            
            // Üye Olmadan Devam Et Button
            Button {
                auth.continueAsGuest()
            } label: {
                HStack {
                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 16))
                    Text("Üye Olmadan Devam Et")
                        .font(.system(size: 17, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.secondary.opacity(0.1))
                .foregroundStyle(.primary)
                .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            
            // Guest Mode Uyarısı
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                    Text("Misafir modunda verileriniz sadece bu cihazda saklanır")
                        .font(.system(size: 12))
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 32)
            
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
