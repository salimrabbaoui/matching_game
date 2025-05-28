import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/services/ad_service.dart';

class AdBannerWidget extends StatefulWidget {
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;

  const AdBannerWidget({
    super.key,
    this.margin,
    this.backgroundColor,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    // Check if ads should be shown (not premium user)
    if (!AdService.instance.shouldShowAds()) {
      return;
    }

    // Wait for AdService to be initialized before loading ads
    _waitForAdServiceAndLoad();
  }

  Future<void> _waitForAdServiceAndLoad() async {
    // Wait up to 5 seconds for AdService to be initialized
    int attempts = 0;
    const maxAttempts = 10;
    const delayBetweenAttempts = Duration(milliseconds: 500);

    while (!AdService.instance.isInitialized && attempts < maxAttempts) {
      await Future.delayed(delayBetweenAttempts);
      attempts++;
    }

    if (!AdService.instance.isInitialized) {
      debugPrint('AdBannerWidget: AdService not initialized after waiting');
      return;
    }

    // Always load our own banner ad to avoid ownership conflicts
    _loadBannerAdInternal();
  }

  void _loadBannerAdInternal() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('AdBannerWidget: Banner ad loaded successfully');
          if (mounted) {
            // Small delay to ensure ad is fully ready for display
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                setState(() {
                  _isAdLoaded = true;
                });
              }
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdBannerWidget: Banner ad failed to load: $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isAdLoaded = false;
            });

            // Retry loading after a delay
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                _loadBannerAdInternal();
              }
            });
          }
        },
        onAdOpened: (ad) {
          debugPrint('AdBannerWidget: Banner ad opened');
        },
        onAdClosed: (ad) {
          debugPrint('AdBannerWidget: Banner ad closed');
        },
      ),
    );

    // Load the ad
    _bannerAd!.load();
  }

  @override
  void dispose() {
    debugPrint('AdBannerWidget: Disposing banner ad widget');
    if (_bannerAd != null) {
      _bannerAd!.dispose();
      _bannerAd = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if user is premium
    if (!AdService.instance.shouldShowAds()) {
      return const SizedBox.shrink();
    }

    // If ad is not loaded or doesn't exist, show empty space with fixed height
    if (!_isAdLoaded || _bannerAd == null) {
      return Container(
        height: 60, // Standard banner height with padding
        margin: widget.margin ?? const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            'Loading ad...',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    // Additional safety check: ensure the ad is actually loaded
    try {
      // Show the actual ad with fixed dimensions
      return Container(
        height: 60, // Fixed height to prevent layout issues
        margin: widget.margin ?? const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: AdSize.banner.width.toDouble(),
            height: AdSize.banner.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
      );
    } catch (e) {
      debugPrint('AdBannerWidget: Error displaying ad: $e');
      // If there's an error displaying the ad, show a placeholder
      return Container(
        height: 60,
        margin: widget.margin ?? const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            'Ad unavailable',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ),
      );
    }
  }
}

/// Helper widget for bottom banner ads that are fixed to the bottom of the screen
class BottomBannerAdWidget extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final bool safeArea;

  const BottomBannerAdWidget({
    super.key,
    required this.child,
    this.backgroundColor,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show banner if user is premium
    if (!AdService.instance.shouldShowAds()) {
      return child;
    }

    Widget content = Column(
      children: [
        Expanded(child: child),
        const AdBannerWidget(
          margin: EdgeInsets.only(bottom: 8, left: 8, right: 8),
        ),
      ],
    );

    return safeArea ? SafeArea(child: content) : content;
  }
}

/// A placeholder widget for when ads are disabled or loading
class AdPlaceholderWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final double? height;

  const AdPlaceholderWidget({
    super.key,
    this.message = 'Ad space',
    this.icon,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.grey.shade500, size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
