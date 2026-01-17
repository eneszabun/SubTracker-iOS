# SubTracker iOS

SwiftUI tabanli, abonelik ve düzenli harcama takibi uygulamasi. Kullanici tum aboneliklerini kaydeder, yenileme tarihlerini ve toplam aylik/yillik maliyeti gorur, hatirlatmalar alir ve iptal/yenileme kararlarini planlar.

## Uygulama Kurallari
- Veriyi oncelikle yerelde Core Data ile sakla; opsiyonel iCloud senkronu ileride eklenecek.
- Ilk acilista abonelik listesi bos gelir; tum girdiler kullanici tarafindan eklenir.
- Abonelik kartlari sade, aksiyon odakli: isim, kategori, tutar, dongu (aylik/yillik), yenileme tarihi, notlar.
- Bildirimler yalnizca kritik anlarda: yenilemeden 3 gun once ve yenileme gunu.
- Giris/duzenleme formlarinda zorunlu alanlar: isim, tutar, para birimi, yenileme araligi; digerleri opsiyonel.
- Karanlik/aydınlık tema destekle; dinamik renkler kullan.
- Erişilebilirlik: Dynamic Type, VoiceOver etiketleri, kontrast kurallari.
- Gizlilik: takip/analitik varsayilan kapali, yalnizca yerel depolama.
- Kimlik: Kullanici uygulamaya ilk giriste Apple ile oturum acar; daha once girisse dogrudan ozet acilir.

## Yol Haritasi ve Yapilacaklar

### Tamamlanan Ozellikler ✅
- [x] Abonelik zaman cizelgesi: her abonelik icin iptal/bitis tarihi destegi, gercek yenileme tarihleriyle 12 aylik nakit akisi grafigi.
- [x] Bildirim akisi: yenileme oncesi bildirim planlama/iptal etme, hatirlatici gun ayari.
- [x] Liste gelistirmeleri: kategori/yenileme filtresi, siralama (en yakin, en pahali), arama.
- [x] Analitik kartlar: en pahali 5 abonelik, son 30/90 gun trendi, iptal edilenlerden kazanilan tasarruf.
- [x] Veri katmani: Core Data ile kalici depolama, JSON'dan goc tamamlandi.
- [x] Tema destegi: karanlik/aydinlik tema, sistem tercihine uyum.
- [x] Abonelik onerileri: populer servislerin otomatik tanima ve kategori atama.

### Kisa Vadeli Hedefler (v1.1)
- [x] Widget destegi: ana ekranda toplam aylik gider ve yakin yenilemeler.
- [x] Spotlight entegrasyonu: abonelikleri sistem aramasindan bulma.
- [x] Bildirim deep link: bildirime tiklandiginda ilgili abonelik detay sayfasi acilir.
- [x] Gecmis odemeler bolumu: detay sayfasinda odeme gecmisi listesi.

### Orta Vadeli Hedefler (v1.2)
- [x] Butce limiti: aylik harcama limiti belirleme ve asim uyarisi.
- [x] Doviz kuru donusturme: farkli para birimlerini tek para birimine cevirme.
- [x] iCloud senkronu: cihazlar arasi veri paylasimi (Pro ozelligi).

### Uzun Vadeli Hedefler (v2.0 - Pro)
- [x] Gelir modeli (abonelik sistemi):
  - Ucretsiz katman: temel abonelik ekleme/listeleme, ozet ve bildirimler (maks 7 gun hatirlatma).
  - Pro aylik/yillik:
    - StoreKit 2 entegrasyonu ile gercek satin alma.
    - iCloud senkronu (UI hazir, CloudKit entegrasyonu bekliyor).
    - Ileri raporlama: kategori bazli dagilim grafikleri (pie chart).
    - Genis bildirim ufku (30 gune kadar).
  - Deneme: 7 gun ucretsiz Pro denemesi.
- [x] Siri kisayollari: sesli komutlarla abonelik sorgulama (iOS 16+).
  - "SubTracker'da aylik harcamam ne kadar?"
  - "SubTracker'da yaklasan yenilemelerim var mi?"
  - "SubTracker'da aboneliklerimi goster"
