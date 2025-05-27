import 'package:flutter/material.dart';
import 'dart:async';
import '../../heart_manager.dart';

class GameAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String titlePrefix;
  final int level;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onReset;
  final Widget? difficultyBadge;
  final List<Widget>? additionalActions;

  const GameAppBar({
    super.key,
    required this.titlePrefix,
    required this.level,
    this.backgroundColor = Colors.purple,
    this.foregroundColor = Colors.white,
    this.onReset,
    this.difficultyBadge,
    this.additionalActions,
  });

  @override
  State<GameAppBar> createState() => _GameAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _GameAppBarState extends State<GameAppBar> {
  Timer? _heartUpdateTimer;

  @override
  void initState() {
    super.initState();
    _startHeartUpdateTimer();
  }

  void _startHeartUpdateTimer() {
    // Update the heart display every second to show the countdown
    _heartUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild to update the heart countdown display
        });
      }
    });
  }

  @override
  void dispose() {
    _heartUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.backgroundColor,
      foregroundColor: widget.foregroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          // Lose a heart when the user clicks the back arrow
          HeartManager().loseHeart();
          Navigator.of(context).pop();
        },
      ),
      title: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate text sizes based on screen width
          final deviceWidth = MediaQuery.of(context).size.width;
          final labelSize = deviceWidth * 0.035;
          final valueSize = deviceWidth * 0.04;

          return RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${widget.titlePrefix}: ',
                  style: TextStyle(
                    fontSize: labelSize,
                    fontWeight: FontWeight.normal,
                    color: widget.foregroundColor,
                  ),
                ),
                TextSpan(
                  text: '${widget.level}',
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.bold,
                    color: widget.foregroundColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        // Difficulty badge (if provided)
        if (widget.difficultyBadge != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: widget.difficultyBadge!,
          ),

        // Additional actions (if provided)
        if (widget.additionalActions != null) ...widget.additionalActions!,

        // Hearts display with timer
        SizedBox(
          height: kToolbarHeight,
          child: Center(
            child: HeartManager().hearts < HeartManager().maxHeartsCount &&
                    HeartManager().lastHeartLossTime != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(
                          HeartManager().hearts,
                          (index) => const Icon(Icons.favorite,
                              color: Colors.red, size: 16)),
                      ...List.generate(
                          HeartManager().maxHeartsCount - HeartManager().hearts,
                          (index) => Icon(Icons.favorite,
                              color: Colors.grey.shade300, size: 16)),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 2),
                            Text(
                              HeartManager().getNextHeartTime(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        HeartManager().maxHeartsCount,
                        (index) => const Icon(Icons.favorite,
                            color: Colors.red, size: 16)),
                  ),
          ),
        ),

        // Reset button (if callback provided)
        if (widget.onReset != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.onReset,
            tooltip: 'Reset Game',
          ),
      ],
    );
  }
}
