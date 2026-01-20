# 🔧 App Store Rejection Düzeltme Rehberi

Apple'dan gelen iki sorunu çözmek için adım adım talimatlar.

---

## ❌ Sorun 1: In-App Purchase Review Eksik

**Apple'ın Mesajı:**
> "We are unable to complete the review of the app because one or more of the in-app purchase products have not been submitted for review."

### Neden Oluştu?
IAP ürünlerinizi (Monthly ve Yearly) oluşturdunuz ama review için submit etmediniz.

### Çözüm Adımları

#### 1. App Store Connect'e Gidin
```
https://appstoreconnect.apple.com
→ My Apps
→ SubTracker
→ In-App Purchases
```

#### 2. Her IAP için Screenshot Ekleyin

**Monthly Subscription için:**

1. `com.subtracker.pro.monthly` ürününe tıklayın
2. **App Review Information** bölümüne scroll edin
3. **Screenshot for Review** bölümüne bir screenshot yükleyin

**Hangi screenshot:**
- Pro upgrade ekranının screenshot'u
- Settings → Pro Ayarları ekranı
- Veya Pro özelliklerin listelendiği herhangi bir ekran

**Screenshot boyutu:** 
- En az 640x920 px
- Herhangi bir iPhone screenshot'u (1290x2796 px ideal)

