import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' show Random, max, min, sqrt;
import 'package:shared_preferences/shared_preferences.dart';
//import 'dart:io';
//import 'package:in_app_purchase/in_app_purchase.dart';
//import 'subscription_dialog.dart';
import 'subscription_service.dart';
import 'heart_manager.dart';
import 'core/services/ad_service.dart';
import 'core/services/game_logic_service.dart';
import 'core/services/color_group_service.dart';
import 'core/models/sock_card.dart';
import 'shared/widgets/game_app_bar.dart';
import 'shared/widgets/ad_banner_widget.dart';
import 'features/menu/menu_page.dart';

class MatchingGamePage extends StatefulWidget {
  final int level;

  const MatchingGamePage({super.key, this.level = 1});

  @override
  State<MatchingGamePage> createState() => _MatchingGamePageState();
}

class _MatchingGamePageState extends State<MatchingGamePage> {
  // Different sock images - using centralized model now
  final List<SockCard> cardSymbols = const [
    SockCard(imagePath: 'assets/images/socks/red_sock.png', name: 'Red Sock'),
    SockCard(imagePath: 'assets/images/socks/blue_sock.png', name: 'Blue Sock'),
    SockCard(
        imagePath: 'assets/images/socks/black_sock.png', name: 'Black Sock'),
    SockCard(imagePath: 'assets/images/socks/pink_sock.png', name: 'Pink Sock'),
    SockCard(
        imagePath: 'assets/images/socks/white_sock.png', name: 'White Sock'),
    SockCard(imagePath: 'assets/images/socks/grey_sock.png', name: 'Grey Sock'),
    SockCard(
        imagePath: 'assets/images/socks/brown_sock.png', name: 'Brown Sock'),
    SockCard(
        imagePath: 'assets/images/socks/purple_sock.png', name: 'Purple Sock'),
    SockCard(
        imagePath: 'assets/images/socks/off_white_sock.png',
        name: 'Off White Sock'),
    SockCard(
        imagePath: 'assets/images/socks/green_sock.png', name: 'Green Sock'),
    // Adding more sock varieties
    SockCard(
        imagePath: 'assets/images/socks/yellow_sock.png', name: 'Yellow Sock'),
    SockCard(
        imagePath: 'assets/images/socks/light_green_sock.png',
        name: 'Light Green Sock'),
    SockCard(
        imagePath: 'assets/images/socks/pastel_purple_sock.png',
        name: 'Pastel Purple Sock'),
    SockCard(
        imagePath: 'assets/images/socks/sky_bleu_sock.png',
        name: 'Sky Bleu Sock'),
    SockCard(
        imagePath: 'assets/images/socks/burgundi_sock.png',
        name: 'Burgundi Sock'),
    SockCard(
        imagePath: 'assets/images/socks/burnt_orange_sock.png',
        name: 'Burnt Orange Sock'),
    SockCard(
        imagePath: 'assets/images/socks/citrus_yellow_sock.png',
        name: 'Citrus Yellow Sock'),
  ];

  // Heart system variables - REMOVED (now using HeartManager)

  // Fallback emojis in case images aren't available
  final List<SockCard> fallbackSocks = const [
    SockCard(imagePath: '🧦', name: 'Red Sock'),
    SockCard(imagePath: '👟', name: 'Blue Sock'),
    SockCard(imagePath: '👞', name: 'Grey Sock'),
    SockCard(imagePath: '👠', name: 'Black Sock'),
    SockCard(imagePath: '👡', name: 'Pink Sock'),
    SockCard(imagePath: '🥿', name: 'Grey Sock'),
    // Adding more fallback varieties
    SockCard(imagePath: '👣', name: 'Off White Sock'),
    SockCard(imagePath: '🦶', name: 'Light Green Sock'),
    SockCard(imagePath: '🧤', name: 'Purple Sock'),
    SockCard(imagePath: '🧣', name: 'Burgundi Sock'),
    SockCard(imagePath: '⭐', name: 'Burnt Orange Sock'),
    SockCard(imagePath: '❤️', name: 'Citrus Yellow Sock'),
    SockCard(imagePath: '⚡', name: 'Pastel Purple Sock'),
    SockCard(imagePath: '🔷', name: 'Sky Bleu Sock'),
    SockCard(imagePath: '🔴', name: 'Red Sock'),
    SockCard(imagePath: '🔵', name: 'Blue Sock'),
    SockCard(imagePath: '🟢', name: 'Green Sock'),
    SockCard(imagePath: '🟡', name: 'Yellow Sock'),
    SockCard(imagePath: '🟣', name: 'Purple Sock'),
    SockCard(imagePath: '🟤', name: 'Brown Sock'),
  ];

