# Xcode'da App Intents Kurulumu

Bu dosya, Siri Kısayolları özelliğinin Xcode'da aktif edilmesi için gerekli adımları içerir.

## 📁 Dosyaları Projeye Ekleme

### 1️⃣ AppIntents Klasörünü Ekle

1. **Xcode'da projeyi açın**
2. Sol panelde **SubTracker** klasörüne sağ tıklayın
3. **New Group** seçin ve adını **AppIntents** yapın
4. Finder'da oluşturduğumuz dosyaları sürükleyip bu gruba bırakın:
   - `GetMonthlyTotalIntent.swift`
   - `GetUpcomingRenewalsIntent.swift`
   - `GetSubscriptionsIntent.swift`
   - `SubTrackerAppShortcuts.swift`

**VEYA** terminalde:

```bash
# Xcode projesini yeniden oluştur
cd /Users/enessefazabun/Codes/SubTracker-iOS
xcodebuild -list
```

### 2️⃣ Dosyaların Target'a Eklendiğinden Emin Olun

Her dosya için:
1. Dosyayı seçin
2. Sağ panelde **File Inspector**'ı açın
3. **Target Membership** bölümünde **SubTracker** işaretli olmalı

## 🔧 Xcode Build Ayarları

### Info.plist Güncelleme (Otomatik)

iOS 16+ projelerinde App Intents otomatik olarak keşfedilir, manuel Info.plist girişi gerekmez.

Eğer gerekirse:
1. **SubTracker** target'ını seçin
2. **Info** sekmesine gidin
3. **+** butonuna tıklayın
4. `NSUserActivityTypes` ekleyin (genellikle otomatik eklenir)

### Capabilities Kontrolü

1. Xcode'da **SubTracker** target'ını seçin
2. **Signing & Capabilities** sekmesine gidin
3. **Siri** capability'sinin ekli olduğundan emin olun
   - Yoksa **+ Capability** butonuna tıklayın
   - **Siri** seçin

## 🧪 Test Etme

### Simülatörde Test

1. Uygulamayı simülatörde çalıştırın
2. Simülatörde **Siri** tetikleyin:
   - macOS: `Hardware > Siri` menüsü (veya `Cmd + S`)
   - Ya da simulator toolbar'daki Siri butonu
3. Komutları deneyin:
   - *"SubTracker'da aylık harcamam ne kadar?"*

### Fiziksel Cihazda Test

1. Uygulamayı cihaza yükleyin
2. Uygulamayı en az bir kez açın (intent'ler kaydolması için)
3. Ana ekrana dönün
4. Siri'yi aktive edin ve komutları deneyin

### Shortcuts Uygulamasında Test

1. **Kısayollar** uygulamasını açın
2. **Galeri** sekmesine gidin
3. "SubTracker" araması yapın
4. Kısayolları görmelisiniz

## 🐛 Sorun Giderme

### "Intent not found" hatası
**Çözüm:**
- Clean Build: `Cmd + Shift + K`
- Build Folder'ı temizle: `Cmd + Option + Shift + K`
- Derived Data sil: `~/Library/Developer/Xcode/DerivedData/SubTracker-*`
- Projeyi yeniden build edin

### Siri kısayolları görünmüyor
**Çözüm:**
- Uygulamayı cihazda en az bir kez çalıştırın
- Cihazı yeniden başlatın
- **Ayarlar > Siri ve Arama > SubTracker** kontrol edin

### Build hatası: "Cannot find type 'AppIntent'"
**Çözüm:**
- Deployment Target'ı iOS 16.0 veya üzeri yapın
- `import AppIntents` satırının mevcut olduğundan emin olun

### "Unexpected error occurred" Siri'de
**Çözüm:**
- Core Data stack'in başlatıldığından emin olun
- En az bir abonelik eklediğinizden emin olun
- Console log'larını kontrol edin (Xcode'da çalışırken)

## 📋 Kontrol Listesi

Build yapmadan önce:
- [ ] Tüm `.swift` dosyaları SubTracker target'ına ekli
- [ ] `import AppIntents` her intent dosyasında mevcut
- [ ] `import SwiftUI` snippet view'ları için mevcut
- [ ] Deployment Target iOS 16.0+
- [ ] Siri capability eklendi
- [ ] Clean build yapıldı

Uygulama çalıştıktan sonra:
- [ ] Uygulama en az bir kez açıldı
- [ ] Core Data çalışıyor
- [ ] En az bir abonelik var (test için)
- [ ] Kısayollar uygulamasında görünüyor
- [ ] Siri komutları yanıt veriyor

## 🎯 Örnek Komutlar (Test İçin)

```
"SubTracker'da aylık harcamam ne kadar?"
→ Beklenen: Toplam aylık tutar ve aktif abonelik sayısı

"SubTracker'da yaklaşan yenilemelerim"
→ Beklenen: 7 gün içinde yenilenecek abonelikler

"SubTracker'da aboneliklerimi göster"
→ Beklenen: Tüm aktif abonelik listesi
```

## 📱 Deployment

App Store'a yüklerken:
- ✅ App Intents otomatik olarak paketlenir
- ✅ Siri capability Info.plist'e eklenir
- ✅ Privacy kullanımı açıklaması gerekli değil (sadece yerel veri)

---

**Not:** App Intents iOS 16+ özelliğidir. Daha eski sürümler için graceful degradation yapılmıştır.
