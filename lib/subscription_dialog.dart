import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionDialog {
  static void show(
    BuildContext context, {
    required Function(String) onPurchase,
    VoidCallback? onCancel,
    Map<String, Map<String, dynamic>>? subscriptionPlans,
    List<Map<String, dynamic>>? premiumFeatures,
  }) {
    // Default subscription plans
    final defaultPlans = {
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

    // Default premium features
    final defaultFeatures = [
      {'icon': Icons.favorite, 'text': 'Unlimited Hearts'},
      {'icon': Icons.block, 'text': 'No Ads'},
      {'icon': Icons.auto_awesome, 'text': 'Exclusive Sock Designs'},
      {'icon': Icons.bolt, 'text': 'Daily Bonuses'},
    ];

    final plans = subscriptionPlans ?? defaultPlans;
    final features = premiumFeatures ?? defaultFeatures;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.amber.shade50,
                Colors.amber.shade100,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Premium icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 80,
                  ),
                  Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 30,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Title
              const Text(
                'Premium Subscription',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Content
              Column(
                children: [
                  const Text(
                    'Subscribe to get:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ...features.map((feature) => _buildFeatureRow(
                        feature['icon'] as IconData,
                        feature['text'] as String,
                      )),
                ],
              ),
              const SizedBox(height: 24),
              // Subscription options
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...plans.entries.map((entry) {
                    final planData = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildSubscriptionOption(
                        planData['title'] as String,
                        planData['price'] as String,
                        planData['isPopular'] as bool,
                        () {
                          Navigator.of(context).pop();
                          onPurchase(entry.key);
                        },
                        discount: planData['discount'] as String?,
                      ),
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 16),
              // Cancel button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onCancel != null) {
                    onCancel();
                  }
                },
                child: const Text(
                  'Maybe Later',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSubscriptionOption(
      String title, String price, bool isPopular, VoidCallback onTap,
      {String? discount}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isPopular ? Colors.amber.shade300 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isPopular ? Colors.black : Colors.black87,
                  ),
                ),
                if (discount != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      discount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPopular ? Colors.black : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
