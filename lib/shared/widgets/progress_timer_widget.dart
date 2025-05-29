import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class ProgressTimerWidget extends StatelessWidget {
  final int currentTime;
  final int maxTime;
  final bool showMaxTime;
  final Color progressColor;
  final Color backgroundColor;
  final Color textColor;

  const ProgressTimerWidget({
    super.key,
    required this.currentTime,
    required this.maxTime,
    this.showMaxTime = true,
    this.progressColor = AppConstants.primaryColor,
    this.backgroundColor = AppConstants.backgroundColor,
    this.textColor = AppConstants.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxTime > 0 ? currentTime / maxTime : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timer text
        Text(
          showMaxTime ? 'Time: $currentTime / $maxTime' : 'Time: $currentTime',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        // Progress bar - extends to full width with small margins
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          height: 8,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