**Yearly Subscription için:**
Aynı işlemi `com.subtracker.pro.yearly` için tekrarlayın (aynı screenshot'u kullanabilirsiniz).

#### 3. IAP'leri Submit Edin

Her iki IAP için:

1. IAP sayfasında sağ üstteki **"Submit for Review"** butonuna tıklayın
2. Onaylayın

**Önemli:** IAP'leri submit etmeden önce:
- ✅ Display Name doldurulmuş olmalı (Turkish + English)
- ✅ Description doldurulmuş olmalı (Turkish + English)
- ✅ Price ayarlanmış olmalı ($2.99 ve $29.00)
- ✅ Free Trial ayarlanmış olmalı (7 days)
- ✅ Screenshot yüklenmiş olmalı

#### 4. Yeni Binary Upload Edin (Opsiyonel ama Apple istedi)

Apple "upload a new binary" diyor ama genellikle gerekli değil. Önce IAP'leri submit edin.

Eğer Apple tekrar isterse:

1. Xcode'da version/build number'ı artırın:
   ```
   Version: 1.0 → 1.0
   Build: 1 → 2
   ```

2. Product → Archive
3. Validate & Upload
4. App Store Connect'te yeni build'i seçin

---

## ❌ Sorun 2: Support URL Çalışmıyor

**Apple'ın Mesajı:**
> "The Support URL provided in App Store Connect, https://eneszabun.github.io/SubTracker-iOS/support.html, is currently not functional and/or displays an error."

### Neden Oluştu?

İki olası sebep:

1. **GitHub Pages aktif değil** - Repo'da GitHub Pages açılmamış
2. **URL yanlış** - Dosya yolu veya isim hatalı

### Çözüm: GitHub Pages Kontrolü

#### 1. GitHub Repo Ayarlarını Kontrol Edin

1. GitHub'da SubTracker-iOS repo'nuza gidin
2. **Settings** tab'ına tıklayın
3. Sol menüden **Pages** seçin

**Kontrol Edilecekler:**

```
Source: Deploy from a branch
Branch: main (veya master)
Folder: /docs
```

**Eğer "Your site is published at..." mesajı yoksa:**

1. **Source** dropdown'dan **main** branch seçin
2. **Folder** dropdown'dan **/docs** seçin
3. **Save** butonuna tıklayın
4. 1-2 dakika bekleyin (GitHub Pages aktif olsun)

#### 2. URL'i Test Edin

Tarayıcıda açın:
```
https://eneszabun.github.io/SubTracker-iOS/support.html
```

**Çalışıyorsa:** ✅ Sorun yok, Apple tekrar kontrol edecek

**404 Error alıyorsanız:**

**Seçenek A: Dosya Yolu Kontrolü**

docs klasöründe dosya var mı?
```bash
ls docs/
# Görmelisiniz:
# - index.html
# - privacy-policy.html
# - terms-of-service.html
# - support.html
```

**Seçenek B: GitHub'a Push Edildi mi?**

```bash
git status
# Eğer docs/ klasörü untracked ise:
git add docs/
git commit -m "Add support page"
git push origin main
```

**Seçenek C: index.html Eksik**

docs/ klasöründe index.html olmalı (GitHub Pages için):

```bash
# Varsa:
ls docs/index.html

# Yoksa oluşturun
# (Zaten var gibi görünüyor recently viewed'da)
```

#### 3. App Store Connect'te URL'i Güncelle (Gerekirse)

Eğer URL kesinlikle çalışmıyorsa ve düzeltemiyorsanız:

**Geçici Çözüm:** Email desteğe geçin

1. App Store Connect → SubTracker → App Information
2. **Support URL:** 
   ```
   mailto:enes.sefa.zabun@gmail.com
   ```

**Not:** `mailto:` URL'leri de kabul edilir, ama web sayfası tercih edilir.

---

## ✅ Hızlı Checklist

### IAP Sorunu İçin:
- [ ] App Store Connect → IAP → Monthly → Screenshot yükle
- [ ] App Store Connect → IAP → Yearly → Screenshot yükle
- [ ] Her iki IAP'yi "Submit for Review" yap
- [ ] IAP status: "Waiting for Review" olduğunu doğrula

### Support URL Sorunu İçin:
- [ ] GitHub → Settings → Pages → /docs aktif mi kontrol et
- [ ] https://eneszabun.github.io/SubTracker-iOS/support.html tarayıcıda test et
- [ ] Çalışıyorsa: ✅ Sorun yok
- [ ] Çalışmıyorsa: docs/ klasörünü push et veya mailto: kullan

---

## 🔄 Düzeltme Sonrası

### 1. App Store Connect'te Status Kontrolü

```
App Store Connect → SubTracker → App Store → Version 1.0
```

**Göreceksiniz:**
- App Status: Waiting for Review (veya In Review)
- Build: [Your build]
- IAP'ler: Waiting for Review

### 2. Apple'a Yanıt (Opsiyonel)

Resolution Center'da Apple'ın mesajına yanıt verebilirsiniz:

```
Dear App Review Team,

Thank you for your feedback. I have resolved both issues:

1. In-App Purchases: I have added required screenshots and submitted both Monthly and Yearly subscriptions for review.

2. Support URL: The support page is now accessible at https://eneszabun.github.io/SubTracker-iOS/support.html. Please verify.

Thank you for your patience!

Best regards,
Enes Sefa Zabun
```

### 3. Resubmit (Eğer Gerekiyorsa)

Eğer binary değiştirdiyseniz:

1. Version sayfasında **Submit for Review** butonuna tekrar tıklayın
2. IAP'lerin seçili olduğunu doğrulayın

**Eğer binary değiştirmediyseniz:**
- Sadece IAP'leri submit etmek yeterli
- Apple otomatik olarak tekrar review edecek

---

## ⏱️ Bekleme Süresi

- **IAP Review:** 24-48 saat
- **App Re-Review:** 12-24 saat (genellikle daha hızlı, rejection sonrası)

---

## 🆘 Hala Sorun Varsa

### Support URL Hala Çalışmıyorsa

**Plan B: Farklı Platform Kullanın**

**1. Notion (En Kolay):**
```bash
1. Notion.so'da yeni page oluşturun
2. support.html içeriğini yapıştırın
3. Sağ üst → Share → Publish to web
4. URL'i kopyalayın
5. App Store Connect'te güncelleyin
```

**2. Google Sites:**
```bash
1. sites.google.com
2. Yeni site oluşturun
3. İçeriği ekleyin
4. Publish
5. URL'i kopyalayın
```

### IAP Screenshot Sorunları

**Hangi ekranı screenshot almalı:**

1. **Settings Ekranı:**
   - Xcode Simulator → iPhone 15 Pro Max
   - Settings → Pro Ayarları
   - Screenshot: ⌘S

2. **Pro Upgrade Sheet:**
   - Pro'ya Yükselt butonuna tıklayın
   - Sheet açılır
   - Screenshot: ⌘S

**Screenshot Boyutu Uygun Değilse:**

Online araçla resize edin:
- [iLoveIMG](https://www.iloveimg.com/resize-image)
- Minimum: 640x920 px
- Maksimum: 4096x4096 px

---

## 📊 Expected Timeline

```
Bugün (Adım 1-2 saat):
├─ IAP'lere screenshot ekle
├─ IAP'leri submit et
├─ Support URL'i kontrol et/düzelt
└─ (Gerekirse) Yeni binary upload et

Yarın-Öbür gün (Apple):
├─ IAP Review: Approved
├─ App Re-Review: 12-24 saat
└─ Status: Ready for Sale 🎉
```

---

## ✅ Başarı Kontrol Listesi

Tamamlandığında:

- ✅ IAP'lerde "Ready to Submit" YOK, "Waiting for Review" var
- ✅ Support URL tarayıcıda açılıyor
- ✅ App status: "Waiting for Review"
- ✅ (Opsiyonel) Resolution Center'da yanıt yazdınız

---

**Başarılar! Bu iki sorunu düzeltince app onaylanacak! 🚀**

---

## 🎯 TL;DR (Çok Kısa Özet)

```bash
# 1. IAP Screenshot Ekle
App Store Connect → IAP → Screenshot Upload (Pro upgrade ekranı)

# 2. IAP Submit Et
Her iki IAP → Submit for Review

# 3. Support URL Test Et
https://eneszabun.github.io/SubTracker-iOS/support.html
# Çalışmıyorsa → GitHub Pages aktif et

# 4. Bekle
24-48 saat → Approval 🎉
```
