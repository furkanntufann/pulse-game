# Pulse — Codemagic ile iPhone’a yükleme

Windows’ta iOS derlenemez; **Codemagic** bulutta Mac kullanarak IPA üretir. 14 günlük deneme ile test edebilirsiniz.

---

## Ön koşullar

| Gerekli | Açıklama |
|---------|----------|
| **GitHub hesabı** | Projeyi Codemagic’e bağlamak için |
| **Apple Developer Program** | iPhone’a yükleme / TestFlight için (**99 USD/yıl**) |
| **Codemagic hesabı** | https://codemagic.io/signup |

> Ücretsiz Apple ID ile yalnızca Mac’te 7 günlük test yapılır; Codemagic + gerçek cihaz için genelde **ücretli geliştirici hesabı** gerekir.

---

## Adım 1 — Projeyi GitHub’a yükleyin

PowerShell (proje klasöründe):

```powershell
cd "C:\Users\Furkan\OneDrive - Beykent Üniversitesi\Masaüstü\oyun"

git init
git add .
git commit -m "Pulse oyunu - Codemagic icin ilk surum"
```

GitHub’da yeni repo oluşturun (ör. `pulse-game`), sonra:

```powershell
git remote add origin https://github.com/furkanntufann/pulse-game.git
git branch -M main
git push -u origin main
```

`.gitignore` zaten `build/`, `.dart_tool/` gibi klasörleri hariç tutar.

---

## Adım 2 — Codemagic’e kayıt ve bağlama

1. https://codemagic.io/signup → GitHub ile giriş  
2. **Add application** → GitHub repo’nuzu seçin (`pulse-game`)  
3. **Flutter App** şablonunu seçin  
4. **codemagic.yaml** dosyasını repo kökünde algılamalı (projede hazır)

---

## Adım 3 — Apple imzalama (iOS)

1. [Apple Developer](https://developer.apple.com/account) → hesap açın / giriş  
2. **Certificates, Identifiers & Profiles**  
3. **Identifiers** → **+** → App IDs → Bundle ID: **`com.pulse.game`** (projeyle aynı)  
4. Codemagic’te uygulamanız → **Settings** → **codemagic.yaml** iş akışı `pulse-ios`  
5. **Teams** → **Integrations** → **Developer Portal** → Apple ID veya **App Store Connect API key** bağlayın  
6. **Environment variables** → grup `code-signing` → **`CERTIFICATE_PRIVATE_KEY`** (RSA private key, `-----BEGIN RSA PRIVATE KEY-----` ile) — dağıtım sertifikası oluşturmak için gerekli  
7. **Teams** → **Integrations** → **App Store Connect** → `Pulse` API anahtarı (yaml’daki `integrations.app_store_connect` ile aynı ad)  
8. **Code signing identities** (isteğe bağlı): UI’da profil yoksa sorun değil; `codemagic.yaml` build sırasında **App Store** profilini Apple’dan çeker. UI’da yalnızca **development** varsa `ios_signing: app_store` **kullanmayın** — “No matching profiles found” hatası verir  

### iPhone 15 Pro Max UDID (development için)

- iPhone’u Mac’e bağlayıp Xcode → Window → Devices, **veya**  
- https://udid.tech gibi sitelerden UDID alıp Apple Developer → **Devices** → ekleyin  

---

## Adım 4 — Build başlat

1. Codemagic → uygulama → **Start new build**  
2. Workflow: **Pulse iOS** (`pulse-ios`)  
3. Branch: `main`  
4. Build bitince **Artifacts** → `.ipa` indirin  

Android denemek için: workflow **Pulse Android** → `.apk` indirilir.

---

## Adım 5 — iPhone’a yükleme

### A) TestFlight (önerilen, Developer hesabı ile)

1. Codemagic **pulse-ios** workflow’unda `distribution_type: app_store` yapın (veya UI’dan App Store dağıtımı)  
2. **Publishing** → App Store Connect / TestFlight ayarlarını Codemagic dokümantasyonuna göre ekleyin  
3. iPhone’da **TestFlight** uygulamasından **Pulse**’u kurun  

### B) IPA dosyası (development / ad hoc)

1. `.ipa` indirin  
2. **Apple Configurator 2** (Mac) veya Codemagic’in verdiği QR / link (ayara bağlı)  
3. Cihaz **Geliştirici modu** açık olsun  

---

## Sorun giderme

| Sorun | Çözüm |
|--------|--------|
| **Scheme "Runner" not found** | `ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme` GitHub’da olmalı. Commit + push. Güncel `codemagic.yaml` eksikse otomatik tamamlar. |
| Signing failed | Bundle ID `com.pulse.game` Apple + Codemagic’te aynı mı kontrol edin |
| Build failed flutter | `flutter pub get` lokal çalışıyor mu; `pubspec.lock` commit’lendi mi |
| IPA yok | `pulse-ios` workflow seçildi mi; log’da `flutter build ipa` hatası var mı |
| **No matching profiles** + `app_store` | Codemagic UI’da App Store profili yok; `ios_signing` bloğunu kaldırın, yaml’daki `fetch-signing-files --type IOS_APP_STORE` kullanın |
| **90161** / Invalid Provisioning Profile | IPA **Development** ile imzalanmıştır. `IOS_APP_STORE` ve `ExportOptions` → `app-store` olmalı; yeniden build alın |
| 14 gün bitti | APK için Android workflow hâlâ işe yarar; iOS için plan veya Mac |

---

## Özet komutlar (lokal kontrol)

```powershell
flutter pub get
flutter analyze
flutter build apk --release
```

iOS build yalnızca Codemagic veya Mac’te:

```bash
flutter build ipa --release
```

---

## Faydalı linkler

- Codemagic Flutter: https://docs.codemagic.io/flutter/flutter-projects/
- iOS code signing: https://docs.codemagic.io/flutter-code-signing/ios-code-signing/
- Apple Developer: https://developer.apple.com/programs/
