# 📋 App Store Yayınlama Hızlı Checklist

Bu checklist'i yazdırabilir veya her adımı tamamladıkça işaretleyebilirsiniz.

---

## 1️⃣ Yasal Hazırlıklar

### Privacy Policy & Terms of Service
- [X] `PRIVACY_POLICY_TEMPLATE.md` dosyasını aç
- [X] `[BÜYÜK HARFLERLE]` yazılmış yerleri kendi bilgilerinle doldur
- [X] Tarihi güncelle (Last Updated)
- [X] GitHub Pages / Notion / web sitene yükle
- [X] URL'i not et: `______________________________`

- [X] `TERMS_OF_SERVICE_TEMPLATE.md` dosyasını aç  
- [X] `[BÜYÜK HARFLERLE]` yazılmış yerleri kendi bilgilerinle doldur
- [X] Tarihi güncelle (Last Updated)
- [X] Aynı yere yükle (Privacy Policy ile aynı domain)
- [X] URL'i not et: `______________________________`

### AppConstants.swift Güncelleme
- [X] `SubTracker/AppConstants.swift` dosyasını aç
- [X] `privacyPolicyURL` = gerçek URL'nizi yazın
- [X] `termsOfServiceURL` = gerçek URL'nizi yazın
- [X] `supportURL` = gerçek email/URL'nizi yazın
- [X] Kaydet ve commit et

---

## 2️⃣ Xcode Ayarları

### StoreKit Configuration Kaldırma
- [ ] Xcode'u aç
- [ ] Product → Scheme → Edit Scheme
- [ ] Run → Options
- [ ] StoreKit Configuration: **None** seç
- [ ] Close

### Code Signing
- [ ] Project → SubTracker target → Signing & Capabilities
- [ ] Automatically manage signing ✅
- [ ] Team seç: `______________________________`
- [ ] Widget target için tekrarla

---

## 3️⃣ App Store Connect

### Uygulama Kaydı
- [ ] https://appstoreconnect.apple.com → My Apps → (+)
- [ ] Platform: iOS
- [ ] Name: SubTracker (veya tercih ettiğiniz)
- [ ] Language: Turkish
- [ ] Bundle ID: `com.enesse.SubTracker`
- [ ] SKU: `SUBTRACKER-IOS-001`

### App Information
- [ ] Primary Category: **Finance**
- [ ] Secondary Category: **Productivity**
- [ ] Privacy Policy URL: `______________________________`
- [ ] Terms URL: `______________________________`
- [ ] Support URL: `______________________________`

### Pricing & Availability
- [ ] Price: **Free**
- [ ] Availability: Tüm ülkeler ✅

---

## 4️⃣ Screenshots (Minimum 3 adet gerekli)

### 6.7" iPhone için (Zorunlu)
- [ ] Screenshot 1: Ana ekran (abonelik listesi)
- [ ] Screenshot 2: Abonelik detay sayfası
- [ ] Screenshot 3: Özet/istatistikler

### Opsiyonel
- [ ] Screenshot 4: Pro özellikleri ekranı
- [ ] Screenshot 5: Widget gösterimi

**Not:** Hotpot.ai veya App Mockup ile güzelleştir

---

## 5️⃣ Metadata

### App Name & Subtitle
- [ ] Name: `SubTracker - Abonelik Takibi`
- [ ] Subtitle: `Aboneliklerinizi Takip Edin`

### Description
- [ ] `PRODUCTION_DEPLOYMENT_GUIDE.md`'deki açıklamayı kopyala-yapıştır
- [ ] Gerekirse özelleştir

### Keywords
- [ ] `abonelik,takip,hatırlatma,netflix,spotify,harcama,bütçe,finans,para`

### Promotional Text
- [ ] `Aboneliklerinizi takip edin, gereksiz harcamalardan kurtulun. 7 gün ücretsiz Pro deneyin!`

---

## 6️⃣ Archive & Upload

### Archive Oluşturma
- [ ] Xcode'da **Any iOS Device (arm64)** seç
- [ ] Product → Clean Build Folder (⌘⇧K)
- [ ] Product → Archive (⌘⇧B ile test)
- [ ] Organizer açılır
- [ ] **Validate App** çalıştır
- [ ] Hatalar varsa düzelt

