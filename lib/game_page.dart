import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' show Random, max, min, sqrt;
import 'package:shared_preferences/shared_preferences.dart';
//import 'dart:io';
//import 'package:in_app_purchase/in_app_purchase.dart';
//import 'subscription_dialog.dart';
import 'subscription_service.dart';
import 'heart_manager.dart';
import 'shared/widgets/game_app_bar.dart';

class MatchingGamePage extends StatefulWidget {
  final int level;

  const MatchingGamePage({super.key, this.level = 1});

  @override
  State<MatchingGamePage> createState() => _MatchingGamePageState();
}

class SockCard {
  final String imagePath;
  final String name;

  const SockCard(this.imagePath, this.name);
}

class _MatchingGamePageState extends State<MatchingGamePage> {
  // Different sock images
  final List<SockCard> cardSymbols = const [
    SockCard('assets/images/socks/red_sock.png', 'Red Sock'),
    SockCard('assets/images/socks/blue_sock.png', 'Blue Sock'),
    SockCard('assets/images/socks/black_sock.png', 'Black Sock'),
    SockCard('assets/images/socks/pink_sock.png', 'Pink Sock'),
    SockCard('assets/images/socks/white_sock.png', 'White Sock'),
    SockCard('assets/images/socks/grey_sock.png', 'Grey Sock'),
    SockCard('assets/images/socks/brown_sock.png', 'Brown Sock'),
    SockCard('assets/images/socks/purple_sock.png', 'Purple Sock'),
    SockCard('assets/images/socks/off_white_sock.png', 'Off White Sock'),
    SockCard('assets/images/socks/green_sock.png', 'Green Sock'),
    // Adding more sock varieties
    SockCard('assets/images/socks/yellow_sock.png', 'Yellow Sock'),
    SockCard('assets/images/socks/light_green_sock.png', 'Light Green Sock'),
    SockCard(
        'assets/images/socks/pastel_purple_sock.png', 'Pastel Purple Sock'),
    SockCard('assets/images/socks/sky_bleu_sock.png', 'Sky Bleu Sock'),
    SockCard('assets/images/socks/burgundi_sock.png', 'Burgundi Sock'),
    SockCard('assets/images/socks/burnt_orange_sock.png', 'Burnt Orange Sock'),
    SockCard(
        'assets/images/socks/citrus_yellow_sock.png', 'Citrus Yellow Sock'),
  ];

  // Heart system variables - REMOVED (now using HeartManager)

  // Fallback emojis in case images aren't available
  final List<SockCard> fallbackSocks = const [
    SockCard('🧦', 'Red Sock'),
    SockCard('👟', 'Blue Sock'),
    SockCard('👞', 'Grey Sock'),
    SockCard('👠', 'Black Sock'),
    SockCard('👡', 'Pink Sock'),
    SockCard('🥿', 'Grey Sock'),
    // Adding more fallback varieties
    SockCard('👣', 'Off White Sock'),
    SockCard('🦶', 'Light Green Sock'),
    SockCard('🧤', 'Purple Sock'),
    SockCard('🧣', 'Burgundi Sock'),
    SockCard('⭐', 'Burnt Orange Sock'),
    SockCard('❤️', 'Citrus Yellow Sock'),
    SockCard('⚡', 'Pastel Purple Sock'),
    SockCard('🔷', 'Sky Bleu Sock'),
    SockCard('🔴', 'Red Sock'),
    SockCard('🔵', 'Blue Sock'),
    SockCard('🟢', 'Green Sock'),
    SockCard('🟡', 'Yellow Sock'),
    SockCard('🟣', 'Purple Sock'),
    SockCard('🟤', 'Brown Sock'),
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

    // For truly random sock selection
    List<SockCard> shuffledSymbols = List.from(cardSymbols)..shuffle(Random());
    final selectedSymbols = shuffledSymbols.take(pairsCount).toList();

    // Double the cards to create pairs
    cards = [...selectedSymbols, ...selectedSymbols];

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
    // Start with 2 pairs at level 1
    // Increase by 1 pair every 3 levels
    // Reaches 16 pairs by level 43
    int basePairs = 2;
    int additionalPairs = (level - 1) ~/ 3;
    return min(basePairs + additionalPairs, 16);
  }

