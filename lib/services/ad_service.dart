import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_units.dart';

class AdService {
  static const Duration deathInterstitialCooldown = Duration(minutes: 3);

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  DateTime? _lastDeathInterstitialAt;

  bool _startupAdShown = false;
  bool _isShowingInterstitial = false;
  bool _isShowingRewarded = false;

  bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  bool get hasRewardedAd => _rewardedAd != null;

  Future<void> initialize() async {
    if (!isSupportedPlatform) return;
    await MobileAds.instance.initialize();
    _loadInterstitial();
    _loadRewarded();
  }

  Future<void> maybeShowStartupInterstitial({required Duration delay}) async {
    if (!isSupportedPlatform || _startupAdShown) return;
    await Future<void>.delayed(delay);
    if (_startupAdShown) return;
    _startupAdShown = true;
    await _showInterstitial();
  }

  Future<void> maybeShowDeathInterstitial() async {
    if (!isSupportedPlatform) return;
    final now = DateTime.now();
    if (_lastDeathInterstitialAt != null &&
        now.difference(_lastDeathInterstitialAt!) < deathInterstitialCooldown) {
      return;
    }
    final shown = await _showInterstitial();
    if (shown) {
      _lastDeathInterstitialAt = now;
    }
  }

  Future<bool> showRewardedForContinue({
    required VoidCallback onRewardEarned,
  }) async {
    if (!isSupportedPlatform || _isShowingRewarded) return false;
    final ad = _rewardedAd;
    if (ad == null) return false;

    _isShowingRewarded = true;
    var rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isShowingRewarded = false;
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isShowingRewarded = false;
        _loadRewarded();
      },
    );

    await ad.show(
      onUserEarnedReward: (_, __) {
        rewarded = true;
        onRewardEarned();
      },
    );

    return rewarded;
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
  }

  void _loadInterstitial() {
    if (!isSupportedPlatform) return;
    InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  void _loadRewarded() {
    if (!isSupportedPlatform) return;
    RewardedAd.load(
      adUnitId: _rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  Future<bool> _showInterstitial() async {
    if (!isSupportedPlatform || _isShowingInterstitial) return false;
    final ad = _interstitialAd;
    if (ad == null) {
      _loadInterstitial();
      return false;
    }

    _isShowingInterstitial = true;
    var shown = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => shown = true,
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _isShowingInterstitial = false;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialAd = null;
        _isShowingInterstitial = false;
        _loadInterstitial();
      },
    );

    await ad.show();
    return shown;
  }

  String get _interstitialUnitId {
    final configured = AdUnits.interstitial;
    if (configured.isNotEmpty) return configured;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/1033173712';
      case TargetPlatform.iOS:
        return 'ca-app-pub-3940256099942544/4411468910';
      default:
        return '';
    }
  }

  String get _rewardedUnitId {
    final configured = AdUnits.rewarded;
    if (configured.isNotEmpty) return configured;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/5224354917';
      case TargetPlatform.iOS:
        return 'ca-app-pub-3940256099942544/1712485313';
      default:
        return '';
    }
  }
}
