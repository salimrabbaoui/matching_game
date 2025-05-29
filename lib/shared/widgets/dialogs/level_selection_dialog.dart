import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/game_logic_service.dart';
import 'base_dialog.dart';

class LevelSelectionDialog extends StatelessWidget {
  final int highestLevel;
  final Function(int level) onLevelSelected;
  final bool isTimeMode;
  final String? title;
  final Color? primaryColor;

  const LevelSelectionDialog({
    super.key,
    required this.highestLevel,
    required this.onLevelSelected,
    this.isTimeMode = false,
    this.title,
    this.primaryColor,
  });

  static void show({
    required BuildContext context,
    required int highestLevel,
    required Function(int level) onLevelSelected,
    bool isTimeMode = false,
    String? title,
    Color? primaryColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => LevelSelectionDialog(
        highestLevel: highestLevel,
        onLevelSelected: onLevelSelected,
        isTimeMode: isTimeMode,
        title: title,
        primaryColor: primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameLogic = GameLogicService();
    final color = primaryColor ??
        (isTimeMode ? AppConstants.timeButtonColor : AppConstants.primaryColor);
    final dialogTitle =
        title ?? (isTimeMode ? 'Time Challenge' : 'Select Level');

    return BaseDialog(
      icon: isTimeMode
          ? Icon(Icons.timer, color: color, size: 40)
          : Icon(Icons.sports_esports, color: color, size: 40),
      title: dialogTitle,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppConstants.cloudColor,
          AppConstants.gradientEnd.withOpacity(0.1),
        ],
      ),
      content: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              highestLevel,
              (index) {
                final level = index + 1;
                final levelColor = gameLogic.getLevelColor(level);
                final difficultyIcon = gameLogic.getLevelDifficultyIcon(level);
                final difficultyLabel = gameLogic.getDifficultyLabel(level);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: _buildLevelButton(
                    context,
                    level: level,
                    color: levelColor,
                    difficultyIcon: difficultyIcon,
                    difficultyLabel: difficultyLabel,
                    isTimeMode: isTimeMode,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      actions: [
        DialogButton(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
          backgroundColor: Colors.grey.shade300,
          textColor: AppConstants.primaryColor,
        ),
      ],
    );
  }

  Widget _buildLevelButton(
    BuildContext context, {
    required int level,
    required Color color,
    required Widget difficultyIcon,
    required String difficultyLabel,
    required bool isTimeMode,
  }) {
    final gameLogic = GameLogicService();
    final pairsCount = gameLogic.calculatePairsForLevel(level);
    final maxMoves = gameLogic.calculateMaxMovesForLevel(level);
    final timeLimit = gameLogic.calculateTimeForLevel(level);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          onLevelSelected(level);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.padding,
            vertical: AppConstants.padding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: 0, // Remove default elevation since we have custom shadow
        ),
        child: Row(
          children: [
            Icon(
              isTimeMode ? Icons.timer : Icons.play_circle_filled,
              size: 28,
            ),
            const SizedBox(width: AppConstants.spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level $level',
                    style: const TextStyle(
                      fontSize: AppConstants.titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isTimeMode
                        ? '$pairsCount pairs • ${timeLimit}s • $difficultyLabel'
                        : '$pairsCount pairs • $maxMoves moves • $difficultyLabel',
                    style: const TextStyle(
                      fontSize: AppConstants.captionFontSize,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            difficultyIcon,
          ],
        ),
      ),
    );
  }
}
