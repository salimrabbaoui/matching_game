import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../heart_manager.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Singleton pattern for ad service
  static AdService get instance => _instance;

  // Ad unit IDs - Replace with your actual ad unit IDs
  static const String _androidBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String _iosBannerAdUnitId =
      'ca-app-pub-3940256099942544/2934735716'; // Test ID
  static const String _androidInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String _iosInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/4411468910'; // Test ID

  // Banner ad getters
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return _androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return _iosBannerAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Interstitial ad getters
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _androidInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return _iosInterstitialAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Ad instances
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  // Ad state
  bool _isBannerAdReady = false;
  bool _isInterstitialAdReady = false;
  bool _isInitialized = false;

  // Ad loading state
  bool _isLoadingInterstitial = false;
  DateTime? _lastInterstitialShown;

  // Getters
  bool get isBannerAdReady => _isBannerAdReady;
  bool get isInterstitialAdReady => _isInterstitialAdReady;
  bool get isInitialized => _isInitialized;
  BannerAd? get bannerAd => _bannerAd;

  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdService: Mobile Ads SDK initialized successfully');

      // Pre-load both interstitial and banner ads with delay to avoid initialization conflicts
      Future.delayed(const Duration(seconds: 1), () {
        loadInterstitialAd();
        loadBannerAd(); // Also preload banner ads
      });
    } catch (e) {
      debugPrint('AdService: Failed to initialize Mobile Ads SDK: $e');
      // Still mark as initialized to prevent blocking the app
      _isInitialized = true;
    }
  }

  /// Load banner ad
  Future<void> loadBannerAd() async {
    if (!_isInitialized) {
      debugPrint('AdService: SDK not initialized, cannot load banner ad');
      return;
    }

    debugPrint('AdService: Loading banner ad at ${DateTime.now()}...');

    // Dispose existing banner ad if any
    if (_bannerAd != null) {
      debugPrint('AdService: Disposing existing banner ad');
      _bannerAd?.dispose();
    }
    _isBannerAdReady = false;

    try {
      _bannerAd = BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint(
                'AdService: Banner ad loaded successfully at ${DateTime.now()}');
            _isBannerAdReady = true;
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint(
                'AdService: Banner ad failed to load at ${DateTime.now()}: $error');
            _isBannerAdReady = false;
            ad.dispose();
            _bannerAd = null;

            // Retry loading after a delay
            Future.delayed(const Duration(seconds: 30), () {
              debugPrint('AdService: Retrying banner ad load after failure...');
              loadBannerAd();
            });
          },
          onAdOpened: (ad) {
            debugPrint('AdService: Banner ad opened');
          },
          onAdClosed: (ad) {
            debugPrint('AdService: Banner ad closed');
          },
        ),
      );

      debugPrint('AdService: Starting banner ad load...');
      await _bannerAd!.load();
      debugPrint('AdService: Banner ad load() call completed');
    } catch (e) {
      debugPrint('AdService: Error loading banner ad: $e');
      _isBannerAdReady = false;
    }
  }

  /// Load interstitial ad
  Future<void> loadInterstitialAd() async {
    if (!_isInitialized || _isLoadingInterstitial) return;

    _isLoadingInterstitial = true;

    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('AdService: Interstitial ad loaded successfully');
            _interstitialAd = ad;
            _isInterstitialAdReady = true;
            _isLoadingInterstitial = false;

            // Set up full screen content callback
            _interstitialAd!.fullScreenContentCallback =
                FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                debugPrint(
                    'AdService: Interstitial ad showed full screen content');
              },
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('AdService: Interstitial ad dismissed');
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdReady = false;
                _lastInterstitialShown = DateTime.now();

                // Preload the next interstitial ad
                loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('AdService: Interstitial ad failed to show: $error');
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdReady = false;
                _isLoadingInterstitial = false;

                // Retry loading
                Future.delayed(const Duration(seconds: 30), () {
                  loadInterstitialAd();
                });
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdService: Interstitial ad failed to load: $error');
            _isInterstitialAdReady = false;
            _isLoadingInterstitial = false;

            // Retry loading after a delay
            Future.delayed(const Duration(seconds: 30), () {
              loadInterstitialAd();
            });
          },
        ),
      );
    } catch (e) {
      debugPrint('AdService: Error loading interstitial ad: $e');
      _isLoadingInterstitial = false;
    }
  }

  /// Show interstitial ad with cooldown logic
  Future<bool> showInterstitialAd() async {
    // Check cooldown (minimum 30 seconds between ads)
    if (_lastInterstitialShown != null) {
      final timeSinceLastAd =
          DateTime.now().difference(_lastInterstitialShown!);
      if (timeSinceLastAd.inSeconds < 30) {
        debugPrint('AdService: Interstitial ad on cooldown');
        return false;
      }
    }

    if (_interstitialAd != null && _isInterstitialAdReady) {
      try {
        await _interstitialAd!.show();
        return true;
      } catch (e) {
        debugPrint('AdService: Error showing interstitial ad: $e');
        return false;
      }
    } else {
      debugPrint('AdService: Interstitial ad not ready');
      // Try to load if not already loading
      if (!_isLoadingInterstitial) {
        loadInterstitialAd();
      }
      return false;
    }
  }

  /// Show interstitial ad between levels
  Future<void> showLevelCompleteAd(int level) async {
    // Show ad every 2-3 levels, but not on the first level
    if (level > 1 && (level % 2 == 0 || level % 3 == 0)) {
      debugPrint('AdService: Showing level complete ad for level $level');
      await showInterstitialAd();
    }
  }

  /// Show interstitial ad when game over
  Future<void> showGameOverAd() async {
    debugPrint('AdService: Showing game over ad');
    await showInterstitialAd();
  }

  /// Dispose all ads
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdReady = false;

    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;

    debugPrint('AdService: All ads disposed');
  }

  /// Check if premium user (should skip ads)
  bool shouldShowAds() {
    // User is premium if they have unlimited hearts (lastHeartLossTime is null and hearts are at max)
    final heartManager = HeartManager();
    final hasUnlimitedHearts = heartManager.lastHeartLossTime == null &&
        heartManager.hearts == heartManager.maxHeartsCount;

    // Don't show ads for premium users
    return !hasUnlimitedHearts;
  }

  /// Get current ad status for debugging
  Map<String, dynamic> getAdStatus() {
    return {
      'isInitialized': _isInitialized,
      'isBannerAdReady': _isBannerAdReady,
      'isInterstitialAdReady': _isInterstitialAdReady,
      'isLoadingInterstitial': _isLoadingInterstitial,
      'lastInterstitialShown': _lastInterstitialShown?.toIso8601String(),
      'bannerAdExists': _bannerAd != null,
    };
  }

  /// Helper method to check if enough time has passed to show another interstitial
  bool canShowInterstitialAd() {
    if (_lastInterstitialShown == null) return true;

    final timeSinceLastAd = DateTime.now().difference(_lastInterstitialShown!);
    return timeSinceLastAd.inSeconds >= 30;
  }
}
