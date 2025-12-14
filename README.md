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
- [x] Abonelik zaman cizelgesi: her abonelik icin iptal/bitis tarihi destegi, gercek yenileme tarihleriyle 12 aylik nakit akisi grafigi.
- [x] Bildirim akisi: yenileme oncesi bildirim planlama/iptal etme, hatirlatici gun ayari.
- [x] Liste gelistirmeleri: kategori/yenileme filtresi, siralama (en yakin, en pahali), arama vurgusu.
- [ ] Analitik kartlar: en pahali 5 abonelik, son 30/90 gun trendi, iptal edilenlerden kazanilan tasarruf.
- [ ] Veri katmani: Core Data + opsiyonel iCloud senkron; JSON yerine kalici store gocmesi.
- [ ] Guvenlik ve gizlilik: Face ID/Touch ID ile kilit, opsiyonel parola.
- [ ] Paylasim ve disari aktarma: CSV/Paylas butonu, coklu profil veya aile paylasimi icin hazirlik.
- [ ] UI/UX: kartlarda yenileme etiketi, detayda gecmis odemeler bolumu, iptal butonu; tema/secim tutarliligi.
- [ ] Testler: model ve hesaplama birim testleri, bildirim planlama testi, CRUD akisi icin UI testi.

## Mimarinin Cizgileri
- Sunum: SwiftUI + ViewModel (ObservableObject) kombinasyonu, yalın state.
- Veri: Core Data stack, gelecek icin CloudKit hazirligi.
- Servisler: NotificationScheduler, CurrencyFormatter, SampleDataLoader.
- Tasarim: Apple Human Interface Guidelines; kart tabanli liste, adaptive grid.

## Calistirma
- Xcode 15+ ve iOS 17+ hedeflenir.
- Projeyi `SubTracker.xcodeproj` ile acip build/run.
