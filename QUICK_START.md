# ⚡ Quick Start - App Store'a 5 Adımda Yayınlama

**Hedef:** SubTracker'ı App Store'da yayınlamak  
**Tahmini Süre:** 8-12 saat aktif çalışma + 24-48 saat Apple review  

---

## 🚦 Başlamadan Önce

✅ Apple Developer Program üyeliğiniz var (yıllık $99)  
✅ Xcode 15+ kurulu  
✅ SubTracker projesi build oluyor  

---

## 📋 5 Ana Adım

### 1️⃣ Yasal Dokümanlar (2-3 saat)

**Ne yapacaksınız:**
- Privacy Policy ve Terms of Service oluşturacaksınız
- Web'e yükleyeceksiniz (GitHub Pages/Notion)
- App'te URL'leri güncelleyeceksiniz

**Nasıl:**

```bash
# 1. Template'leri açın
open PRIVACY_POLICY_TEMPLATE.md
open TERMS_OF_SERVICE_TEMPLATE.md

# 2. [BÜYÜK HARFLERLE] yazılı yerleri doldurun
# 3. GitHub Pages'e yükleyin (veya Notion)
# 4. URL'leri AppConstants.swift'e yazın

# AppConstants.swift'i düzenleyin:
open SubTracker/AppConstants.swift
# privacyPolicyURL = "GERÇEK_URL_BURAYA"
# termsOfServiceURL = "GERÇEK_URL_BURAYA"
# supportURL = "mailto:EMAIL_BURAYA"
```

**Kontrol:**
- [ ] Privacy Policy web'de erişilebilir
- [ ] Terms of Service web'de erişilebilir
- [ ] AppConstants.swift güncellendi
- [ ] Git commit yapıldı

---

### 2️⃣ Xcode Ayarları (5 dakika)

**Ne yapacaksınız:**
- StoreKit test configuration'ı kaldıracaksınız (production için)

**Nasıl:**

1. Xcode'u açın
2. **Product → Scheme → Edit Scheme** (veya ⌘<)
3. Sol panelden **Run** seçin
4. **Options** tab'ına tıklayın
5. **StoreKit Configuration:** dropdown'dan **None** seçin
6. **Close**

**Kontrol:**
- [ ] StoreKit Configuration = None

---

### 3️⃣ App Store Connect Setup (2-3 saat)

**Ne yapacaksınız:**
- Uygulama kaydı oluşturacaksınız
- Screenshots hazırlayacaksınız
- Metadata yazacaksınız

**Nasıl:**

```bash
# Checklist'i takip edin:
open APP_STORE_CHECKLIST.md

# Her maddeyi işaretleyerek ilerleyin
```

