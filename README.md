# SubTracker iOS

SwiftUI tabanli, abonelik ve düzenli harcama takibi uygulamasi. Kullanici tum aboneliklerini kaydeder, yenileme tarihlerini ve toplam aylik/yillik maliyeti gorur, hatirlatmalar alir ve iptal/yenileme kararlarini planlar.

## Uygulama Kurallari
- Veriyi oncelikle yerelde Core Data ile sakla; opsiyonel iCloud senkronu ileride eklenecek.
- Abonelik kartlari sade, aksiyon odakli: isim, kategori, tutar, dongu (aylik/yillik), yenileme tarihi, notlar.
- Bildirimler yalnizca kritik anlarda: yenilemeden 3 gun once ve yenileme gunu.
- Giris/duzenleme formlarinda zorunlu alanlar: isim, tutar, para birimi, yenileme araligi; digerleri opsiyonel.
- Karanlik/aydınlık tema destekle; dinamik renkler kullan.
- Erişilebilirlik: Dynamic Type, VoiceOver etiketleri, kontrast kurallari.
- Gizlilik: takip/analitik varsayilan kapali, yalnizca yerel depolama.

## Yol Haritasi ve Yapilacaklar
- [ ] Minimum iskelet: SwiftUI tabanli, iki ana sekme (Ozet, Abonelikler).
- [ ] Model: `Subscription` ve `BillingCycle` tipleri, Core Data store.
- [ ] Ozet ekran: toplam aylik/yillik maliyet, yakin yenilemeler listesi.
- [ ] Abonelik listesi: filtreleme (kategori/dongu), arama, surukle-sil.
- [ ] Abonelik olustur/duzenle akisi: form dogrulama, tarih secici, para birimi secimi.
- [ ] Bildirim planlayici: UNUserNotificationCenter entegrasyonu, izin akisi.
- [ ] Ayarlar: para birimi varsayilani, bildirim tercihleri, veri yedekleme uyarisi.
- [ ] Testler: model ve hesaplama birim testleri; en az 1 UI testi (liste gosterimi).

## Mimarinin Cizgileri
- Sunum: SwiftUI + ViewModel (ObservableObject) kombinasyonu, yalın state.
- Veri: Core Data stack, gelecek icin CloudKit hazirligi.
- Servisler: NotificationScheduler, CurrencyFormatter, SampleDataLoader.
- Tasarim: Apple Human Interface Guidelines; kart tabanli liste, adaptive grid.

## Calistirma
- Xcode 15+ ve iOS 17+ hedeflenir.
- Projeyi `SubTracker.xcodeproj` ile acip build/run.