  List<SockCard> cards = []; // Initialize to prevent LateInitializationError
  List<bool> cardFlips = [];
  List<int> matchedPairs = [];

  int? firstCardIndex;
  int? secondCardIndex;

  int moves = 0;
  int maxMoves = 6; // Default value to prevent LateInitializationError
  bool isProcessing = false;
  bool useImages = true;
  int pairsCount = 2; // Default value to prevent LateInitializationError
  int highestLevel = 1; // Default value to prevent LateInitializationError

  // Replace the current color constants with these
  final Color primaryColor = Color(0xFF5D9CEC); // Soft blue
  final Color secondaryColor = Color(0xFF48CFAD); // Mint
  final Color accentColor = Color(0xFFFFCE54); // Soft yellow
  final Color backgroundColor = Color(0xFFF5F7FA); // Light gray
  final Color successColor = Color(0xFFA0D468); // Light green
  final Color cardColor = Color(0xFF4FC1E9); // Sky blue

  // In-app purchase variables - REMOVED (now using SubscriptionService)

  @override
  void initState() {
    super.initState();
    // Initialize centralized services
    _initializeServices().then((_) {
      _loadHighestLevel().then((_) {
        _checkHasHeartsToPlay();
        initGame();
        _checkAndShowLevelSummary(widget.level);
      });
    });
  }

  Future<void> _initializeServices() async {
    await HeartManager().initialize();
    await SubscriptionService().initialize();
  }

