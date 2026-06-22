# Ripple Rush — Play Store görselleri

Play Console çok alan gösterir; **hepsini doldurmanız gerekmez.**

---

## Zorunlu (yayın için)

| Varlık | Boyut | Adet | Not |
|--------|--------|------|-----|
| **Uygulama simgesi** | 512×512 px, PNG/JPEG | 1 | Play Console → Mağaza girişi |
| **Özellik grafiği** | **1024×500** px, PNG/JPEG (alfa yok) | 1 | Zorunlu banner |
| **Telefon ekran görüntüsü** | 1080×1920 (9:16 dikey) veya 1920×1080 | **En az 3** (oyun) | Oyun içi ekran |

Projede hazır taslaklar: `store-assets/` klasörü (simge + feature graphic).

---

## İsteğe bağlı (boş bırakabilirsiniz)

| Varlık | Gerek var mı? |
|--------|----------------|
| **Tanıtım videosu** | Hayır — YouTube linki isteğe bağlı |
| **7" / 10" tablet** | Hayır* — telefon SS’lerini kopyalayabilir veya 4 tablet SS |
| **Chromebook** | **Hayır** — dokunmatik oyun, PC hedeflemiyorsunuz |
| **Google Play Games on PC** | **Hayır** — programa kaydolmadıysanız atlayın |
| **Android XR** | **Hayır** — VR/ XR desteklemiyorsunuz |

\* MatePad’de de oynanır; Play’de “telefon” SS’leri çoğu zaman yeter.

---

## Atlamak için (Play Console)

1. **Play Console** → uygulama → **Test edin ve yayınlayın** → **Cihaz kataloğu**  
2. Chromebook / PC / XR cihazlarını **hariç tut** (touch-only oyun)  
3. Mağaza listesinde Chromebook / PC / XR bölümlerini **boş bırakın**

Böylece “eksik Chromebook görseli” uyarısı genelde engellenir veya yalnızca bilgi olur.

---

## Boyut özeti

```
Uygulama simgesi (Play):     512 × 512
Özellik grafiği:             1024 × 500  (tam bu boyut)
Telefon SS (oyun, dikey):    1080 × 1920 (min 3 adet)
Telefon SS (alternatif):     1920 × 1080 (yatay, min 3)
Tablet SS (isterseniz):      1080 × 1920 veya 1920 × 1080 (min 4)
Video:                       YouTube URL (opsiyonel)
```

Dosya: JPEG veya 24-bit PNG (**şeffaflık yok**), max ~8 MB.

---

## Ekran görüntüsü nasıl alınır?

### MatePad / telefon (en kolay)

1. **Ripple Rush v8** kurulu olsun  
2. Sırayla ekran görüntüsü al:
   - Başlangıç ekranı (RIPPLE RUSH)
   - Oyun oynanırken (mor halka)
   - Game over / skor ekranı
3. Gerekirse bilgisayarda **1080×1920** kırp (Paint, Photopea, Canva)

### Android emülatör (PC)

1. Android Studio → Pixel 6 emülatör  
2. `flutter run --release`  
3. Emülatör yan çubuk → **Screenshot** (Ctrl+S)

---

## Mağaza metinleri

`STORE-LISTING.md` dosyasına bakın.

---

## Gizlilik politikası URL

```
https://furkanntufann.github.io/pulse-game/privacy-policy.html
```

(GitHub Pages açık olmalı.)

---

## Hızlı checklist

```
[ ] store-assets/ içindeki simge + feature graphic yükle
[ ] 3 telefon ekran görüntüsü (oyun içi)
[ ] STORE-LISTING.md kısa + tam açıklama
[ ] Gizlilik politikası URL
[ ] Chromebook / PC / XR → boş veya cihaz hariç tut
[ ] AAB v10 yükle
```

---

## Play Console — sık hatalar

**"Hiçbir uygulama paketi eklemiyor"** → Sürüme AAB yüklenmemiş. Önce paketi yükle, sonra onayla.

**"Sürüm kodu kullanıldı"** → Yeni build al (+10, +11…).

**Reklam kimliği uyarısı** → Uygulama içeriği → Reklam kimliği → **Kullanmıyor** seçin.
