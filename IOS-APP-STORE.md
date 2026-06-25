# Ripple Rush — iOS / App Store yayını

Android tamam. iOS için aynı oyun, aynı bundle ID: **`com.tufan.pulsegame`**

---

## Ön koşullar

| Gerekli | Not |
|---------|-----|
| **Apple Developer Program** | 99 USD/yıl — [developer.apple.com](https://developer.apple.com) |
| **Codemagic** | `pulse-game` repo bağlı |
| **App Store Connect API** | Codemagic → Teams → Integrations → **Pulse** |
| **Distribution sertifikası + App Store profili** | Codemagic’e yüklü (aşağıda) |

---

## Adım 1 — App Store Connect (zaten var: Pulse)

**Yeni uygulama oluşturmayın.** Daha önce oluşturduğunuz **Pulse** kaydını kullanın.

1. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **My Apps** → **Pulse**
2. Kontrol edin:
   - Bundle ID: **`com.tufan.pulsegame`** (projeyle aynı olmalı)
   - Platform: iOS
3. Mağaza adını güncellemek isterseniz:
   - **App Store** sekmesi → sürüm → **Name**: **Ripple Rush**
   - (Uygulama Connect’te internal ad “Pulse” kalabilir; mağazada görünen ad Ripple Rush olur)

Gizlilik politikası (Android ile aynı):

```
https://furkanntufann.github.io/pulse-game/privacy-policy.html
```

> Bundle ID bir kez seçilir, değişmez. `com.tufan.pulsegame` doğruysa devam edin.

---

## Adım 2 — iOS imzalama (sıfırdan)

Tüm imzalama dosyaları bu klasörde:

```
C:\Users\Furkan\OneDrive - Beykent Üniversitesi\Masaüstü\RippleRush-iOS-Signing\
```

Detaylı rehber: aynı klasördeki **`README.md`** ve **`SILME-ONCESI-OKU.txt`**

### Apple’da temizlik (Identifier dahil silersen)

1. **Profiles** → sil
2. **Certificates** → revoke
3. **Identifiers** → silindiysen **yeniden oluştur:** Explicit → **`com.tufan.pulsegame`** (Android ile aynı — değiştirme)
4. Codemagic → eski iOS cert + profile sil

> **Silme:** Google Play, `upload-keystore.jks`, App Store Connect **Pulse** uygulaması.

### A) Key + CSR + .p12

PowerShell:

```powershell
cd "C:\Users\Furkan\OneDrive - Beykent Üniversitesi\Masaüstü\RippleRush-iOS-Signing"
.\1-create-csr.ps1
```

Apple → **Certificates** → **Apple Distribution** → upload: **`ripple_rush_distribution.csr`**

İndirilen `.cer` dosyasını klasöre kaydet: **`ripple_rush_distribution.cer`**

```powershell
.\2-create-p12.ps1
```

### B) App Store profili

**Profiles** → **+** → **App Store Connect** → `com.tufan.pulsegame` → yeni Distribution cert

İndir → **`ripple_rush_appstore.mobileprovision`**

### C) Codemagic’e yükle

**Teams** → **Code signing identities**:

| Tür | Dosya |
|-----|--------|
| **iOS certificates** | `ripple_rush_distribution.p12` |
| **iOS provisioning profiles** | `ripple_rush_appstore.mobileprovision` |

Profil: bundle **com.tufan.pulsegame**, tip **App Store**, yeşil sertifika tik’i.

---

## Adım 3 — Build al

```powershell
git push origin main
```

Codemagic → **Start new build** → **Ripple Rush iOS** → branch **main**

Başarılı log:

- `Distribution type: App Store` (Development değil)
- IPA artifact oluşur
- **Publishing** → TestFlight’a yükleme (integration açıksa)

---

## Adım 4 — TestFlight (iPhone’da test)

1. App Store Connect → **Pulse** (mevcut uygulama) → **TestFlight**
2. Build işlenince (15–60 dk) görünür
3. **Internal testing** → kendi Apple ID e-postanı ekle
4. iPhone’da **TestFlight** uygulamasından kur

---

## Adım 5 — App Store’a gönder (yayın)

TestFlight’ta sorun yoksa:

1. **App Store** sekmesi → **+ Version** → `1.0.0`
2. **Screenshots** — iPhone 6.7" (1290×2796) en az 3 adet
3. **Description** — `STORE-LISTING.md` metinlerini kullan (EN veya TR)
4. **Build** seç (TestFlight’taki IPA)
5. **Content rights**, **Age rating**, **App Privacy** formları
6. **Submit for Review**

İnceleme genelde **1–3 gün**.

---

## Sık hatalar

| Hata | Çözüm |
|------|--------|
| No matching profiles / app_store | Codemagic’e App Store profili + Distribution `.p12` yükle |
| 403 certificate create | Elle sertifika; API Admin değil |
| 90161 Development profile | IPA App Store profili ile imzalanmalı — yaml zaten `app-store` |
| App crash açılışta | AdMob kaldırıldı; `Info.plist`’te GAD ID yok |

---

## Checklist

```
[ ] Apple Developer Program aktif
[ ] App Store Connect’te mevcut **Pulse** uygulaması (bundle com.tufan.pulsegame)
[ ] Distribution .p12 + App Store profile → Codemagic
[ ] Pulse API integration bağlı
[ ] Codemagic Ripple Rush iOS build → IPA
[ ] TestFlight internal test
[ ] iPhone ekran görüntüleri + mağaza metni
[ ] Submit for Review
```

---

## Android ile farklar

| | Android | iOS |
|--|---------|-----|
| Mağaza | Google Play | App Store |
| Dosya | `.aab` | `.ipa` |
| Test | Dahili/Açık test | TestFlight |
| Ücret | 25 USD (tek) | 99 USD/yıl |
| İmzalama | upload-keystore.jks | Distribution cert + profile |

Reklamlar şu an **kapalı** (Android ile aynı). AdMob sonra eklenebilir.