- [ ] Apple Watch uygulamasi: bilekte hizli ozet ve yakin yenilemeler.
- [ ] Aile paylasimi: ortak abonelikleri aile uyeleriyle takip etme.
- [ ] Premium temalar: ozel renk semalari ve uygulama ikonlari.

### Kalite ve Test
- [ ] Birim testleri: model ve hesaplama fonksiyonlari icin.
- [ ] UI testleri: temel CRUD akislari icin otomasyon.
- [x] Bildirim testleri: zamanlama ve iptal senaryolari.

## Mimarinin Cizgileri
- Sunum: SwiftUI + ViewModel (ObservableObject) kombinasyonu, yalın state.
- Veri: Core Data stack, gelecek icin CloudKit hazirligi.
- Servisler: NotificationScheduler, CurrencyConverter, SpotlightManager, WidgetDataManager, ProManager, StoreManager.
- Monetizasyon: StoreKit 2 ile in-app purchase, transaction dogrulama ve abonelik yonetimi.
- Tasarim: Apple Human Interface Guidelines; kart tabanli liste, adaptive grid.

## Calistirma
- Xcode 15+ ve iOS 17+ hedeflenir.
- Projeyi `SubTracker.xcodeproj` ile acip build/run.
- **Pro ozellikleri test icin**: `STOREKIT_SETUP.md` dosyasindaki adimlari takip edin.
- **Siri kisayollari icin**: `SIRI_SHORTCUTS.md` dosyasina bakin (iOS 16+ gerekli).

## 🚀 Production Deployment (App Store Yayinlama)

Uygulamaniz App Store'a yayinlanmaya HAZIR! Asagidaki rehberlere bakin:

### ⚡ YENİ BAŞLAYANLAR İÇİN
**[QUICK_START.md](QUICK_START.md)** - 5 adimda App Store'a yayinlama (buradan baslayin!)

### 🎯 TEKNİK ÖZET
**[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Neler yapildi, ne yapmaniz gerekiyor?

### 📖 Detayli Rehberler
1. **[APP_STORE_CHECKLIST.md](APP_STORE_CHECKLIST.md)** - Hizli checklist (yazdirabilir, isaretle-takip-et)
2. **[PRODUCTION_DEPLOYMENT_GUIDE.md](PRODUCTION_DEPLOYMENT_GUIDE.md)** - 500+ satir kapsamli kilavuz (tum detaylar)

### 📄 Yasal Doküman Templateleri
1. **[PRIVACY_POLICY_TEMPLATE.md](PRIVACY_POLICY_TEMPLATE.md)** - Privacy Policy sablonu (düzenleyip web'e yukleyin)
2. **[TERMS_OF_SERVICE_TEMPLATE.md](TERMS_OF_SERVICE_TEMPLATE.md)** - Terms of Service sablonu (düzenleyip web'e yukleyin)

### ✅ Tamamlanan Kod Degisiklikleri
- ✅ `AppConstants.swift` olusturuldu (Legal URL'leri icerir)
- ✅ `Info.plist` guncellendi (Bildirim izinleri eklendi)
- ✅ `SettingsView` guncellendi (Privacy Policy, Terms, Support linkleri eklendi)
- ✅ App Icon tum boyutlarda mevcut
- ✅ Xcode project dosyasi guncellendi

### 🔧 Simdi Yapmaniz Gerekenler (Oncelik Sirasi)
1. ⚠️ **ÖNCE BU!** `IMPLEMENTATION_SUMMARY.md` dosyasini okuyun
2. **Privacy Policy ve Terms'i duzenleyin** (template'leri kullanin)
3. **Web'e yukleyin** (GitHub Pages, Notion, vs.)
4. **`SubTracker/AppConstants.swift`'te URL'leri guncelleyin** (placeholder'lari degistirin)
5. **Xcode Scheme'den StoreKit Configuration'i kaldirin**
6. **App Store Connect'te setup yapin** (checklist'i takip edin)
7. **Archive olusturun ve upload edin**

### 📞 Destek
Her adim icin detayli aciklamalar dokumanlarda mevcut. Takildiyisniz `PRODUCTION_DEPLOYMENT_GUIDE.md`'deki "Sorun Giderme" bolumune bakin.