  Future<void> _loadHighestLevel() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highestLevel = prefs.getInt('highestLevel') ?? 1;
    });
  }

  Future<void> _saveHighestLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    if (level > highestLevel) {
      await prefs.setInt('highestLevel', level);
      setState(() {
        highestLevel = level;
      });
    }
  }

  void initGame() {
    // Calculate pairs and max moves based on the current level
    // More difficult as level increases
    pairsCount = _calculatePairsForLevel(widget.level);
    maxMoves = _calculateMaxMovesForLevel(widget.level);

    // Make sure we don't exceed available card types
    pairsCount = pairsCount.clamp(2, cardSymbols.length);

    // Use the new game logic service for smart card selection
    final gameLogic = GameLogicService();
    final selectedCards =
        gameLogic.initializeCards(widget.level, useImages: useImages);

    // Extract unique sock cards (remove duplicates for pair creation)
    final uniqueSocks = <SockCard>[];
    final seenPaths = <String>{};

    for (final card in selectedCards) {
      if (!seenPaths.contains(card.imagePath)) {
        uniqueSocks.add(card);
        seenPaths.add(card.imagePath);
      }
      if (uniqueSocks.length >= pairsCount) break;
    }

    // Debug: Print color distribution for early levels
    if (widget.level <= 8) {
      final distribution =
          ColorGroupService.analyzeColorDistribution(uniqueSocks);
      final difficulty =
          ColorGroupService.calculateVisualDifficulty(uniqueSocks);
      print('Level ${widget.level} Color Distribution: $distribution');
      print(
          'Level ${widget.level} Visual Difficulty: ${difficulty.toStringAsFixed(2)}');
    }

    // Double the cards to create pairs
    cards = [...uniqueSocks, ...uniqueSocks];

    // Shuffle the cards
    cards.shuffle(Random());

    // Initialize all cards as face down
    cardFlips = List.generate(cards.length, (index) => false);

    // Clear matched pairs
    matchedPairs = [];

    // Reset game state
    firstCardIndex = null;
    secondCardIndex = null;
    moves = 0;
    isProcessing = false;
  }

  int _calculatePairsForLevel(int level) {
    // Define specific pairs for each level
    switch (level) {
      case 1:
        return 6;
      case 2:
        return 8;
      case 3:
        return 10;
      case 4:
        return 12;
      case 5:
        return 14;
      case 6:
        return 15;
      case 7:
        return 18;
      case 8:
        return 20;
      case 9:
        return 21;
      default:
        // For levels beyond 9, continue with a pattern
        if (level > 9) {
          return 21 +
              ((level - 9) * 2); // Increase by 2 pairs per level after 9
        }
        return 6; // Fallback to level 1
    }
  }

  int _calculateMaxMovesForLevel(int level) {
    final pairs = _calculatePairsForLevel(level);

    // Define specific max moves for each level to provide balanced difficulty
    // Generally allowing 2.5x to 3x the pairs for a reasonable challenge
    switch (level) {
      case 1:
        return 19; // 6 pairs × 3.16
      case 2:
        return 23; // 8 pairs × 2.87
      case 3:
        return 28; // 10 pairs × 2.8
      case 4:
        return 28; // 12 pairs × 2.33
      case 5:
        return 32; // 14 pairs × 2.28
      case 6:
        return 36; // 15 pairs × 2.4
      case 7:
        return 40; // 18 pairs × 2.22
      case 8:
        return 44; // 20 pairs × 2.2
      case 9:
        return 48; // 21 pairs × 2.28
      default:
        // For levels beyond 9, use a formula
        if (level > 9) {
          // Gradually reduce the multiplier as levels increase
          double multiplier = max(2.3, 3.0 - ((level - 9) * 0.1));
          return (pairs * multiplier).floor();
        }
        return pairs * 3; // Fallback
    }
  }

  void resetGame() {
    setState(() {
      initGame();
    });
  }

  void flipCard(int index) {
    if (isProcessing || cardFlips[index] || matchedPairs.contains(index)) {
      return;
    }

    setState(() {
      // If no card is flipped yet
      if (firstCardIndex == null) {
        firstCardIndex = index;
        cardFlips[index] = true;
      }
      // If one card is already flipped
      else if (secondCardIndex == null && firstCardIndex != index) {
        secondCardIndex = index;
        cardFlips[index] = true;
        isProcessing = true;
        moves++;

        // Check for a match
        checkForMatch();
      }
    });
  }

  void checkForMatch() {
    if (firstCardIndex == null || secondCardIndex == null) return;

    // If the cards match (same image path)
    if (cards[firstCardIndex!].imagePath == cards[secondCardIndex!].imagePath) {
      matchedPairs.add(firstCardIndex!);
      matchedPairs.add(secondCardIndex!);

      // Reset selected cards
      firstCardIndex = null;
      secondCardIndex = null;
      isProcessing = false;

      // Check if game is complete
      if (matchedPairs.length == cards.length) {
        // Game is won!
        _saveHighestLevel(widget.level + 1);
        Timer(const Duration(milliseconds: 500), () {
          showGameCompleteDialog();
        });
      }
    } else {
      // If cards don't match, flip them back after a delay
      Timer(const Duration(milliseconds: 1000), () {
        setState(() {
          cardFlips[firstCardIndex!] = false;
          cardFlips[secondCardIndex!] = false;
          firstCardIndex = null;
          secondCardIndex = null;
          isProcessing = false;
        });
      });
    }

    // Check if player has exceeded max moves OR insufficient moves remaining
    final remainingPairs = (cards.length - matchedPairs.length) / 2;
    final remainingMoves = maxMoves - moves;

    if ((moves >= maxMoves || remainingMoves < remainingPairs) &&
        matchedPairs.length < cards.length) {
      Timer(const Duration(milliseconds: 500), () {
        HeartManager().loseHeart();
        showGameOverDialog();
      });
    }
  }

  void showGameCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                primaryColor.withOpacity(0.1),
                primaryColor.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy icon
              Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 60,
              ),
              const SizedBox(height: 16),
              // Title
              const Text(
                'Sock Matching Champion!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Content
              Text(
                'You matched all the colorful socks in $moves moves!',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Buttons - now in a column instead of row
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      resetGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: successColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Play Again',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();

                      // Show interstitial ad before moving to next level
                      await AdService.instance
                          .showLevelCompleteAd(widget.level);

                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  MatchingGamePage(level: widget.level + 1),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                                opacity: animation, child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Next Level',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // Return to menu
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Back to Menu',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGameOverMessage() {
    final remainingPairs = (cards.length - matchedPairs.length) / 2;
    final remainingMoves = maxMoves - moves;

    if (moves >= maxMoves) {
      return 'You used all your moves!\nMoves: $moves\nHearts remaining: ${HeartManager().hearts}';
    } else if (remainingMoves < remainingPairs) {
      return 'Not enough moves to finish!\nRemaining pairs: ${remainingPairs.toInt()}\nRemaining moves: $remainingMoves\nHearts remaining: ${HeartManager().hearts}';
    } else {
      return 'Game over!\nMoves: $moves\nHearts remaining: ${HeartManager().hearts}';
    }
  }

  void showGameOverDialog() {
    // Show game over interstitial ad first
    AdService.instance.showGameOverAd();

    // Only show no hearts dialog if player actually has no hearts left
    if (HeartManager().hearts <= 0) {
      // Use the local _showNoHeartsDialog method for consistency
      _showNoHeartsDialog();
    } else {
      // Player still has hearts, show regular game over dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red.shade50, Colors.red.shade100],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sentiment_dissatisfied, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                const Text(
                  'Game Over!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _getGameOverMessage(),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        resetGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Back to Menu',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  // Removed duplicate _showNoHeartsDialog method - now using centralized SubscriptionService().showNoHeartsDialog()

  // Switch to emoji mode if images fail to load
  void useEmojiMode() {
    setState(() {
      useImages = false;

      // Take only the needed number of unique cards
      final selectedFallbacks = fallbackSocks.take(pairsCount).toList();

      cards = [...selectedFallbacks, ...selectedFallbacks];
      cards.shuffle(Random());
    });
  }

  Widget buildSockWidget(SockCard sock) {
    if (useImages) {
      return Image.asset(
        sock.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // If image fails to load, show text fallback
          return Center(
            child: Text(
              '🧦',
              style: TextStyle(fontSize: 40),
            ),
          );
        },
      );
    } else {
      return Center(
        child: Text(
          sock.imagePath, // For fallback, imagePath contains emoji
          style: TextStyle(fontSize: 40),
        ),
      );
    }
  }

  int getCrossAxisCount() {
    // Define specific column counts for each level based on your requirements
    switch (widget.level) {
      case 1:
        return 3; // 6 pairs (3 columns × 4 rows)
      case 2:
        return 4; // 8 pairs (4 columns × 4 rows)
      case 3:
        return 4; // 10 pairs (4 columns × 5 rows)
      case 4:
        return 4; // 12 pairs (4 columns × 6 rows)
      case 5:
        return 4; // 14 pairs (4 columns × 7 rows)
      case 6:
        return 5; // 15 pairs (5 columns × 6 rows)
      case 7:
        return 6; // 18 pairs (6 columns × 6 rows)
      case 8:
        return 5; // 20 pairs (5 columns × 8 rows)
      case 9:
        return 6; // 21 pairs (6 columns × 7 rows)
      default:
        // For levels beyond 9, use a reasonable grid
        final pairs = _calculatePairsForLevel(widget.level);
        if (pairs <= 24) return 6;
        if (pairs <= 36) return 6;
        return 8; // For very high levels
    }
  }

  void _showLevelSummary() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(
          'Level ${widget.level}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryItem(
              icon: Icons.grid_4x4,
              text: 'Find $pairsCount pairs of socks',
            ),
            const SizedBox(height: 10),
            _buildSummaryItem(
              icon: Icons.timer,
              text: 'Maximum $maxMoves moves allowed',
            ),
            const SizedBox(height: 10),
            _buildSummaryItem(
              icon: Icons.tips_and_updates,
              text: 'Remember the positions!',
              color: Colors.orange,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Let\'s Go!'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String text,
    Color color = Colors.blue,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;

    return Scaffold(
      appBar: GameAppBar(
        titlePrefix: 'Level',
        level: widget.level,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onReset: resetGame,
        difficultyBadge: _buildDifficultyBadge(),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.1),
              backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: OrientationBuilder(builder: (context, orientation) {
            if (orientation == Orientation.portrait) {
              return _buildPortraitLayout();
            } else {
              return _buildLandscapeLayout();
            }
          }),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return BottomBannerAdWidget(
      child: Column(
        children: [
          // Game info section with minimal padding
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Moves: $moves',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Remaining: ${maxMoves - moves}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: (maxMoves - moves) <= 3 ? Colors.red : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pairs: $pairsCount',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Highest Level: $highestLevel',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Card grid with flex to fill space
          Expanded(
            flex: 1, // Take all available space
            child: _buildCardGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return BottomBannerAdWidget(
      child: Row(
        children: [
          // Game info panel on the side
          Container(
            width: 150,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level: ${widget.level}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Moves: $moves',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Remaining: ${maxMoves - moves}',
                  style: TextStyle(
                    fontSize: 16,
                    color: (maxMoves - moves) <= 3 ? Colors.red : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pairs: $pairsCount',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Highest: $highestLevel',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Card grid takes remaining width
          Expanded(
            flex: 1,
            child: _buildCardGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      // If no cards are loaded yet, show a loading indicator
      if (cards.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // Get available dimensions
      final availableWidth = constraints.maxWidth;
      final availableHeight = constraints.maxHeight;
      final itemCount = cards.length;

      // Calculate the optimal grid configuration
      final gridConfig =
          _calculateOptimalGrid(availableWidth, availableHeight, itemCount);
      final crossAxisCount = gridConfig['columns'] as int;
      final rowCount = gridConfig['rows'] as int;
      final cardSize = gridConfig['cardSize'] as double;
      final spacing = gridConfig['spacing'] as double;

      // Calculate total grid dimensions
      final totalGridWidth =
          (crossAxisCount * cardSize) + ((crossAxisCount - 1) * spacing);
      final totalGridHeight =
          (rowCount * cardSize) + ((rowCount - 1) * spacing);

      // Calculate centering offsets
      final horizontalOffset = (availableWidth - totalGridWidth) / 2;
      final verticalOffset = (availableHeight - totalGridHeight) / 2;

      return Container(
        width: availableWidth,
        height: availableHeight,
        child: Stack(
          children: [
            Positioned(
              left: horizontalOffset.clamp(0.0, double.infinity),
              top: verticalOffset.clamp(0.0, double.infinity),
              child: SizedBox(
                width: totalGridWidth,
                height: totalGridHeight,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: 1.0, // Always square cards
                  ),
                  itemCount: cards.length,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // No scrolling since we're centering
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => flipCard(index),
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        color: matchedPairs.contains(index)
                            ? successColor.withOpacity(0.3)
                            : cardFlips[index]
                                ? Colors.white
                                : cardColor,
                        child: cardFlips[index] || matchedPairs.contains(index)
                            ? FittedBox(
                                fit: BoxFit.contain,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: buildSockWidget(cards[index]),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // Calculate the optimal grid configuration for square cards
  Map<String, dynamic> _calculateOptimalGrid(
      double availableWidth, double availableHeight, int cardCount) {
    // Handle edge case where cardCount is 0 or negative
    if (cardCount <= 0) {
      return {
        'columns': 2,
        'rows': 1,
        'cardSize': 100.0,
        'spacing': 4.0,
      };
    }

    // Use the predefined column count for this level
    int columns = getCrossAxisCount();
    int rows = (cardCount / columns).ceil();

    // Calculate spacing (2-6px based on available space)
    double spacing = (availableWidth > 400)
        ? 6.0
        : (availableWidth > 300)
            ? 4.0
            : 2.0;

    // Calculate card size that would fit with this configuration
    double cardWidthBasedOnColumns =
        (availableWidth - (spacing * (columns - 1))) / columns;
    double cardHeightBasedOnRows =
        (availableHeight - (spacing * (rows - 1))) / rows;

    // Use the smaller dimension to ensure square cards fit in both dimensions
    double cardSize = min(cardWidthBasedOnColumns, cardHeightBasedOnRows);

    // Make sure card size is reasonable (not too small)
    if (cardSize < 30) {
      // If cards would be too small, reduce spacing
      spacing = 2.0;
      cardWidthBasedOnColumns =
          (availableWidth - (spacing * (columns - 1))) / columns;
      cardHeightBasedOnRows = (availableHeight - (spacing * (rows - 1))) / rows;
      cardSize = min(cardWidthBasedOnColumns, cardHeightBasedOnRows);
    }

    // Ensure minimum card size
    cardSize = max(cardSize, 30.0);

    return {
      'columns': columns,
      'rows': rows,
      'cardSize':
          cardSize.floorToDouble(), // Use floor to ensure integer pixel values
      'spacing': spacing,
    };
  }

  Widget _buildDifficultyBadge() {
    String difficultyText;
    Color badgeColor;

    if (widget.level <= 3) {
      difficultyText = 'Easy';
      badgeColor = successColor;
    } else if (widget.level <= 6) {
      difficultyText = 'Medium';
      badgeColor = secondaryColor;
    } else if (widget.level <= 9) {
      difficultyText = 'Hard';
      badgeColor = accentColor;
    } else {
      difficultyText = 'Expert';
      badgeColor = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficultyText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _checkHasHeartsToPlay() {
    if (!HeartManager().hasHeartsToPlay()) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _showNoHeartsDialog();
      });
    }
  }

  void _showNoHeartsDialog() {
    SubscriptionService().showNoHeartsDialog(
      context,
      onBackToMenu: () {
        // Navigate back to menu
        if (mounted && context.mounted) {
          try {
            print('Navigating back to menu from game page');
            Navigator.of(context).pop(); // Return to menu
          } catch (e) {
            print('Navigation error: $e');
          }
        }
      },
      onHeartRecharge: () {
        // Test heart recharge functionality
        HeartManager().rechargeHearts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hearts fully recharged!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      },
      // Remove onShowSubscription to prevent redirect to menu
      // The subscription dialog will be shown directly instead
      showRechargeButton: true, // Show the test recharge button
    );
  }

  Future<void> _checkAndShowLevelSummary(int level) async {
    // Only show level summary if user has hearts to play
    if (!HeartManager().hasHeartsToPlay()) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final shownLevels = prefs.getStringList('shownLevelSummaries') ?? [];

    // If we haven't shown this level summary before
    if (!shownLevels.contains(level.toString())) {
      // Add this level to the list of shown summaries
      shownLevels.add(level.toString());
      await prefs.setStringList('shownLevelSummaries', shownLevels);

      // Show the level summary dialog
      Future.delayed(const Duration(milliseconds: 500), () {
        _showLevelSummary();
      });
    }
  }

  @override
  void dispose() {
    // Dispose centralized services
    HeartManager().dispose();
    SubscriptionService().dispose();
    super.dispose();
  }
}
