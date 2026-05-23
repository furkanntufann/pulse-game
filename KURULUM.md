# NABIZ — Kurulum ve Test Rehberi

Bu klasörde oyun kodu hazır. Bilgisayarınızda **Flutter SDK** kurulduktan sonra aşağıdaki adımlarla çalıştırırsınız.

---

## 1. Kurmanız gereken uygulamalar

| Uygulama | Zorunlu mu? | Ne işe yarar? |
|----------|-------------|----------------|
| [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) | **Evet** | Oyunu derler ve çalıştırır |
| [Git for Windows](https://git-scm.com/download/win) | **Evet** | Flutter kurulumu için gerekli |
| [Android Studio](https://developer.android.com/studio) | Telefonda/emülatörde test için | Android SDK + emülatör |
| [Visual Studio 2022](https://visualstudio.microsoft.com/) — “Desktop development with C++” | Windows masaüstü testi için | `flutter run -d windows` |
| [VS Code](https://code.visualstudio.com/) + **Flutter** eklentisi | Hayır (önerilir) | Kod düzenleme, tek tık çalıştırma |
| Google Chrome | Hızlı web testi için | `flutter run -d chrome` |

> **Not:** Şu an bilgisayarınızda Flutter yüklü değil (`flutter` komutu tanınmıyor). Önce Flutter kurulumunu tamamlayın.

---

## 2. Flutter kurulumu (Windows — özet)

1. https://docs.flutter.dev/get-started/install/windows adresinden **Flutter SDK** indirin (zip).
2. Örneğin `C:\src\flutter` klasörüne çıkartın.
3. **Ortam değişkeni PATH**’e ekleyin: `C:\src\flutter\bin`
4. Yeni bir PowerShell açıp kontrol edin:

```powershell
flutter doctor
```

5. `flutter doctor` çıktısındaki kırmızı uyarıları giderin (Android lisansı, VS Code vb.).

Android lisansı için:

```powershell
flutter doctor --android-licenses
```

---

## 3. Projeyi ilk kez hazırlama

Proje klasöründe (bu `oyun` klasörü):

```powershell
cd "C:\Users\Furkan\OneDrive - Beykent Üniversitesi\Masaüstü\oyun"

flutter create . --project-name nabiz

flutter pub get
```

`flutter create` Android, iOS, Windows, Web klasörlerini oluşturur. Mevcut `lib/` kodunuz korunur.

---

## 4. Nerede test edeceksiniz?

### A) Windows masaüstü (en hızlı — önerilen ilk test)

Bilgisayarınızda Windows olduğu için emülatör kurmadan deneyebilirsiniz:

```powershell
flutter config --enable-windows-desktop
flutter run -d windows
```

- **Nerede:** Açılan masaüstü penceresi  
- **Artı:** Kurulumu kolay, hızlı iterasyon  
- **Eksi:** Dokunmatik hissi yok (fare tıklaması)

---

### B) Chrome tarayıcı (ikinci en hızlı)

```powershell
flutter run -d chrome
```

- **Nerede:** Chrome sekmesi  
- **Artı:** Android Studio’suz bile çalışır  
- **Eksi:** Mağaza sürümü değil; mobil his için yeterli prototip

---

### C) Android emülatör (telefon gibi)

1. Android Studio → **Device Manager** → Sanal cihaz oluştur (ör. Pixel 6).  
2. Emülatörü başlatın.  
3. Terminalde:

```powershell
flutter devices
flutter run
```

- **Nerede:** Android Studio içindeki sanal telefon  
- **Artı:** Gerçek mobil boyut ve dokunma  
- **Eksi:** Bilgisayarı yavaşlatabilir, ilk kurulum uzun

---

### D) Kendi Android telefonunuz (en gerçekçi test)

1. Telefonda **Geliştirici seçenekleri** → **USB hata ayıklama** açın.  
2. USB ile bilgisayara bağlayın.  
3. `flutter devices` ile telefonu görün.  
4. `flutter run` — uygulama telefona yüklenir.

- **Nerede:** Fiziksel telefonunuz  
- **Artı:** Metro/tek elle oynanışı en iyi burada hissedersiniz  
- **Öneri:** Oyunu değerlendirirken **mutlaka** gerçek telefonda test edin

---

### E) iPhone (ileride)

- macOS + Xcode gerekir.  
- Windows’ta doğrudan iOS build alınamaz; ileride Mac veya bulut CI (Codemagic vb.) kullanılır.

---

## 5. Günlük geliştirme komutları

| Komut | Açıklama |
|--------|----------|
| `flutter run` | Varsayılan cihazda çalıştır |
| `flutter run -d windows` | Windows’ta çalıştır |
| `flutter run -d chrome` | Tarayıcıda çalıştır |
| `r` (terminalde) | Hot reload — kod değişince anında yenile |
| `R` | Hot restart — tam yeniden başlat |
| `flutter build apk` | Android APK (arkadaşınıza göndermek için) |

---

## 6. Oyun nasıl oynanır?

1. **Mor halka** merkezden dışa genişler.  
2. **Turkuaz hedef çizgi**ye denk gelince ekrana dokunun.  
3. **Perfect** = yüksek skor + combo.  
4. **Pembe halkalar** tuzak — dokunmayın veya combo sıfırlanır / can gider.  
5. **3 can** biter → oyun biter → tekrar dokunarak yeniden başlar.

---

## 7. Mağazaya çıkmadan önce (ileride)

- Android: `flutter build appbundle` → Google Play Console  
- İkon ve splash: `flutter_launcher_icons` paketi  
- Reklam: `google_mobile_ads` (Faz 2)

---

## Sorun: `sdkmanager` tanınmıyor

`sdkmanager` kurulu olabilir ama **PATH’te değildir**. Kontrol:

```powershell
dir "C:\Users\Furkan\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat"
```

### Kalıcı çözüm — Windows ortam değişkenleri

**Ortam değişkenleri** → Kullanıcı değişkenleri → **Yeni**:

| Ad | Değer |
|----|--------|
| `ANDROID_HOME` | `C:\Users\Furkan\AppData\Local\Android\Sdk` |
| `JAVA_HOME` | `C:\Program Files\Android\Android Studio\jbr` |

**Path** → **Yeni** (üç satır):

```
C:\Users\Furkan\AppData\Local\Android\Sdk\cmdline-tools\latest\bin
C:\Users\Furkan\AppData\Local\Android\Sdk\platform-tools
C:\Program Files\Android\Android Studio\jbr\bin
```

VS Code’u kapatıp açın. Sonra:

```powershell
sdkmanager --version
flutter config --android-sdk C:\Users\Furkan\AppData\Local\Android\Sdk
flutter doctor --android-licenses
flutter doctor
```

### Geçici çözüm (tek oturum)

Proje klasöründe:

```powershell
.\android-sdk-path.ps1
```

Sonra aynı pencerede `flutter doctor --android-licenses` çalıştırın.

---

## Sorun çıkarsa

```powershell
flutter doctor -v
flutter clean
flutter pub get
flutter run
```

Hata mesajını kopyalayıp paylaşırsanız adım adım çözebiliriz.