**Ana görevler:**
1. App Store Connect → My Apps → (+) New App
2. Simulator'da 3+ screenshot alın (6.7" iPhone)
3. Description, keywords yazın (guide'da hazır metinler var)

**Kontrol:**
- [ ] App kaydı oluşturuldu
- [ ] 3+ screenshot yüklendi
- [ ] Metadata dolduruldu
- [ ] Privacy/Terms URL'leri eklendi

---

### 4️⃣ Build & Upload (30 dakika)

**Ne yapacaksınız:**
- Archive oluşturacaksınız
- App Store'a upload edeceksiniz

**Nasıl:**

```bash
# Xcode'da:
# 1. Device seçimi: Any iOS Device (arm64)
# 2. Product → Clean Build Folder (⌘⇧K)
# 3. Product → Archive (⌘⇧B ile önce test)
# 4. Organizer'da → Validate App
# 5. Distribute App → Upload

# Sonra bekleyin: "Build processed" emaili (10-60 dakika)
```

**Kontrol:**
- [ ] Archive başarılı
- [ ] Validate başarılı
- [ ] Upload tamamlandı
- [ ] Email alındı (build processed)

---

### 5️⃣ IAP & Submission (1-2 saat)

**Ne yapacaksınız:**
- In-App Purchase'ları oluşturacaksınız
- TestFlight'ta test edeceksiniz (opsiyonel ama önerilen)
- Review'e göndereceksiniz

**Nasıl:**

1. **IAP oluşturun:**
   - App Store Connect → IAP → Subscription Group
   - Monthly: `com.subtracker.pro.monthly` (₺39.99)
   - Yearly: `com.subtracker.pro.yearly` (₺299.99)
   - Her ikisi için 7-day free trial

2. **TestFlight (opsiyonel):**
   - TestFlight → Internal Testing
   - Kendinizi ekleyin ve test edin

3. **Submit:**
   - App Store Connect → Version 1.0
   - Build seç, IAP'leri ekle
   - **Submit for Review**

**Kontrol:**
- [ ] IAP'ler oluşturuldu
- [ ] TestFlight'ta test edildi
- [ ] Review'e gönderildi
- [ ] Status: "Waiting for Review"

---

## ⏰ Zaman Çizelgesi

```
Gün 1: Yasal dokümanlar + Xcode ayarları (3 saat)
Gün 2: App Store Connect + Screenshots (3 saat)
Gün 3: Build, Upload, IAP, Submit (2 saat)
Gün 4-5: Apple Review (otomatik, 24-48 saat)
Gün 6: Yayında! 🎉
```

---

## 📚 Hangi Belgeyi Ne Zaman Kullanmalıyım?

### Şu An (Başlamadan önce)
→ **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Genel bakış

### İlerleme Takibi
→ **[APP_STORE_CHECKLIST.md](APP_STORE_CHECKLIST.md)** - Her adımı işaretleyin

### Detaylı Adımlar
→ **[PRODUCTION_DEPLOYMENT_GUIDE.md](PRODUCTION_DEPLOYMENT_GUIDE.md)** - Takılınca bakın

### Yasal Dokümanlar
→ **[PRIVACY_POLICY_TEMPLATE.md](PRIVACY_POLICY_TEMPLATE.md)** - Doldurup yükleyin  
→ **[TERMS_OF_SERVICE_TEMPLATE.md](TERMS_OF_SERVICE_TEMPLATE.md)** - Doldurup yükleyin

---

## 🆘 Sık Sorulan Sorular

### "Nereden başlamalıyım?"
1. Bu dosyayı okuyun (şu an okuyorsunuz ✅)
2. `APP_STORE_CHECKLIST.md`'yi açın
3. İlk maddeyi tamamlayın, işaretleyin, devam edin

### "Privacy Policy oluşturmayı bilmiyorum!"
`PRIVACY_POLICY_TEMPLATE.md` dosyasını açın, `[BÜYÜK HARFLERLE]` yazılı 5-6 yeri doldurun, hazır!

### "Screenshot nasıl güzelleştiririm?"
1. Simulator'da screenshot alın (⌘S)
2. [Hotpot.ai](https://hotpot.ai/templates/app-store-screenshot)'a yükleyin
3. iPhone çerçevesi + başlık ekleyin
4. İndirin

### "IAP'leri ne zaman oluşturmalıyım?"
Build upload'dan SONRA. Önce upload edin, sonra IAP'leri oluşturun.

### "TestFlight zorunlu mu?"
Hayır, ama ÇOOK önerilir. Pro satın almayı gerçek cihazda test etmek önemli.

### "Review ne kadar sürer?"
Genellikle 24-48 saat. Hızlı olabilir (4 saat) veya yavaş olabilir (3 gün).

### "Red edilirse ne olur?"
Sorun açıklanır, düzeltirsiniz, tekrar submit edersiniz. Problem değil!

---

## ✅ Hızlı Kontrol Listesi

Başlamadan önce hazır mısınız?

- [ ] Apple Developer hesabım aktif ($99/yıl)
- [ ] Xcode kurulu ve çalışıyor
- [ ] SubTracker build oluyor
- [ ] 8-12 saat ayırabilirim (birkaç güne yayılabilir)
- [ ] Email'lerime erişimim var (Apple'dan email gelecek)
- [ ] Privacy Policy/Terms için web alanım var (GitHub Pages/Notion)

**Hepsi ✅ ise:** `APP_STORE_CHECKLIST.md`'yi açın ve başlayın! 🚀

---

## 🎯 İlk 3 Adımınız

```bash
# 1. Checklist'i açın
open APP_STORE_CHECKLIST.md

# 2. Privacy template'ini açın
open PRIVACY_POLICY_TEMPLATE.md

# 3. Başlayın!
# [BÜYÜK HARFLERLE] yazılı yerleri doldurmaya başlayın
```

---

## 📞 Yardım

Takılırsanız:
1. `PRODUCTION_DEPLOYMENT_GUIDE.md`'de "Sorun Giderme" bölümüne bakın
2. Apple Developer Forums'da arayın
3. Stack Overflow'da "ios app store submission" aratın

---

**Başarılar! SubTracker'ı App Store'da görmeyi sabırsızlıkla bekliyoruz! 🎉**

---

**Not:** Bu quick start, `PRODUCTION_DEPLOYMENT_GUIDE.md`'nin özeti. Detaylar için o belgeye bakın.
