# SubTracker Production Deployment Guide

Bu kılavuz, SubTracker uygulamasını App Store'da yayınlamak için tamamlanması gereken adımları içerir.

## ✅ Tamamlanan Kod Değişiklikleri

Aşağıdaki kod değişiklikleri otomatik olarak tamamlanmıştır:

1. ✅ **AppConstants.swift oluşturuldu** - Legal URL'ler ve uygulama sabitleri
2. ✅ **Info.plist güncellendi** - Bildirim izin açıklamaları eklendi
3. ✅ **SettingsView güncellendi** - Yasal doküman linkleri eklendi (Privacy Policy, Terms, Support)
4. ✅ **App Icon kontrolü** - Tüm gerekli boyutlar mevcut

## 🚨 ÖNEMLİ: URL'leri Güncelleyin

**HEMEN YAPIN:** `SubTracker/AppConstants.swift` dosyasını açın ve placeholder URL'leri gerçek URL'lerinizle değiştirin:

```swift
// ŞURAYI DEĞİŞTİRİN:
static let privacyPolicyURL = "https://yourdomain.com/subtracker/privacy"
static let termsOfServiceURL = "https://yourdomain.com/subtracker/terms"
static let supportURL = "mailto:support@yourdomain.com"
```

---

## 📋 Yapılması Gereken Manuel Adımlar

### 1️⃣ Privacy Policy ve Terms of Service Oluşturma

**Öncelik: YÜKSEKAğırlık: 🔴 Zorunlu**

#### Online Araçlar ile Oluşturma (Önerilen)

