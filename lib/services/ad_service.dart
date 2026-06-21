import 'package:flutter/foundation.dart';

/// Reklamlar gecici olarak kapali (Play Store test icin).
/// AdMob hesabi hazir olunca google_mobile_ads tekrar eklenebilir.
class AdService {
  static const Duration deathInterstitialCooldown = Duration(minutes: 3);

  bool get isSupportedPlatform => false;

  bool get hasRewardedAd => false;

  Future<void> initialize() async {}

  Future<void> maybeShowStartupInterstitial({required Duration delay}) async {}

  Future<void> maybeShowDeathInterstitial() async {}

  Future<bool> showRewardedForContinue({
    required VoidCallback onRewardEarned,
  }) async {
    return false;
  }

  void dispose() {}
}
