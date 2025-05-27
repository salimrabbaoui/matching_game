import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../heart_manager.dart';
import '../../../subscription_service.dart';
import 'base_dialog.dart';

class NoHeartsDialog extends StatefulWidget {
  final VoidCallback onBackToMenu;
  final VoidCallback? onHeartRecharge;
  final bool showRechargeButton;

  const NoHeartsDialog({
    super.key,
    required this.onBackToMenu,
    this.onHeartRecharge,
    this.showRechargeButton = false,
  });

  static void show({
    required BuildContext context,
    required VoidCallback onBackToMenu,
    VoidCallback? onHeartRecharge,
    bool showRechargeButton = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NoHeartsDialog(
        onBackToMenu: onBackToMenu,
        onHeartRecharge: onHeartRecharge,
        showRechargeButton: showRechargeButton,
      ),
    );
  }

  @override
  State<NoHeartsDialog> createState() => _NoHeartsDialogState();
}

class _NoHeartsDialogState extends State<NoHeartsDialog> {
  late String nextHeartTime;

  @override
  void initState() {
    super.initState();
    _updateHeartTime();
    // Update the timer every second
    Future.delayed(const Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer() {
    if (mounted) {
      _updateHeartTime();
      Future.delayed(const Duration(seconds: 1), _updateTimer);
    }
  }

  void _updateHeartTime() {
    if (mounted) {
      setState(() {
        nextHeartTime = HeartManager().getNextHeartTime();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      barrierDismissible: false,
      icon: const Icon(
        Icons.hourglass_empty,
        color: Colors.purple,
        size: 60,
      ),
      title: 'No Hearts Left',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.purple.shade50,
          Colors.purple.shade100,
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'You need to wait for hearts to regenerate.',
            style: TextStyle(
              fontSize: AppConstants.bodyFontSize,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (HeartManager().lastHeartLossTime != null) ...[
            const SizedBox(height: AppConstants.spacing),
            Container(
              padding: const EdgeInsets.all(AppConstants.padding),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Text(
                'Next heart in: $nextHeartTime',
                style: const TextStyle(
                  fontSize: AppConstants.bodyFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppConstants.largeSpacing),

          // Premium subscription button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                SubscriptionService().showSubscriptionDialog(
                  context,
                  onCancel: () {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (context.mounted) {
                        NoHeartsDialog.show(
                          context: context,
                          onBackToMenu: widget.onBackToMenu,
                          onHeartRecharge: widget.onHeartRecharge,
                          showRechargeButton: widget.showRechargeButton,
                        );
                      }
                    });
                  },
                  onSuccess: (type) {
                    print('Success callback triggered for $type');
                    // Snackbar is now handled by subscription service
                  },
                  onBackToMenu: () {
                    try {
                      print('Navigating back to menu from no hearts dialog');
                      widget.onBackToMenu();
                    } catch (e) {
                      print('Navigation error: $e');
                    }
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.padding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.orangeAccent),
                  SizedBox(width: AppConstants.spacing),
                  Text(
                    'Get Unlimited Hearts',
                    style: TextStyle(
                      fontSize: AppConstants.bodyFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (widget.showRechargeButton) ...[
            const SizedBox(height: AppConstants.spacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (widget.onHeartRecharge != null) {
                    widget.onHeartRecharge!();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.padding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.battery_charging_full),
                    SizedBox(width: AppConstants.spacing),
                    Text(
                      'Recharge Hearts (Test)',
                      style: TextStyle(
                        fontSize: AppConstants.bodyFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        DialogButton(
          text: 'Back to Menu',
          onPressed: () {
            Navigator.of(context).pop();
            widget.onBackToMenu();
          },
          isPrimary: true,
          icon: Icons.home,
        ),
      ],
    );
  }
}
