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
3. **Identifiers** → **+** → App IDs → Bundle ID: **`com.tufan.pulsegame`** (projeyle aynı)  
4. Codemagic’te uygulamanız → **Settings** → **codemagic.yaml** iş akışı `pulse-ios`  
5. **Teams** → **Integrations** → **Developer Portal** → Apple ID veya **App Store Connect API key** bağlayın  
6. **`CERTIFICATE_PRIVATE_KEY`** (zorunlu) — aşağıdaki alt bölüm  
7. **Teams** → **Integrations** → **App Store Connect** → `Pulse` API anahtarı (yaml’daki `integrations.app_store_connect` ile aynı ad)  
8. **Code signing identities** (isteğe bağlı): UI’da profil yoksa sorun değil; build sırasında **App Store** profili Apple’dan çekilir  

### CERTIFICATE_PRIVATE_KEY (Windows)

Bu anahtar olmadan build şu hatayı verir: *Cannot save Signing Certificates without certificate private key*.

1. PowerShell (proje klasöründe veya Masaüstü’nde):

```powershell
ssh-keygen -t rsa -b 2048 -m PEM -f ios_distribution_private_key -q -N '""'
```

2. `ios_distribution_private_key` dosyasını Not Defteri ile açın — **tamamını** kopyalayın (`-----BEGIN RSA PRIVATE KEY-----` … `-----END RSA PRIVATE KEY-----`).

3. Codemagic → uygulama **pulse-game** → **Environment variables** → **Add**:
   - **Variable name:** `CERTIFICATE_PRIVATE_KEY` (tam bu isim)
   - **Variable value:** kopyaladığınız private key
   - **Secret:** işaretli
   - **Group name:** `code-signing` (yaml’daki `groups` ile aynı)

4. **Save** → yeni build. İlk seferde Codemagic Apple’da **iOS Distribution** sertifikası + **App Store** profili oluşturabilir.

> Bu dosyayı GitHub’a **commit etmeyin**. Sadece Codemagic’te Secret olarak kalsın.

### 403 — “not allowed to perform this operation” (Distribution sertifikası)

Log’da şunu görürseniz API anahtarı sertifika **oluşturamaz** (yetki veya hesap rolü):

```text
POST .../v1/certificates returned 403: ... not allowed to perform this operation
```

**Çözüm A — API anahtarını düzeltin (tercih)**

1. [App Store Connect](https://appstoreconnect.apple.com) → **Users and Access** → **Integrations** → **App Store Connect API**  
2. Yeni anahtar: **Access** = **Admin** (veya sertifika yönetebilen **Account Holder** hesabıyla oluşturun)  
3. `.p8` dosyasını indirin (yalnızca bir kez)  
4. Codemagic → **Teams** → **Integrations** → **Pulse** → anahtarı güncelleyin  
5. Yeniden build  

**Çözüm B — Sertifikayı elle oluşturup Codemagic’e yükleyin (403 devam ederse)**

1. [developer.apple.com](https://developer.apple.com/account) → **Certificates** → **+** → **Apple Distribution**  
2. CSR için (PowerShell, `ios_distribution_private_key` ile **aynı** anahtar):

```powershell
openssl req -new -key ios_distribution_private_key -out ios_dist.csr -subj "/email=tufanyazilimdanismanlik@gmail.com/CN=Tufan/C=TR"
```

3. CSR’yi Apple’a yükleyin → indirilen `.cer` dosyasını kaydedin  
4. **Profiles** → **+** → **App Store** → `com.tufan.pulsegame` → az önceki Distribution sertifikasını seçin → profili indirin (`.mobileprovision`)  
5. Codemagic → **Teams** → **Code signing identities** →  
   - **iOS certificates:** `.p12` yükleyin (sertifika + private key; şifre boş veya kendi şifreniz)  
   - **iOS provisioning profiles:** `.mobileprovision` yükleyin  
6. `codemagic.yaml` içinde `ios_signing` ile `distribution_type: app_store` kullanın; `fetch-signing-files --create` satırını kaldırın veya `--create` olmadan yalnızca indirme yapın  

> **Not:** Apple hesabınızda yıllık **Apple Developer Program** (99 USD) ve hesapta **Admin / Account Holder** rolü olmalı. Sadece “Developer” davetli kullanıcılar sertifika oluşturamaz.

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
| **Cannot save Signing Certificates without certificate private key** | `CERTIFICATE_PRIVATE_KEY` yok veya grup adı `code-signing` değil; yukarıdaki adımları uygulayın |
| **403** / not allowed to perform this operation | App Store Connect API anahtarı **Admin** değil veya hesap sertifika oluşturamaz; yukarıdaki **403** bölümüne bakın |
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
