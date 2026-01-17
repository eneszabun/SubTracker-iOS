# App Store Screenshot Rehberi

## 🎯 Hedef Boyutlar

App Store için en az **6.7" display** boyutunda screenshot'lar gerekir:
- **1290 x 2796 pixels** (iPhone 15 Pro Max, 14 Pro Max)

## 📸 Adım Adım Screenshot Alma

### 1. Xcode Simulator'ü Başlatın

```bash
# Terminal'de çalıştırın
open -a Simulator
```

### 2. Doğru Cihazı Seçin

Simulator menüsünden:
- **File → Open Simulator → iPhone 15 Pro Max**

### 3. Uygulamayı Simulator'de Çalıştırın

1. Xcode'da projeyi açın
2. Üst ortadaki scheme selector'dan **iPhone 15 Pro Max** seçin
3. Play butonuna basın (⌘R)

### 4. Screenshot Alın

Uygulamada göstermek istediğiniz ekranlara gidin ve:
- **⌘S** tuşuna basın (veya File → New Screenshot)
- Screenshot otomatik olarak masaüstüne kaydedilir
- Dosya adı: `Simulator Screen Shot - iPhone 15 Pro Max - 2026-01-17 at XX.XX.XX.png`

## 📋 Önerilen Screenshot'lar (5-10 adet)

SubTracker için önerilen ekranlar:

1. **Ana Sayfa (Summary)**
   - Toplam aylık harcama görünür
   - Birkaç abonelik göster
   - Temiz, göze hoş gelen bir durum

2. **Abonelikler Listesi**
   - Netflix, Spotify, iCloud gibi popüler abonelikler
   - Farklı kategorilerde örnekler
   - Gerçekçi fiyatlar

3. **Yeni Abonelik Ekleme**
   - Form ekranı açık
   - Kullanıcıya nasıl ekleneceğini göster

4. **Kategori Raporları** (Pro özellik)
   - Pie chart görünümü
   - Kategori dağılımı

5. **Ayarlar / Pro Özellikleri**
   - Premium özellikler vurgusu
   - Tema seçenekleri

## 🎨 İpuçları

### Screenshot'ları Daha İyi Göstermek İçin:

1. **Test Verileri Hazırlayın**
   - Gerçekçi abonelik isimleri kullanın
   - Tutarlı fiyatlar ekleyin
   - 5-8 abonelik ideal

2. **Temiz UI**
   - Light mode veya dark mode (ikisini de deneyin)
   - Notification/alert yok
   - Tam şarjlı batarya gösterin

3. **Zamanı Düzenleyin**
   - Simulator'de saat 09:41 gösterilir (Apple standardı)
   - Bildirim yoktur

### Screenshot'ları Düzenlemek İsterseniz:

Preview veya başka bir araçla:
- Cihaz frame'i ekleyebilirsiniz (opsiyonel)
- Başlık/açıklama ekleyebilirsiniz
- Arka plan rengi ekleyebilirsiniz

## 🖼️ Screenshot Boyutlarını Kontrol Etme

Terminal'de:
```bash
cd ~/Desktop
sips -g pixelWidth -g pixelHeight "Simulator Screen Shot*.png"
```

Çıktı şu şekilde olmalı:
```
pixelWidth: 1290
pixelHeight: 2796
```

## 📤 App Store Connect'e Yükleme

1. App Store Connect → Your App → App Store tab
2. **1.0 Prepare for Submission** seçin
3. **App Previews and Screenshots** bölümüne gidin
4. **6.7" Display** seçin
5. Screenshot'ları sürükle-bırak ile yükleyin (max 10 adet)

## ⚠️ Önemli Notlar

- **Minimum 3, maksimum 10** screenshot yüklenebilir
- İlk screenshot en önemli (App Store'da büyük gösterilir)
- Screenshot'lar sırayla gösterilir
- Aynı boyutta olmalılar (1290x2796)
- PNG veya JPEG formatı
- RGB color space

## 🎬 Video Preview (Opsiyonel)

İsterseniz 15-30 saniyelik app preview videosu da ekleyebilirsiniz:
- 1920x1080 (landscape) veya 1080x1920 (portrait)
- M4V, MP4, MOV formatı
- Max 500 MB

## 🆘 Sorun mu Var?

### "Wrong size" hatası alıyorsanız:
1. Simulator'ün %100 zoom'da olduğundan emin olun
2. Window → Physical Size (⌘1) seçin
3. Yeniden screenshot alın

### Ekran çok büyük/küçük görünüyorsa:
- Window → Physical Size (⌘1)
- Window → Pixel Accurate (⌘2)
- Window → Fit Screen (⌘3)

## 📚 Daha Fazla Bilgi

Apple Screenshot Guidelines:
https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications
