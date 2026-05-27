import 'package:flutter/foundation.dart';

/// Uretim reklam ID'lerini buraya girin.
/// Bos birakirsaniz test reklam ID'leri kullanilir.
class AdUnits {
  // Android
  static const String androidInterstitial = '';
  static const String androidRewarded = '';
  static const String androidAppId = '';

  // iOS
  static const String iosInterstitial = '';
  static const String iosRewarded = '';
  static const String iosAppId = '';

  static String get interstitial {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidInterstitial;
      case TargetPlatform.iOS:
        return iosInterstitial;
      default:
        return '';
    }
  }

  static String get rewarded {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidRewarded;
      case TargetPlatform.iOS:
        return iosRewarded;
      default:
        return '';
    }
  }
}
