# NABIZ — Android SDK + Java (bu PowerShell oturumu icin)
# Kalici kurulum: asagidaki 3 degiskeni Windows Ortam Degiskenlerine ekleyin (KURULUM.md)

$sdk = "C:\Users\Furkan\AppData\Local\Android\Sdk"
$java = "C:\Program Files\Android\Android Studio\jbr"

$env:ANDROID_HOME = $sdk
$env:ANDROID_SDK_ROOT = $sdk
$env:JAVA_HOME = $java
$env:Path = "$java\bin;$sdk\cmdline-tools\latest\bin;$sdk\platform-tools;$env:Path"

Write-Host "ANDROID_HOME = $env:ANDROID_HOME"
Write-Host "sdkmanager test:"
& "$sdk\cmdline-tools\latest\bin\sdkmanager.bat" --version

Write-Host ""
Write-Host "Sonraki komutlar:"
Write-Host "  flutter config --android-sdk $sdk"
Write-Host "  flutter doctor --android-licenses"
Write-Host "  flutter doctor"