  int _calculateMaxMovesForLevel(int level) {
    final pairs = _calculatePairsForLevel(level);

    // Base moves calculation starts with pairs * 3 (very generous)
    // Gradually reduce to pairs * 2 (perfect play)

    // Calculate how far we are through the 50 levels (0.0 to 1.0)
    double progressFactor = min((level - 1) / 49, 1.0);

    // Start with multiplier of 3.0, end with 2.0
    double multiplier = 3.0 - progressFactor;

    // Calculate base moves
    int baseMoves = (pairs * multiplier).floor();

    // Apply level-specific adjustment to ensure unique difficulty
    // Use modulo 3 to create a consistent pattern
    int levelMod = level % 3;

    // When pairs change (every 3rd level), keep standard calculation
    // For other levels, apply a specific adjustment
    int movesAdjustment = 0;
    if (levelMod == 1) {
      // First level of a new pair count - standard calculation
      movesAdjustment = 0;
    } else if (levelMod == 2) {
      // Second level with same pairs - reduce by 1
      movesAdjustment = -1;
    } else if (levelMod == 0) {
      // Third level with same pairs - reduce by 2
      movesAdjustment = -2;
    }

    // Ensure we don't go below the minimum perfect play amount
    return max(baseMoves + movesAdjustment, pairs * 2);
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

    // Check if player has exceeded max moves
    if (moves >= maxMoves && matchedPairs.length < cards.length) {
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
                    onPressed: () {
                      Navigator.of(context).pop();
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

  void showGameOverDialog() {
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
                  'You used all your moves!\nMoves: $moves\nHearts remaining: ${HeartManager().hearts}',
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
    final pairs = _calculatePairsForLevel(widget.level);
    final totalCards = pairs * 2;

    // Ensure we always have an even number for the cross axis
    if (pairs <= 4) return 2; // For 8 cards or less (2×4 grid)
    if (pairs <= 8) return 4; // For 16 cards or less (4×4 grid)
    if (pairs <= 12) return 4; // For 24 cards or less (4×6 grid)
    return 6; // For more cards (6×6 or similar grid)
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
    return Column(
      children: [
        // Game info section with minimal padding
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Moves: $moves',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

    double bestCardSize = 0;
    int bestColumns = 2;
    int bestRows = 2;
    double bestSpacing = 4.0;
    double bestEfficiency = 0;

    // Try different configurations
    for (int columns = 2; columns <= min(cardCount, 8); columns++) {
      int rows = (cardCount / columns).ceil();

      // Skip if this creates too many empty spaces
      if ((columns * rows) - cardCount > columns) continue;

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
      if (cardSize < 40) continue;

      // Calculate efficiency (how much of the screen is used by cards)
      double totalCardArea = cardCount * (cardSize * cardSize);
      double totalScreenArea = availableWidth * availableHeight;
      double efficiency = totalCardArea / totalScreenArea;

      // Prefer configurations with better efficiency and reasonable card sizes
      if (efficiency > bestEfficiency && cardSize >= bestCardSize * 0.9) {
        bestCardSize = cardSize;
        bestColumns = columns;
        bestRows = rows;
        bestSpacing = spacing;
        bestEfficiency = efficiency;
      }
    }

    // Ensure we have a valid configuration
    if (bestCardSize == 0) {
      bestColumns = 2;
      bestRows = (cardCount / 2).ceil();
      bestSpacing = 4.0;
      bestCardSize = min((availableWidth - bestSpacing) / 2,
          (availableHeight - (bestSpacing * (bestRows - 1))) / bestRows);
    }

    return {
      'columns': bestColumns,
      'rows': bestRows,
      'cardSize': bestCardSize
          .floorToDouble(), // Use floor to ensure integer pixel values
      'spacing': bestSpacing,
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
                  SubscriptionService().showSubscriptionDialog(
                    context,
                    onCancel: _showNoHeartsDialog,
                    onSuccess: (type) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'You now have unlimited hearts with $type plan!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  );
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
              const SizedBox(height: 12),
              // TEST: Recharge Hearts button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  HeartManager().rechargeHearts();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hearts fully recharged!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Back to menu button
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
                child:
                    const Text('Back to Menu', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
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
