# StoreKit Test Yapılandırması

Bu dosya, SubTracker Pro özelliklerini local olarak test etmek için gerekli adımları içerir.

## 1️⃣ StoreKit Configuration Dosyasını Xcode'a Ekleyin

1. **Xcode'da projeyi açın**
2. **File > Add Files to "SubTracker"...** seçin
3. `SubTracker.storekit` dosyasını seçin ve **Add** butonuna tıklayın

## 2️⃣ StoreKit Configuration'ı Aktif Edin

1. **Product > Scheme > Edit Scheme...** menüsüne gidin (veya `⌘ + <`)
2. Sol panelden **Run** seçin
3. Sağ panelde **Options** tabına tıklayın
4. **StoreKit Configuration** dropdown'ından **SubTracker.storekit** seçin
5. **Close** butonuna tıklayın

## 3️⃣ Uygulamayı Çalıştırın

Artık uygulamayı simulator veya cihazda çalıştırdığınızda:
- ✅ Ürünler yüklenecek
- ✅ Satın alma işlemleri test edilebilecek
- ✅ 7 günlük ücretsiz deneme aktif olacak
- ✅ Restore işlemi çalışacak

## 💰 Test Fiyatları

- **Aylık Plan**: $2.99/ay
- **Yıllık Plan**: $29.00/yıl (%19 tasarruf)
- **Deneme Süresi**: İlk 7 gün ücretsiz

## 🔍 Test İpuçları

### StoreKit Test Konsolu
Xcode'da çalışırken **Debug > StoreKit > Manage Transactions** ile:
- Aktif abonelikleri görüntüleyin
- Abonelikleri iptal edin
- Yenileme tarihlerini değiştirin
- Fiyat artışlarını test edin

### Sandbox Test Kullanıcısı (Opsiyonel)
App Store Connect'te gerçek test yapmak için:
1. App Store Connect > Users and Access > Sandbox Testers
2. Yeni test kullanıcısı oluşturun
3. Cihazda App Store'dan çıkış yapın
4. Uygulamada satın alma yaparken sandbox kullanıcısı ile giriş yapın

## ⚠️ Önemli Notlar

- StoreKit Configuration **sadece local test** içindir
- App Store'a yüklemeden önce **gerçek Product ID'leri** App Store Connect'te oluşturmanız gerekir
- Gerçek cihazda test için **Sandbox kullanıcısı** veya **TestFlight** kullanın

## 📱 Pro Özellikleri

Test edebileceğiniz Pro özellikler:
- ✨ iCloud Senkronizasyonu
- 📊 Gelişmiş Raporlar (Kategori Dağılımı)
- 🎨 Premium Temalar
- 🔔 Geniş Bildirim Ufku (30 güne kadar)

## 🐛 Sorun Giderme

### "Ürünler yüklenemedi" hatası alıyorum
- ✅ StoreKit Configuration'ın scheme'de aktif olduğundan emin olun
- ✅ Uygulamayı tamamen durdurup yeniden çalıştırın
- ✅ Simulator'ü restart edin

### Satın alma işlemi tamamlanmıyor
- StoreKit Console'da transaction'ı manuel olarak approve edin
- Product ID'lerin doğru olduğundan emin olun

### Pro özellikleri açılmıyor
- Settings > Pro Ayarları'nda "Restore Purchases" butonuna tıklayın
- StoreManager'ın `isProUser` property'sini kontrol edin
