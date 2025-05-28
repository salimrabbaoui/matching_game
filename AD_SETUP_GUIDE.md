# Ad Setup Guide for Matching Game

This guide will help you set up Google Mobile Ads (AdMob) in your matching game to display banner ads at the bottom of screens and interstitial video ads between levels.

## 📋 Prerequisites

1. Google AdMob account
2. Flutter development environment
3. Android/iOS app configured in AdMob

## 🚀 Step 1: Google AdMob Account Setup

### Create AdMob Account
1. Go to [Google AdMob](https://admob.google.com/)
2. Sign in with your Google account
3. Complete the account setup process

### Create Your App in AdMob
1. Click "Add App" in the AdMob console
2. Choose your platform (Android/iOS)
3. Enter your app name: "Sock Matching Game"
4. Note down the **App ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXXX~XXXXXXXXXX`)

### Create Ad Units
Create the following ad units in AdMob:

#### Banner Ad Unit
- **Name**: "Game Banner"
- **Format**: Banner
- **Size**: Standard (320x50)
- Note the **Ad Unit ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXXX/XXXXXXXXXX`)

#### Interstitial Ad Unit
- **Name**: "Level Complete Interstitial"
- **Format**: Interstitial
- **Type**: Video (recommended) or Display
- Note the **Ad Unit ID**

## 🔧 Step 2: Configure Ad Unit IDs

Replace the test IDs in `lib/core/services/ad_service.dart`:

```dart
class AdService {
  // Replace these test IDs with your actual AdMob Ad Unit IDs
  
  // Android Ad Unit IDs
  static const String _androidBannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _androidInterstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXXX/XXXXXXXXXX';
  
  // iOS Ad Unit IDs  
  static const String _iosBannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _iosInterstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXXX/XXXXXXXXXX';
  
  // ... rest of the code
}
```

## 📱 Step 3: Configure Platform-Specific Settings

### Android Configuration

Update `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Replace with your actual AdMob App ID -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

### iOS Configuration

Update `ios/Runner/Info.plist`:

```xml
<!-- Replace with your actual AdMob App ID -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
```

## ⚡ Step 4: Ad Integration Features

The game is already configured with the following ad features:

### Banner Ads
- **Location**: Bottom of all game screens
- **Type**: Standard banner (320x50)
- **Behavior**: 
  - Automatically loads when screen opens
  - Graceful fallback if ads fail to load
  - Hidden for premium users
  - Responsive to orientation changes

### Interstitial Ads
- **Triggers**:
  - Between levels (every 2-3 levels)
  - Game over scenarios
  - 30-second cooldown between ads
- **Type**: Video or display interstitials
- **Behavior**:
  - Pre-loaded for instant display
  - Automatic retry on load failure
  - Non-intrusive timing

## 🎮 Step 5: Ad Display Logic

### Banner Ad Placement
```dart
// Wraps game content with bottom banner
BottomBannerAdWidget(
  child: Column(
    children: [
      // Game UI content
      Expanded(child: gameContent),
    ],
  ),
)
```

### Interstitial Ad Triggers
```dart
// Level completion
await AdService.instance.showLevelCompleteAd(currentLevel);

// Game over
AdService.instance.showGameOverAd();
```

## 🔒 Step 6: Premium User Integration

The ad system respects premium subscriptions:

```dart
bool shouldShowAds() {
  // Integrate with your subscription service
  return !SubscriptionService().isPremium;
}
```

## 📊 Step 7: Testing

### Test with AdMob Test IDs
The app is configured with test IDs that show test ads. These are safe to use during development.

### Test Ad Scenarios
1. **Banner ads loading**: Open any game screen
2. **Interstitial ads**: Complete levels 2, 3, 4, 6, etc.
3. **Game over ads**: Lose a game
4. **Ad failures**: Test with airplane mode
5. **Premium users**: Test ad hiding with subscription

### Debugging
Enable debug logs to monitor ad behavior:
```bash
flutter run --verbose
```
Look for `AdService:` logs in the console.

## 🚀 Step 8: Production Deployment

### Before Publishing
1. ✅ Replace all test Ad Unit IDs with production IDs
2. ✅ Replace test App IDs with production App IDs
3. ✅ Test on real devices
4. ✅ Verify ads load correctly
5. ✅ Test premium subscription ad hiding
6. ✅ Ensure proper ad placement and timing

### App Store Guidelines
- Ensure ads don't interfere with gameplay
- Ads should be clearly distinguishable from game content
- Follow platform-specific advertising policies
- Consider COPPA compliance if targeting children

## 🎯 Step 9: Optimization Tips

### Ad Performance
1. **Preload ads**: The service preloads ads for instant display
2. **Retry logic**: Failed ads are automatically retried
3. **Cooldown periods**: Prevents ad spam
4. **Contextual timing**: Ads shown at natural break points

### User Experience
1. **Non-intrusive placement**: Banner ads at bottom don't block gameplay
2. **Appropriate frequency**: Interstitials every 2-3 levels
3. **Smooth integration**: Ads feel part of the app experience
4. **Premium option**: Users can remove ads via subscription

### Revenue Optimization
1. **Multiple ad networks**: Consider adding mediation later
2. **A/B testing**: Test different ad frequencies
3. **Ad formats**: Experiment with rewarded videos
4. **Placement optimization**: Monitor performance metrics

## 🔧 Troubleshooting

### Common Issues

#### Ads Not Loading
- Check internet connection
- Verify Ad Unit IDs are correct
- Ensure AdMob account is approved
- Check for policy violations

#### Test Ads Not Showing
- Verify test device is registered in AdMob
- Check that test IDs are being used
- Clear app data and restart

#### Production Ads Not Loading
- Ensure production Ad Unit IDs are configured
- Check that app is published and approved
- Monitor AdMob reports for errors

### Debug Commands
```bash
# Check ad SDK version
flutter packages deps

# Verbose logging
flutter run --verbose

# Check for conflicts
flutter doctor
```

## 📈 Monitoring & Analytics

### AdMob Reports
Monitor these metrics in your AdMob dashboard:
- **Impressions**: Number of ads shown
- **CTR**: Click-through rate
- **eCPM**: Effective cost per thousand impressions
- **Revenue**: Total earnings

### App Analytics
Track ad-related events in your analytics:
- Ad impression events
- Ad click events
- Premium upgrade correlation
- User retention with/without ads

## 🎉 Final Notes

Your matching game now has a comprehensive ad system that:
- ✅ Shows banner ads on all game screens
- ✅ Displays interstitial videos between levels
- ✅ Respects premium subscriptions
- ✅ Handles errors gracefully
- ✅ Provides smooth user experience
- ✅ Includes proper testing setup
- ✅ Ready for production deployment

The ad integration is designed to monetize your game while maintaining an excellent user experience. Remember to always test thoroughly before publishing and monitor performance metrics to optimize revenue.

Good luck with your game monetization! 🚀 