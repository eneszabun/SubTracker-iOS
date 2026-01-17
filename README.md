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
- [ ] Gelir modeli (abonelik sistemi):
  - Ucretsiz katman: temel abonelik ekleme/listeleme, ozet ve bildirimler.
  - Pro aylik/yillik:
    - iCloud senkronu.
    - Ileri raporlama: kategori bazli dagilim grafikleri, birikimli nakit akisi analizi.
    - Premium temalar ve ozel ikonlar.
    - Genis bildirim ufku (30 gune kadar).
  - Deneme: 7 gun ucretsiz Pro denemesi.
- [ ] Apple Watch uygulamasi: bilekte hizli ozet ve yakin yenilemeler.
- [ ] Siri kisayollari: sesli komutlarla abonelik ekleme/sorgulama.
- [ ] Aile paylasimi: ortak abonelikleri aile uyeleriyle takip etme.

### Kalite ve Test
- [ ] Birim testleri: model ve hesaplama fonksiyonlari icin.
- [ ] UI testleri: temel CRUD akislari icin otomasyon.
- [x] Bildirim testleri: zamanlama ve iptal senaryolari.

## Mimarinin Cizgileri
- Sunum: SwiftUI + ViewModel (ObservableObject) kombinasyonu, yalın state.
- Veri: Core Data stack, gelecek icin CloudKit hazirligi.
- Servisler: NotificationScheduler, CurrencyConverter, SpotlightManager, WidgetDataManager, ProManager.
- Tasarim: Apple Human Interface Guidelines; kart tabanli liste, adaptive grid.

## Calistirma
- Xcode 15+ ve iOS 17+ hedeflenir.
- Projeyi `SubTracker.xcodeproj` ile acip build/run.