### Upload
- [ ] **Distribute App** → App Store Connect
- [ ] Upload seç
- [ ] Export Compliance:
  - Uses Encryption: **YES**
  - Exempt: **YES**
- [ ] Upload (5-15 dakika)
- [ ] Email bekle: "Build processed"

---

## 7️⃣ In-App Purchases

**Not:** Build upload'dan SONRA yapabilirsiniz

### Subscription Group
- [ ] App Store Connect → IAP → Create Subscription Group
- [ ] Name: `SubTracker Pro`

### Aylık Abonelik
- [ ] Create Subscription
- [ ] Product ID: `com.subtracker.pro.monthly`
- [ ] Duration: 1 Month
- [ ] Price: ₺39.99 (Tier 13)
- [ ] Free Trial: 7 Days
- [ ] Turkish localization doldur
- [ ] English localization doldur
- [ ] Screenshot yükle

### Yıllık Abonelik  
- [ ] Create Subscription
- [ ] Product ID: `com.subtracker.pro.yearly`
- [ ] Duration: 1 Year
- [ ] Price: ₺299.99 (Tier 99)
- [ ] Free Trial: 7 Days
- [ ] Turkish localization doldur
- [ ] English localization doldur
- [ ] Screenshot yükle

---

## 8️⃣ TestFlight (Önerilir)

### Internal Testing
- [ ] TestFlight → Internal Testing → Create Group
- [ ] Kendinizi tester olarak ekle
- [ ] Build'i assign et
- [ ] iPhone'da TestFlight app'i indir
- [ ] SubTracker'ı yükle

### Test Kontrolleri
- [ ] Apple Sign In çalışıyor
- [ ] Abonelik ekleme/düzenleme/silme çalışıyor
- [ ] Bildirimler çalışıyor
- [ ] Widget görünüyor
- [ ] Pro satın alma test edildi (Sandbox kullanıcı)
- [ ] iCloud sync test edildi (iki cihazda)
- [ ] Siri shortcuts çalışıyor

---

## 9️⃣ App Review Submission

### Version Info
- [ ] App Store Connect → SubTracker → (+) Version
- [ ] Version: 1.0
- [ ] Release notes yaz (guide'dan kopyala)
- [ ] Build seç

### IAP Ekleme
- [ ] Monthly subscription ekle
- [ ] Yearly subscription ekle

### App Review Information
- [ ] Contact info doldur:
  - Name: `______________________________`
  - Email: `______________________________`
  - Phone: `______________________________`

- [ ] Review notes yaz (guide'dan kopyala)

### Final Checks
- [ ] Screenshots yüklendi (min 3 adet)
- [ ] Description dolduruldu
- [ ] Keywords eklendi
- [ ] Privacy URL eklendi
- [ ] Support URL eklendi
- [ ] Advertising Identifier: NO
- [ ] Content Rights: ✅

### 🚀 Submit!
- [ ] **Submit for Review** butonuna tıkla
- [ ] Onay bekle (24-48 saat)

---

## 🎉 Yayın Sonrası

- [ ] Review onaylandı email'i geldi
- [ ] App Store'da yayınlandı
- [ ] Arkadaşlara/sosyal medyaya duyuru yap
- [ ] İlk yorumları/indirmeleri takip et
- [ ] Analytics'i kontrol et

---

## 📞 Yardım Gerekirse

- Apple Developer Forums
- Stack Overflow
- App Store Connect Help: help.apple.com/app-store-connect/

---

**Başarılar! 🎊**

**Checklist tamamlandığında:** Uygulamanız App Store'da yayında!

---

## Önemli Notlar

- ⏰ Review süresi: 24-48 saat (ortalama 1 gün)
- 📧 Email bildirimlerini takip edin
- ❌ Red edilirse: Sorunu düzeltin ve tekrar submit edin
- ✅ Onaylandıktan sonra: App Store'da görünmesi 24 saat sürebilir
- 💰 IAP'ler: İlk satın alma 48 saat içinde raporlanır

---

**Not:** Detaylı açıklamalar için `PRODUCTION_DEPLOYMENT_GUIDE.md` dosyasına bakın.
