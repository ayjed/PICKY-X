import 'package:flutter/foundation.dart';
import 'iap_service.dart';

/// AdMonetization engine managing high-eCPM Rewarded Videos, frequency-capped Interstitials, and Banners.
class AdService extends ChangeNotifier {
  final IapService iapService;

  int _levelsCompletedSinceLastInterstitial = 0;
  DateTime _lastInterstitialTime = DateTime.fromMillisecondsSinceEpoch(0);

  AdService({required this.iapService});

  bool get shouldShowAds => !iapService.isAdsRemoved;

  /// High-eCPM Rewarded Video Ad with instant callback
  Future<bool> showRewardedVideo({
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdClosed,
  }) async {
    // Rewarded Video simulation hook with callback
    onUserEarnedReward();
    onAdClosed?.call();
    return true;
  }

  /// Evaluates smart frequency capping and displays Interstitial ad between levels
  Future<bool> maybeShowInterstitialAd() async {
    if (!shouldShowAds) return false;

    _levelsCompletedSinceLastInterstitial++;
    final now = DateTime.now();
    final difference = now.difference(_lastInterstitialTime);

    // Show every 3 completed levels and at least 60 seconds apart
    if (_levelsCompletedSinceLastInterstitial >= 3 && difference.inSeconds >= 60) {
      _levelsCompletedSinceLastInterstitial = 0;
      _lastInterstitialTime = now;
      return true;
    }
    return false;
  }
}
