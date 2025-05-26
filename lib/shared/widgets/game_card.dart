import 'package:flutter/material.dart';
import '../../core/models/sock_card.dart';
import '../../core/constants/app_constants.dart';

class GameCard extends StatefulWidget {
  final SockCard sockCard;
  final bool isFlipped;
  final bool isMatched;
  final VoidCallback? onTap;
  final bool useImages;
  final double? size;
  final Duration animationDuration;

  const GameCard({
    super.key,
    required this.sockCard,
    this.isFlipped = false,
    this.isMatched = false,
    this.onTap,
    this.useImages = true,
    this.size,
    this.animationDuration = AppConstants.mediumAnimation,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    if (widget.isFlipped) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(GameCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardSize = widget.size ?? 80.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: cardSize,
              height: cardSize,
              margin: const EdgeInsets.all(4),
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final isShowingFront = _flipAnimation.value < 0.5;

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_flipAnimation.value * 3.14159),
                    child: isShowingFront
                        ? _buildCardBack(cardSize)
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(3.14159),
                            child: _buildCardFront(cardSize),
                          ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardBack(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.cardColor,
            AppConstants.cardColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.question_mark,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildCardFront(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: widget.isMatched ? AppConstants.successColor : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: widget.isMatched
              ? AppConstants.successColor
              : AppConstants.primaryColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isMatched
                ? AppConstants.successColor.withOpacity(0.3)
                : Colors.black.withOpacity(0.2),
            blurRadius: widget.isMatched ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius - 2),
        child: _buildCardContent(size),
      ),
    );
  }

  Widget _buildCardContent(double size) {
    if (widget.useImages && widget.sockCard.imagePath.startsWith('assets/')) {
      return Image.asset(
        widget.sockCard.imagePath,
        width: size * 0.7,
        height: size * 0.7,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildEmojiContent(size);
        },
      );
    } else {
      return _buildEmojiContent(size);
    }
  }

  Widget _buildEmojiContent(double size) {
    return Center(
      child: Text(
        widget.sockCard.imagePath.startsWith('assets/')
            ? '🧦' // Fallback emoji if image fails
            : widget.sockCard.imagePath,
        style: TextStyle(
          fontSize: size * 0.5,
        ),
      ),
    );
  }
}
