# Siri Kısayolları - SubTracker

SubTracker, iOS 16+ cihazlarda Siri ile sesli komutlarla abonelik yönetimi yapmanıza olanak tanır.

## 🎙️ Kullanılabilir Komutlar

### 1️⃣ Aylık Toplam Harcama

**Siri'ye söyleyebilecekleriniz:**
- *"SubTracker'da aylık harcamam ne kadar?"*
- *"Toplam abonelik harcamam SubTracker'da"*
- *"SubTracker'da aylık toplam"*
- *"Abonelik toplamı SubTracker"*

**Ne gösterir:**
- Toplam aylık abonelik harcamanız
- Aktif abonelik sayınız
- Tercih ettiğiniz para biriminde gösterim

---

### 2️⃣ Yaklaşan Yenilemeler

**Siri'ye söyleyebilecekleriniz:**
- *"SubTracker'da yaklaşan yenilemelerim"*
- *"SubTracker'da hangi abonelikler yenilenecek?"*
- *"Yenilenecek abonelikler SubTracker"*
- *"SubTracker yenileme bildirimleri"*

**Ne gösterir:**
- Önümüzdeki 7 gün içinde yenilenecek abonelikler
- Her aboneliğin adı ve tutarı
- Yenilenme tarihine kalan süre
- En fazla 5 yaklaşan yenileme

---

### 3️⃣ Aboneliklerimi Göster

**Siri'ye söyleyebilecekleriniz:**
- *"SubTracker'da aboneliklerimi göster"*
- *"SubTracker'da aboneliklerim"*
- *"SubTracker abonelik listesi"*
- *"Aktif aboneliklerim SubTracker"*

**Ne gösterir:**
- Tüm aktif abonelikleriniz
- Her aboneliğin adı, tutarı ve döngüsü
- En fazla 10 abonelik (daha fazlası için uygulamayı açın)
- Opsiyonel kategori filtresi

**Kategori ile filtreleme:**
- *"SubTracker'da müzik aboneliklerimi göster"*
- *"SubTracker'da eğlence aboneliklerim"*

---

## 📱 Nasıl Kurulur?

### Otomatik Keşif (Önerilen)
1. SubTracker'ı ilk kez açtığınızda Siri otomatik olarak kısayolları keşfeder
2. **Ayarlar > Siri ve Arama > SubTracker** bölümüne gidin
3. Önerilen kısayolları görün ve kullanın

### Manuel Kısayol Ekleme
1. **Kısayollar** uygulamasını açın
2. **Galeri** sekmesine gidin
3. "SubTracker" araması yapın
4. İstediğiniz kısayolu ekleyin
5. İsterseniz özel Siri komutu kaydedebilirsiniz

---

## 🔧 Gelişmiş Kullanım

### Shortcuts Uygulaması ile Otomasyon
Shortcuts uygulamasında SubTracker intent'lerini kullanarak:
- ✅ Sabah rutinine ekleme: "Günaydın" derken günlük harcama özeti
- ✅ Konum bazlı: Eve geldiğinizde yaklaşan yenilemeler
- ✅ Zaman bazlı: Her ayın 1'inde aylık harcama raporu
- ✅ NFC tag'ler ile: Özel tag'e dokunarak hızlı özet

**Örnek Otomasyon:**
```
Sabah 9:00'da → SubTracker Aylık Toplam göster → Bildirim gönder
```

### Widget ile Entegrasyon
Shortcuts widget'ı ile SubTracker kısayollarını ana ekrana ekleyin:
1. Ana ekranda uzun basın
2. **Widget Ekle** > **Kısayollar**
3. SubTracker kısayollarını seçin

---

## 💡 İpuçları

### Siri'yi Eğitin
- Farklı telaffuzlarla deneyin
- İlk denemede tanımazsa komutu tekrarlayın
- Zaman içinde Siri alışkanlıklarınızı öğrenir

### Gizlilik
- Tüm veriler cihazınızda kalır
- Siri sorguları Apple sunucularına gider ama abonelik detaylarınız gitmez
- Intent'ler tamamen yerel Core Data kullanır

### Performans
- İlk sorguda kısa gecikme olabilir (Core Data başlatma)
- Sonraki sorgular çok hızlıdır
- Uygulama arka planda olsa bile çalışır

---

## ❓ Sorun Giderme

### "SubTracker bu işlemi yapamadı" hatası
- Uygulamayı en az bir kez açtığınızdan emin olun
- En az bir abonelik ekleyin
- Cihazı yeniden başlatın

### Siri kısayolları görünmüyor
- **Ayarlar > Siri ve Arama > SubTracker** kontrol edin
- Siri'ye erişim iznini onaylayın
- SubTracker'ı güncellediğinizden emin olun

### Yanlış para birimi gösteriyor
- **SubTracker > Ayarlar > Para Birimi** tercihini kontrol edin
- Değişiklikler sonraki Siri sorgusunda aktif olur

---

## 🚀 Gelecek Özellikler

Planlanan Siri özellikleri:
- [ ] Sesli abonelik ekleme
- [ ] Abonelik iptal etme
- [ ] Özel tarih aralığı sorguları
- [ ] Kategori bazlı harcama trendleri
- [ ] Bütçe durumu sorgusu

---

## 🎯 Daha Fazla Bilgi

- [Apple App Intents Dokümantasyonu](https://developer.apple.com/documentation/appintents)
- [Shortcuts Kullanıcı Kılavuzu](https://support.apple.com/guide/shortcuts/welcome/ios)

**Not:** Siri Kısayolları özelliği iOS 16 ve üzeri gerektirir.