1. **Privacy Policy için:**
   - [PrivacyPolicies.com](https://www.privacypolicies.com/live/create/privacy-policy) veya
   - [Termly.io](https://termly.io/products/privacy-policy-generator/)
   
2. **Aşağıdaki bilgileri içermelidir:**
   - ✅ Uygulama adı: SubTracker
   - ✅ Toplanan veriler:
     * Apple Sign In ile kullanıcı adı/email
     * Yerel cihazda Core Data ile abonelik verileri
     * iCloud senkronizasyonu (opsiyonel)
     * Bildirim izinleri
   - ✅ Üçüncü parti servisler: YOK (hiç analytics/tracking yok)
   - ✅ Veri saklama: Sadece kullanıcının cihazında
   - ✅ GDPR/KVKK uyumu
   - ✅ Kullanıcı hakları (veri silme talebi)

3. **Terms of Service için:**
   - Pro abonelik koşulları
   - 7 günlük deneme süresi
   - İptal ve iade politikası (Apple'ın standart politikası)
   - Kullanım sınırları

#### Nereye Yükleyin?

**Ücretsiz seçenekler:**
- **GitHub Pages** (önerilen)
- **Notion** (Public page olarak yayınlayın)
- **Google Sites**
- Kendi web siteniz varsa orada

**URL formatı:**
```
https://yourusername.github.io/subtracker/privacy
https://yourusername.github.io/subtracker/terms
```

#### AppConstants.swift'i Güncelleyin

Dokümanları yükledikten sonra:

```swift
// SubTracker/AppConstants.swift
static let privacyPolicyURL = "https://GERÇEK_URL/privacy"
static let termsOfServiceURL = "https://GERÇEK_URL/terms"
static let supportURL = "mailto:GERÇEK_EMAIL@domain.com"
```

---

### 2️⃣ Xcode Scheme'den StoreKit Configuration Kaldırma

**Öncelik: YÜKSEK**
**Ağırlık: 🔴 Zorunlu (Production için)**

**Neden:** Test StoreKit configuration production'da kullanılmamalı, gerçek App Store API kullanılmalı.

**Adımlar:**

1. Xcode'u açın
2. Menüden: **Product → Scheme → Edit Scheme...** (veya `⌘ + <`)
3. Sol panelden **Run** seçin
4. Sağ panelde **Options** tab'ına tıklayın
5. **StoreKit Configuration** dropdown'ından **None** seçin
6. **Close** butonuna tıklayın

**Doğrulama:**
- Build yapın ve gerçek cihazda test edin
- Pro özellikler satın alma ekranı açılmalı (test ürünleri değil, gerçek ürünler)

---

### 3️⃣ App Store Connect Ayarları

**Öncelik: YÜKSEK**

#### 3.1 Uygulama Kaydı Oluşturma

1. [App Store Connect](https://appstoreconnect.apple.com)'e gidin
2. **My Apps → (+) butonu**
3. **New App** seçin

**Form Bilgileri:**
```
Platform: iOS
Name: SubTracker
Subtitle: Aboneliklerinizi Takip Edin
Primary Language: Turkish
Bundle ID: com.enesse.SubTracker (dropdown'dan seçin)
SKU: SUBTRACKER-IOS-001
User Access: Full Access
```

#### 3.2 App Information

1. App Store Connect → SubTracker → App Information

**Kategoriler:**
```
Primary Category: Finance
Secondary Category: Productivity
```

**Privacy Policy URL:** (Adım 1'de oluşturduğunuz)
```
https://your-url.com/subtracker/privacy
```

**Terms of Service URL:** (Opsiyonel ama önerilen)
```
https://your-url.com/subtracker/terms
```

**Support URL:** (Zorunlu)
```
mailto:support@youremail.com
```

#### 3.3 Pricing and Availability

```
Price: Free
Availability: Tüm ülkeler (veya istediğiniz ülkeler)
```

---

### 4️⃣ In-App Purchase (IAP) Ürünleri Oluşturma

**Öncelik: YÜKSEK**
**Not:** Önce bir build upload etmelisiniz, sonra IAP ekleyebilirsiniz.

#### 4.1 Subscription Group Oluşturma

1. App Store Connect → SubTracker → **In-App Purchases**
2. **Manage** (Subscriptions altında)
3. **Create** → Subscription Group
4. **Reference Name:** SubTracker Pro
5. **Group Name (Customer-facing):** SubTracker Pro

#### 4.2 Aylık Abonelik

1. Subscription Group içinde **Create Subscription** (veya + butonu)

```
Reference Name: SubTracker Pro Monthly
Product ID: com.subtracker.pro.monthly
Subscription Duration: 1 Month
```

**Pricing:**
```
Price: ₺39.99 (Tier 13 veya istediğiniz fiyat)
```

**Introductory Offer (7 gün ücretsiz deneme):**
```
Type: Free Trial
Duration: 7 Days
```

**Localization (Turkish):**
```
Display Name: SubTracker Pro Aylık
Description: Tüm Pro özelliklere aylık erişim
```

**Localization (English):**
```
Display Name: SubTracker Pro Monthly
Description: Monthly access to all Pro features
```

**Review Screenshot:**
- Pro özelliklerin gösterildiği bir ekran görüntüsü (Settings > Pro Upgrade ekranı)

#### 4.3 Yıllık Abonelik

Yukarıdaki adımları tekrarlayın:

```
Reference Name: SubTracker Pro Yearly
Product ID: com.subtracker.pro.yearly
Subscription Duration: 1 Year
Price: ₺299.99 (Tier 99 - %37 tasarruf)
Introductory Offer: 7 Days Free Trial
```

**Subscription Ranking:**
- Yıllık aboneliği üst sıraya yerleştirin (daha karlı)

---

### 5️⃣ Ekran Görüntüleri Hazırlama

**Öncelik: YÜKSEK**
**Ağırlık: 🔴 Zorunlu (En az 3 adet gerekli)**

#### Gerekli Boyutlar

**Minimum (zorunlu):**
- **6.7" Display (iPhone 14 Pro Max, 15 Pro Max):** 1290 x 2796 px

**Opsiyonel ama önerilen:**
- **6.5" Display (iPhone 11 Pro Max, XS Max):** 1284 x 2778 px
- **5.5" Display (iPhone 8 Plus):** 1242 x 2208 px

#### Önerilen Ekranlar

1. **Ana Ekran** - Abonelik listesi
2. **Abonelik Detay** - Bir aboneliğin detay sayfası
3. **Özet/İstatistikler** - Aylık/yıllık harcama grafiği
4. **Pro Özellikleri** - Pro upgrade ekranı
5. **Widget Gösterimi** - Ana ekran + widget beraber

#### Ekran Görüntüsü Alma

1. **Xcode Simulator'ı başlatın**
   ```
   Xcode → Open Developer Tool → Simulator
   Device → iPhone 15 Pro Max (6.7")
   ```

2. **Ekran görüntüsü alın**
   - `⌘ + S` veya
   - Simulator menü → File → Save Screen

3. **Dosyalar:** `~/Desktop/` klasörüne kaydedilir

#### Ekran Görüntülerini Güzelleştirme

**Online Araçlar:**
- [Hotpot.ai Screenshot Generator](https://hotpot.ai/templates/app-store-screenshot)
- [App Mockup](https://app-mockup.com)
- [Mockuphone](https://mockuphone.com)

**Manuel (Figma/Canva):**
- iPhone çerçevesi ekleyin
- Başlık ekleyin (örn: "Tüm Aboneliklerinizi Tek Yerden")
- Alt açıklama ekleyin
- Arka plan rengi/gradient

---

### 6️⃣ App Store Metadata

**Öncelik: YÜKSEK**

#### 6.1 App Name & Subtitle

```
Name: SubTracker - Abonelik Takibi
Subtitle: Aboneliklerinizi Takip Edin
```

#### 6.2 Description (Türkçe)

App Store Connect'te kullanın:

```
SubTracker ile tüm aboneliklerinizi tek yerden kolayca takip edin!

🎯 ÖZELLİKLER

• Abonelik Takibi: Netflix, Spotify, Apple Music gibi tüm aboneliklerinizi ekleyin
• Akıllı Hatırlatmalar: Yenileme tarihinden önce bildirim alın
• Maliyet Analizi: Aylık ve yıllık toplam harcamanızı görün
• Kategori Raporları: Hangi kategoride ne kadar harcadığınızı öğrenin
• Widget Desteği: Ana ekranınızda özet bilgi görün
• Siri Kısayolları: "SubTracker'da aylık harcamam ne kadar?" diye sorun
• Spotlight Arama: Sistem aramasından aboneliklerinizi bulun

💎 PRO ÖZELLİKLER

• iCloud Senkronu: Tüm cihazlarınızda aboneliklerinize erişin
• Gelişmiş Raporlar: Detaylı kategori ve trend analizleri
• Geniş Bildirim: 30 güne kadar önceden hatırlatma
• 7 Gün Ücretsiz Deneme

🔒 GİZLİLİK

• Tüm verileriniz cihazınızda güvende
• Üçüncü parti takip yok
• Apple Sign In ile güvenli giriş

Aboneliklerinizin kontrolünü elinize alın!
```

#### 6.3 Keywords (Anahtar Kelimeler)

**100 karakter limit, virgülle ayırın, BOŞLUK KULLANMAYIN:**

```
abonelik,takip,hatırlatma,netflix,spotify,harcama,bütçe,finans,para
```

#### 6.4 Promotional Text (170 karakter)

```
Aboneliklerinizi takip edin, gereksiz harcamalardan kurtulun. 7 gün ücretsiz Pro deneyin!
```

---

### 7️⃣ Archive Oluşturma ve Upload

**Öncelik: YÜKSEK**

#### 7.1 Code Signing Ayarları

1. Xcode'da **Project Navigator** → SubTracker (proje)
2. **TARGETS** → SubTracker
3. **Signing & Capabilities** tab
4. **Automatically manage signing** ✅ aktif
5. **Team:** Apple Developer hesabınızı seçin
6. **Bundle Identifier:** com.enesse.SubTracker (değiştirmeyin)

**Widget için tekrarlayın:**
- TARGETS → SubTrackerWidgetExtension
- Aynı ayarları yapın

#### 7.2 Archive Oluşturma

1. **Device seçimi:** Toolbar'dan **Any iOS Device (arm64)** seçin (simulator DEĞIL!)

2. **Temiz build:**
   ```
   Product → Clean Build Folder (⌘ + ⇧ + K)
   ```

3. **Archive:**
   ```
   Product → Archive (⌘ + ⇧ + B önce build test edin)
   ```
   - İşlem 2-5 dakika sürer
   - Başarılı olursa Organizer penceresi açılır

4. **Validate App:**
   - Organizer'da yeni archive'i seçin
   - **Validate App** butonuna tıklayın
   - Hataları kontrol edin

**Yaygın Hatalar ve Çözümleri:**

**❌ "Missing Compliance"**
- Çözüm: Export Compliance bilgisi ekleyin (sonraki adımda)

**❌ "Invalid Bundle ID"**
- Çözüm: Bundle ID'nin App Store Connect'tekiyle aynı olduğundan emin olun

**❌ "Icon contains alpha channel"**
- Çözüm: App Icon'dan alpha channel'ı kaldırın (PNG'yi düzenleyin)

**❌ "Missing Entitlements"**
- Çözüm: Signing & Capabilities'de Apple Sign In ve App Groups ekli mi kontrol edin

#### 7.3 App Store'a Upload

1. Organizer'da **Distribute App** butonuna tıklayın
2. **App Store Connect** seçin → Next
3. **Upload** seçin → Next
4. **Automatically manage signing** seçin → Next
5. **Export Compliance:**
   ```
   Does your app use encryption? YES
   Is your app exempt from encryption? YES
   (Çünkü sadece HTTPS kullanıyorsunuz, custom encryption yok)
   ```
6. Review ekranını kontrol edin → **Upload**

**İşlem Süresi:** 5-15 dakika

**Upload Sonrası:**
- App Store Connect → TestFlight → Builds
- Build "Processing" durumunda olacak (10-60 dakika sürebilir)
- Email alacaksınız: "Your build has been processed"

---

### 8️⃣ TestFlight Beta Test

**Öncelik: ORTA (Ama çok önerilir)**

#### Neden TestFlight?

- Gerçek cihazda test
- Pro satın alma gerçek Sandbox environment'da test
- App Store review öncesi son kontrol

#### Internal Testing Kurulumu

1. App Store Connect → TestFlight → Internal Testing
2. **Create Group** veya mevcut gruba ekle
3. **Add Testers:** Kendinizi ve test edecekleri ekleyin
4. Build'i gruba assign edin

#### TestFlight Uygulamasından Test

1. iPhone'unuzda **TestFlight** uygulamasını açın (App Store'dan indirin)
2. SubTracker'ı görün ve **Install** yapın
3. Test edin:
   - ✅ Apple Sign In çalışıyor mu?
   - ✅ Abonelik ekleme/düzenleme/silme
   - ✅ Bildirimler çalışıyor mu?
   - ✅ Widget düzgün güncelleniyor mu?
   - ✅ **Pro satın alma** (Sandbox kullanıcı gerekli)
   - ✅ iCloud senkronu (iki cihazda test)
   - ✅ Siri shortcuts çalışıyor mu?

#### Sandbox Test Kullanıcısı Oluşturma

**Pro satın almayı test etmek için:**

1. App Store Connect → Users and Access → **Sandbox Testers**
2. **Add Tester** (+)
3. Fake bilgilerle test kullanıcısı oluşturun

**Kullanım:**
1. iPhone Settings → App Store → Sign Out (normal Apple ID'den)
2. SubTracker'da Pro satın alma yaparken Sandbox kullanıcı ile giriş yapın

---

### 9️⃣ App Store Review'e Gönderme

**Öncelik: YÜKSEK**

#### 9.1 Version Bilgileri

1. App Store Connect → SubTracker → **(+) Version or Platform**
2. **iOS**
3. **Version:** 1.0

**What's New in This Version (Release Notes):**
```
SubTracker ile aboneliklerinizi kolayca takip edin!

✨ Özellikler
• Abonelik yönetimi ve hatırlatmalar
• Maliyet analizi ve raporlar
• Widget ve Siri desteği
• iCloud senkronu (Pro)
• 7 gün ücretsiz Pro deneme
```

#### 9.2 Build Seçimi

1. **Build** dropdown → Yüklediğiniz build'i seçin
2. **Export Compliance** (tekrar sorabilir):
   - Uses Encryption: YES
   - Exempt: YES

#### 9.3 In-App Purchases Ekleme

1. **In-App Purchases and Subscriptions** → Add
2. Oluşturduğunuz 2 subscription'ı ekleyin:
   - com.subtracker.pro.monthly
   - com.subtracker.pro.yearly

#### 9.4 App Review Information

**Contact Information:**
```
First Name: [Adınız]
Last Name: [Soyadınız]
Phone: +90 [Telefon Numaranız]
Email: [Email Adresiniz]
```

**Review Notes (İngilizce yazın):**
```
Test Instructions:
- App uses Apple Sign In, reviewer can use their test Apple ID
- Pro features can be tested with 7-day free trial

Important Notes:
- Notifications require permission grant
- Widget appears after adding first subscription
- Siri Shortcuts work on iOS 16+

Thank you for reviewing SubTracker!
```

**Demo Account:** 
```
Gerekli değil (Apple Sign In reviewer'ın kendi Apple ID ile test edebilir)
```

#### 9.5 Content Rights & Age Rating

**Advertising Identifier:**
```
Does your app use the Advertising Identifier (IDFA)? NO
```

**Content Rights:**
```
✅ I confirm that I have the rights to use content in this app
```

**Age Rating:**
- İçerik sorularını cevaplayın (muhtemelen 4+ olacak)

#### 9.6 Submit

**Final Checklist:**
- ✅ Build seçili
- ✅ IAP'ler eklendi
- ✅ Screenshots yüklendi (en az 3 adet 6.7" için)
- ✅ Description dolduruldu
- ✅ Keywords eklendi
- ✅ Privacy Policy URL eklendi
- ✅ Support URL eklendi
- ✅ App Review Information dolduruldu

**Submit for Review** butonuna tıklayın!

---

## 🎉 Review Sonrası

### Bekleme Süresi

```
Status: Waiting for Review → 24-48 saat
Status: In Review → 1-8 saat
```

### Olası Sonuçlar

**✅ Ready for Sale** - Onaylandı!
- App Store'da yayınlanması 24 saat sürebilir
- App Store Connect → Sales and Trends'ten satışları takip edin

**❌ Rejected** - Reddedildi
- Resolution Center'da red nedenini okuyun
- Yaygın nedenler:
  1. Privacy Policy erişilemiyor
  2. App çöküyor
  3. IAP test edilemiyor
  4. Metadata yanıltıcı
- Problemi düzeltin ve **Submit for Review** tekrar yapın

---

## 📊 Yayın Sonrası Takip

### Analytics

- App Store Connect → Analytics
- İndirme, gelir, kullanıcı davranışları

### Kullanıcı Yorumları

- App Store Connect → App Store → Ratings and Reviews
- Yorumlara yanıt verin

### Crash Reports

- Xcode → Window → Organizer → Crashes
- TestFlight crashlerini takip edin

---

## 🆘 Yardım Kaynakları

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [In-App Purchase Guide](https://developer.apple.com/in-app-purchase/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Apple Developer Forums](https://developer.apple.com/forums/)

---

## ✅ Hızlı Checklist

### Yasal Hazırlıklar
- [ ] Privacy Policy oluşturuldu ve web'e yüklendi
- [ ] Terms of Service oluşturuldu ve web'e yüklendi
- [ ] AppConstants.swift'te URL'ler güncellendi

### Xcode Ayarları
- [ ] StoreKit Configuration scheme'den kaldırıldı
- [ ] Code signing ayarlandı
- [ ] Archive alındı ve validate edildi

### App Store Connect
- [ ] Uygulama kaydı oluşturuldu
- [ ] App Information dolduruldu
- [ ] Pricing ayarlandı (Free)
- [ ] IAP ürünleri oluşturuldu (monthly + yearly)
- [ ] Ekran görüntüleri yüklendi
- [ ] Metadata dolduruldu

### Yayın
- [ ] Build upload edildi
- [ ] TestFlight'ta test edildi
- [ ] Review'e gönderildi

---

**🎊 Başarılar! Herhangi bir sorunda yardıma ihtiyacınız olursa çekinmeden sorun.**
