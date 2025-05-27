import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';
import 'subscription_dialog.dart';
import 'heart_manager.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  // In-app purchase variables
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;

  // Product IDs
  final Set<String> _productIds = {
    'monthly_subscription',
    'yearly_subscription'
  };

  // Subscription plans configuration
  static const Map<String, Map<String, dynamic>> subscriptionPlans = {
    'monthly': {
      'title': 'Monthly',
      'price': '\$2.99',
      'productId': 'monthly_subscription',
      'isPopular': false,
      'discount': null,
    },
    'yearly': {
      'title': 'Yearly',
      'price': '\$19.99',
      'productId': 'yearly_subscription',
      'isPopular': true,
      'discount': '45% OFF',
    },
  };

  // Premium features configuration
  static const List<Map<String, dynamic>> premiumFeatures = [
    {'icon': Icons.favorite, 'text': 'Unlimited Hearts'},
    {'icon': Icons.block, 'text': 'No Ads'},
    {'icon': Icons.auto_awesome, 'text': 'Exclusive Sock Designs'},
    {'icon': Icons.bolt, 'text': 'Daily Bonuses'},
  ];

  // Getters
  bool get isAvailable => _isAvailable;
  bool get isPurchasePending => _purchasePending;
  List<ProductDetails> get products => _products;

  // Initialize the service
  Future<void> initialize() async {
    await _initInAppPurchase();
  }

  // Show subscription dialog with centralized logic
  void showSubscriptionDialog(
    BuildContext context, {
    VoidCallback? onCancel,
    Function(String)? onSuccess,
    Function(String)? onError,
    VoidCallback? onBackToMenu,
  }) {
    SubscriptionDialog.show(
      context,
      subscriptionPlans: subscriptionPlans,
      premiumFeatures: premiumFeatures,
      onPurchase: (subscriptionType) => _processPurchase(
        context,
        subscriptionType,
        onSuccess: (type) {
          // Use the dialog context to show snackbar immediately before it closes
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('You now have unlimited hearts with $type plan!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            print('Snackbar shown successfully from subscription service');
          } catch (e) {
            print('Error showing snackbar from subscription service: $e');
          }

          // Call original success callback if provided
          if (onSuccess != null) {
            onSuccess(type);
          }

          // Handle navigation after snackbar
          if (onBackToMenu != null) {
            Future.delayed(const Duration(milliseconds: 2500), () {
              onBackToMenu();
            });
          }
        },
        onError: onError,
      ),
      onCancel: onCancel,
    );
  }

  // Show no hearts dialog with subscription option
  void showNoHeartsDialog(
    BuildContext context, {
    required VoidCallback onBackToMenu,
    VoidCallback? onHeartRecharge,
    VoidCallback? onShowSubscription,
    bool showRechargeButton = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple.shade50, Colors.purple.shade100],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_empty, color: Colors.purple, size: 60),
              const SizedBox(height: 16),
              const Text(
                'No Hearts Left',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  Text(
                    'You need to wait for hearts to regenerate.',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  if (HeartManager().lastHeartLossTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Next heart in: ${HeartManager().getNextHeartTime()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              // Premium subscription button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // If onShowSubscription callback is provided, use it (redirect to menu first)
                  // Otherwise, show subscription dialog directly (fallback)
                  if (onShowSubscription != null) {
                    onBackToMenu();
                    // Small delay to ensure menu is loaded before showing subscription
                    Future.delayed(const Duration(milliseconds: 300), () {
                      onShowSubscription();
                    });
                  } else {
                    // Fallback: show subscription dialog directly
                    showSubscriptionDialog(
                      context,
                      onCancel: () {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (context.mounted) {
                            showNoHeartsDialog(
                              context,
                              onBackToMenu: onBackToMenu,
                              onHeartRecharge: onHeartRecharge,
                              onShowSubscription: onShowSubscription,
                              showRechargeButton: showRechargeButton,
                            );
                          }
                        });
                      },
                      onSuccess: (type) {
                        try {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'You now have unlimited hearts with $type plan!',
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          print('Error showing snackbar: $e');
                        }
                      },
                      onBackToMenu: onBackToMenu,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black87,
                  minimumSize: Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.star, color: Colors.orangeAccent),
                    SizedBox(width: 8),
                    Text(
                      'Get Unlimited Hearts',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (showRechargeButton) ...[
                const SizedBox(height: 12),
                // TEST: Recharge Hearts button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onHeartRecharge != null) onHeartRecharge();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.bolt, color: Colors.yellow),
                      SizedBox(width: 8),
                      Text(
                        'Recharge Hearts (Test)',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // Back to menu button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onBackToMenu();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5D9CEC),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child:
                    const Text('Back to Menu', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Process subscription purchase
  Future<void> _processPurchase(
    BuildContext context,
    String subscriptionType, {
    Function(String)? onSuccess,
    Function(String)? onError,
  }) async {
    // Demo mode: If store is not available or products aren't loaded,
    // simulate a successful purchase for testing
    if (!_isAvailable || _products.isEmpty) {
      print('Demo mode: Simulating successful $subscriptionType purchase');
      _handleDemoModePurchase(subscriptionType, onSuccess);
      return;
    }

    final String productId = subscriptionPlans[subscriptionType]
            ?['productId'] ??
        (subscriptionType == 'monthly'
            ? 'monthly_subscription'
            : 'yearly_subscription');

    final products = _products.where((p) => p.id == productId).toList();
    if (products.isEmpty) {
      final error = 'Product not found';
      if (onError != null) {
        onError(error);
      } else {
        _showPurchaseErrorDialog(context, error);
      }
      return;
    }

    final product = products.first;
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
      applicationUserName: null,
    );

    try {
      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      // Store success callback for later use
      _currentSuccessCallback = onSuccess;
    } catch (e) {
      final error = 'Failed to start purchase: $e';
      if (onError != null) {
        onError(error);
      } else {
        _showPurchaseErrorDialog(context, error);
      }
    }
  }

  Function(String)? _currentSuccessCallback;

  // Initialize in-app purchases
  Future<void> _initInAppPurchase() async {
    print('Initializing in-app purchases...');

    final bool available = await _inAppPurchase.isAvailable();
    _isAvailable = available;

    if (!available) {
      print("Store not available - Demo mode enabled");
      return;
    }

    print('Store is available, loading products...');

    _subscription = _inAppPurchase.purchaseStream.listen(
      _listenToPurchaseUpdates,
      onDone: () => _subscription.cancel(),
      onError: (error) => print("Purchase stream error: $error"),
    );

    try {
      ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds);

      if (response.notFoundIDs.isNotEmpty) {
        print("⚠️  Products not found: ${response.notFoundIDs}");
        print("📝 To use real in-app purchases, you need to:");
        print("   1. Configure these product IDs in your app store console");
        print(
            "   2. For Google Play: Add them in Google Play Console > Monetization > Products");
        print(
            "   3. For App Store: Add them in App Store Connect > In-App Purchases");
        print("🎮 For now, demo mode is enabled - purchases will be simulated");
      }

      _products = response.productDetails;
      print("✅ Products loaded: ${_products.length}");
      if (_products.isNotEmpty) {
        _products.forEach((p) => print("   📦 Product: ${p.id} - ${p.title}"));
      } else {
        print("🎮 No products loaded - demo mode enabled");
      }
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  // Listen to purchase updates
  void _listenToPurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _purchasePending = true;
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _handleSuccessfulPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        print('Purchase error: ${purchaseDetails.error?.message}');
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  // Handle successful purchase
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    _purchasePending = false;

    // Grant unlimited hearts
    HeartManager().grantUnlimitedHearts();

    // Call success callback if provided
    if (_currentSuccessCallback != null) {
      String subscriptionType =
          purchaseDetails.productID.contains('monthly') ? 'monthly' : 'yearly';
      _currentSuccessCallback!(subscriptionType);
      _currentSuccessCallback = null;
    }
  }

  // Handle demo mode purchase (for testing when products aren't available)
  void _handleDemoModePurchase(
      String subscriptionType, Function(String)? onSuccess) {
    // Grant unlimited hearts
    HeartManager().grantUnlimitedHearts();

    // Call success callback if provided
    if (onSuccess != null) {
      onSuccess(subscriptionType);
    }

    print(
        '🎮 Demo mode: Granted unlimited hearts for $subscriptionType subscription');
  }

  // Show purchase error dialog
  void _showPurchaseErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Dispose resources
  void dispose() {
    _subscription.cancel();
  }
}
