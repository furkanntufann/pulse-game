# Pulse — Google Play Store yükleme

iOS’u atlayıp doğrudan Android ile Play Store’a gidebilirsiniz. Paket adı: **`com.tufan.pulsegame`**

---

## Özet (sıra)

1. Google Play Console hesabı (tek seferlik ~25 USD)
2. Uygulama oluştur
3. Keystore’u Codemagic’e ekle
4. Codemagic **Pulse Android** build → `.aab` indir veya otomatik yükle
5. Play Console’da inceleme / yayın

---

## 1) Google Play Console

1. https://play.google.com/console → Google hesabı  
2. Geliştirici kaydı (~**25 USD**, tek seferlik)  
3. **Create app**  
   - Ad: **Pulse**  
   - Varsayılan dil: Türkçe  
   - Uygulama / oyun: **Game**  
4. **Dashboard** → zorunlu bölümleri doldurun (gizlilik politikası URL’si, ekran görüntüleri, kısa/açıklama metni vb.)

> İlk sürüm için en az bir **AAB** yüklemeniz gerekir; mağaza sayfasının bir kısmı sonra da tamamlanabilir.

---

## 2) Codemagic — keystore (imzalama)

Projede `upload-keystore.jks` ve `android/key.properties` var (Git’e **girmez**).

### Keystore’u base64 yapın (Windows PowerShell)

```powershell
cd "C:\Users\Furkan\OneDrive - Beykent Üniversitesi\Masaüstü\oyun"
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Set-Clipboard
```

Panodaki metin = **CM_KEYSTORE** değeri.

### Codemagic ortam değişkenleri

**pulse-game** → **Environment variables** → grup **`keystore_credentials`**:

| Değişken | Değer | Secret |
|----------|--------|--------|
| `CM_KEYSTORE` | base64 (yukarıdaki) | ✅ |
| `CM_KEYSTORE_PASSWORD` | key.properties içindeki store şifresi | ✅ |
| `CM_KEY_PASSWORD` | key.properties içindeki key şifresi | ✅ |
| `CM_KEY_ALIAS` | `upload` | hayır |

Kaydedin.

---

## 3) Build alın

```powershell
cd "C:\Users\Furkan\OneDrive - Beykent Üniversitesi\Masaüstü\oyun"
git add codemagic.yaml android PLAY-STORE.md
git commit -m "Google Play Android build"
git push
```

Codemagic → **pulse-game** → **Start new build** → workflow: **Pulse Android**

Başarılı olunca **Artifacts** → `app-release.aab` indirin.

---

## 4) Play Console’a elle yükleme (en kolay)

1. Play Console → uygulama → **Testing** → **Internal testing** (veya **Production**)  
2. **Create new release**  
3. **App bundles** → indirdiğiniz `.aab` dosyasını sürükleyin  
4. Sürüm notları → **Save** → **Review release** → **Start rollout**

Test için: **Internal testing** → testçi e-postası ekleyin → paylaşılan linkten yükleyin.

---

## 5) Codemagic’ten otomatik yükleme (isteğe bağlı)

1. Play Console → **Setup** → **API access** → **Create service account**  
2. Google Cloud’da JSON anahtar indirin  
3. Play Console’da bu hesaba **Release manager** (veya en azından release) yetkisi verin  
4. Codemagic → Environment variables → grup **`google_play_credentials`**:
   - `GOOGLE_PLAY_SERVICE_ACCOUNT_CREDENTIALS` = JSON dosyasının **tüm içeriği** (Secret)

`codemagic.yaml` içinde `publishing.google_play` zaten tanımlı; credentials ekleyince build sonrası **internal** track’e draft olarak gider.

Credentials yoksa build yine **AAB üretir**; sadece otomatik yükleme çalışmaz — elle yükleyin.

---

## Lokal test (telefonda)

```powershell
flutter build apk --release
```

APK: `build\app\outputs\flutter-apk\app-release.apk`  
(Release imzası için `android/key.properties` + `upload-keystore.jks` gerekir.)

---

## Sorun giderme

| Sorun | Çözüm |
|--------|--------|
| CM_KEYSTORE hatası | base64 ve şifreleri Codemagic’te kontrol edin |
| Play “imza uyuşmuyor” | Hep aynı `upload-keystore.jks` kullanın; yenisini üretmeyin |
| versionCode çakışması | `pubspec.yaml` içinde `version: 1.0.0+4` gibi **+** sonrası sayıyı artırın |
| AdMob test ID | Canlıya çıkmadan `AndroidManifest.xml` içinde kendi AdMob App ID’nizi koyun |

---

## Önemli

- **`upload-keystore.jks` dosyasını kaybetmeyin** — Play’de güncelleme için aynı anahtar şart.  
- Yedek: güvenli bir yere kopyalayın (bulut + USB).  
- iOS / Codemagic Apple adımlarına şimdilik gerek yok.
