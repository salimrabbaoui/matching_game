import 'package:flutter/material.dart';
import '../../../core/services/color_group_service.dart';
import '../../../core/constants/app_constants.dart';

class ColorGroupsInfoDialog extends StatelessWidget {
  const ColorGroupsInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: AppConstants.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Smart Color Grouping',
                    style: TextStyle(
                      fontSize: AppConstants.headingFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.largeSpacing),

            // Explanation
            Container(
              padding: const EdgeInsets.all(AppConstants.padding),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 Making Early Levels Easier',
                    style: TextStyle(
                      fontSize: AppConstants.titleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We group socks by similar colors and ensure early levels show socks from different color groups, making them easier to distinguish!',
                    style: TextStyle(fontSize: AppConstants.bodyFontSize),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.largeSpacing),

            // Color Groups
            const Text(
              'Color Groups:',
              style: TextStyle(
                fontSize: AppConstants.titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: AppConstants.spacing),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildColorGroup('Warm Colors', 'warm', [
                      Colors.red,
                      Colors.pink,
                      Colors.orange,
                      Colors.deepOrange,
                    ]),
                    _buildColorGroup('Cool Colors', 'cool', [
                      Colors.blue,
                      Colors.lightBlue,
                      Colors.indigo,
                      Colors.teal,
                    ]),
                    _buildColorGroup('Green Colors', 'green', [
                      Colors.green,
                      Colors.lightGreen,
                      Colors.lime,
                    ]),
                    _buildColorGroup('Bright Colors', 'bright', [
                      Colors.yellow,
                      Colors.amber,
                    ]),
                    _buildColorGroup('Purple Colors', 'purple', [
                      Colors.purple,
                      Colors.deepPurple,
                    ]),
                    _buildColorGroup('Neutral Colors', 'neutral', [
                      Colors.black,
                      Colors.grey,
                      Colors.brown,
                      Colors.white,
                    ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.largeSpacing),

            // Level explanation
            Container(
              padding: const EdgeInsets.all(AppConstants.padding),
              decoration: BoxDecoration(
                color: AppConstants.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: AppConstants.successColor.withOpacity(0.3),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'How it Works by Level:',
                        style: TextStyle(
                          fontSize: AppConstants.bodyFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Levels 1-3: Maximum variety (each sock from different color group)\n'
                    '• Levels 4-8: Good variety (limited similar colors)\n'
                    '• Level 9+: Random selection (full challenge)',
                    style: TextStyle(fontSize: AppConstants.captionFontSize),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.largeSpacing),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(
                    fontSize: AppConstants.bodyFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorGroup(
      String groupName, String groupKey, List<Color> colors) {
    final sockCount = ColorGroupService.getSocksFromGroup(groupKey).length;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing),
      padding: const EdgeInsets.all(AppConstants.padding),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  style: const TextStyle(
                    fontSize: AppConstants.bodyFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$sockCount socks',
                  style: TextStyle(
                    fontSize: AppConstants.captionFontSize,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Color indicators
          Row(
            children: colors
                .map((color) => Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
