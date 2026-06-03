import 'dart:io';
import 'package:flutter/foundation.dart';

// TODO: Replace placeholder IDs with real AdMob IDs from Jay
// Android App ID → AndroidManifest.xml meta-data: com.google.android.gms.ads.APPLICATION_ID
// iOS App ID     → Info.plist: GADApplicationIdentifier
// Current values are Google's official test IDs — safe for development.

class AdIds {
  // ── App IDs (needed in native manifests) ─────────────────────────────────────
  // Android: ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX
  // iOS:     ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX
  static const androidAppId = 'ADMOB_ANDROID_APP_ID_PLACEHOLDER';
  static const iosAppId     = 'ADMOB_IOS_APP_ID_PLACEHOLDER';

  // ── Rewarded ad unit IDs ─────────────────────────────────────────────────────
  // Used for: hints (sudoku), continue-after-mistake (sudoku)
  static final rewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917' // Android test ID
      : 'ca-app-pub-3940256099942544/1712485313'; // iOS test ID

  // ── Interstitial ad unit IDs ─────────────────────────────────────────────────
  // Used for: game completion (optional, between sessions)
  static final interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712' // Android test ID
      : 'ca-app-pub-3940256099942544/4411468910'; // iOS test ID
}

// Reward types returned by rewarded ads
enum AdRewardType { hint, mistakeChance }

/// Manages AdMob rewarded and interstitial ads.
///
/// Usage flow:
///   await AdService.instance.initialize();   // once in main()
///   AdService.instance.loadRewardedAd();     // preload
///   final rewarded = await AdService.instance.showRewardedAd();
///   if (rewarded) { ... grant reward ... }
class AdService extends ChangeNotifier {
  static final instance = AdService._();
  AdService._();

  bool _rewardedAdLoaded = false;
  bool _interstitialAdLoaded = false;
  bool _isShowingAd = false;

  bool get rewardedAdReady => _rewardedAdLoaded;
  bool get interstitialAdReady => _interstitialAdLoaded;
  bool get isShowingAd => _isShowingAd;

  /// Call once from main() after WidgetsFlutterBinding.ensureInitialized().
  Future<void> initialize() async {
    // TODO: Uncomment after adding google_mobile_ads package and real App IDs
    // await MobileAds.instance.initialize();
    await _loadRewardedAd();
    await _loadInterstitialAd();
  }

  // ── Rewarded ads ─────────────────────────────────────────────────────────────

  Future<void> _loadRewardedAd() async {
    // TODO: replace with real implementation
    // RewardedAd.load(
    //   adUnitId: AdIds.rewardedAdUnitId,
    //   request: const AdRequest(),
    //   rewardedAdLoadCallback: RewardedAdLoadCallback(
    //     onAdLoaded: (ad) {
    //       _rewardedAd = ad;
    //       _rewardedAdLoaded = true;
    //       notifyListeners();
    //     },
    //     onAdFailedToLoad: (error) {
    //       _rewardedAdLoaded = false;
    //       notifyListeners();
    //     },
    //   ),
    // );

    // Placeholder: simulate ad being "ready" after short delay
    await Future.delayed(const Duration(milliseconds: 500));
    _rewardedAdLoaded = true;
    notifyListeners();
  }

  /// Shows a rewarded ad. Returns true if the user watched it and earned the reward.
  /// Returns false if ad not ready or dismissed early.
  Future<bool> showRewardedAd() async {
    if (!_rewardedAdLoaded || _isShowingAd) return false;

    _isShowingAd = true;
    _rewardedAdLoaded = false;
    notifyListeners();

    // TODO: replace with real implementation
    // _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
    //   onAdDismissedFullScreenContent: (ad) {
    //     ad.dispose();
    //     _isShowingAd = false;
    //     _loadRewardedAd();
    //     notifyListeners();
    //   },
    // );
    // bool rewarded = false;
    // await _rewardedAd!.show(
    //   onUserEarnedReward: (ad, reward) { rewarded = true; },
    // );
    // return rewarded;

    // Placeholder: simulate 2s ad view and grant reward
    await Future.delayed(const Duration(seconds: 2));
    _isShowingAd = false;
    unawaited(_loadRewardedAd());
    notifyListeners();
    return true; // In placeholder, always reward
  }

  // ── Interstitial ads ─────────────────────────────────────────────────────────

  Future<void> _loadInterstitialAd() async {
    // TODO: replace with real implementation
    // InterstitialAd.load(
    //   adUnitId: AdIds.interstitialAdUnitId,
    //   request: const AdRequest(),
    //   adLoadCallback: InterstitialAdLoadCallback(
    //     onAdLoaded: (ad) { _interstitialAd = ad; _interstitialAdLoaded = true; notifyListeners(); },
    //     onAdFailedToLoad: (_) { _interstitialAdLoaded = false; notifyListeners(); },
    //   ),
    // );
    await Future.delayed(const Duration(milliseconds: 500));
    _interstitialAdLoaded = true;
    notifyListeners();
  }

  /// Shows interstitial if ready (fire-and-forget). Reloads after dismiss.
  Future<void> showInterstitialAd() async {
    if (!_interstitialAdLoaded || _isShowingAd) return;
    _isShowingAd = true;
    _interstitialAdLoaded = false;
    notifyListeners();

    // TODO: replace with real implementation
    // _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
    //   onAdDismissedFullScreenContent: (ad) {
    //     ad.dispose();
    //     _isShowingAd = false;
    //     _loadInterstitialAd();
    //     notifyListeners();
    //   },
    // );
    // await _interstitialAd!.show();

    // Placeholder: no-op
    await Future.delayed(const Duration(milliseconds: 100));
    _isShowingAd = false;
    unawaited(_loadInterstitialAd());
    notifyListeners();
  }
}

// Suppress unused-future warnings for fire-and-forget calls
void unawaited(Future<void> future) => future.ignore();
