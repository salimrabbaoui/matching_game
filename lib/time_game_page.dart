import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' show Random, max, min, sqrt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'subscription_dialog.dart';
import 'subscription_service.dart';
import 'heart_manager.dart';
import 'core/constants/app_constants.dart';
import 'core/services/ad_service.dart';
import 'core/services/game_logic_service.dart';
import 'core/services/color_group_service.dart';
import 'core/models/sock_card.dart';
import 'shared/widgets/game_app_bar.dart';
import 'shared/widgets/ad_banner_widget.dart';
import 'shared/widgets/progress_timer_widget.dart';
import 'features/menu/menu_page.dart';

class TimeGamePage extends StatefulWidget {
  final int level;

  const TimeGamePage({super.key, this.level = 1});

  @override
  State<TimeGamePage> createState() => _TimeGamePageState();
}

class _TimeGamePageState extends State<TimeGamePage> {
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
    // Additional sock types to support higher levels (these will fallback to emojis if images don't exist)
    SockCard(imagePath: 'assets/images/socks/navy_sock.png', name: 'Navy Sock'),
    SockCard(
        imagePath: 'assets/images/socks/maroon_sock.png', name: 'Maroon Sock'),
    SockCard(imagePath: 'assets/images/socks/teal_sock.png', name: 'Teal Sock'),
    SockCard(
        imagePath: 'assets/images/socks/coral_sock.png', name: 'Coral Sock'),
    SockCard(
        imagePath: 'assets/images/socks/indigo_sock.png', name: 'Indigo Sock'),
    SockCard(imagePath: 'assets/images/socks/lime_sock.png', name: 'Lime Sock'),
    SockCard(
        imagePath: 'assets/images/socks/salmon_sock.png', name: 'Salmon Sock'),
    SockCard(
        imagePath: 'assets/images/socks/turquoise_sock.png',
        name: 'Turquoise Sock'),
  ];

  // Heart system variables - REMOVED (now using HeartManager)

  // Fallback emojis in case images aren't available
  final List<SockCard> fallbackSocks = const [
    SockCard(imagePath: '🧦', name: 'Red Sock'),
    SockCard(imagePath: '👟', name: 'Blue Sock'),
    SockCard(imagePath: '👞', name: 'Striped Sock'),
    SockCard(imagePath: '🥾', name: 'Polka Dot Sock'),
    SockCard(imagePath: '👢', name: 'Rainbow Sock'),
    SockCard(imagePath: '👠', name: 'Black Sock'),
    SockCard(imagePath: '👡', name: 'Pink Sock'),
    SockCard(imagePath: '🥿', name: 'Checkered Sock'),
    SockCard(imagePath: '👣', name: 'Yellow Sock'),
    SockCard(imagePath: '🦶', name: 'Green Sock'),
    SockCard(imagePath: '🧤', name: 'Purple Sock'),
    SockCard(imagePath: '🧣', name: 'Orange Sock'),
    SockCard(imagePath: '⭐', name: 'Star Sock'),
    SockCard(imagePath: '❤️', name: 'Heart Sock'),
    SockCard(imagePath: '⚡', name: 'Zigzag Sock'),
    SockCard(imagePath: '🔷', name: 'Argyle Sock'),
    SockCard(imagePath: '🔴', name: 'Red Circle Sock'),
    SockCard(imagePath: '🔵', name: 'Blue Circle Sock'),
    SockCard(imagePath: '🟢', name: 'Green Circle Sock'),
    SockCard(imagePath: '🟡', name: 'Yellow Circle Sock'),
    SockCard(imagePath: '🟣', name: 'Purple Circle Sock'),
    SockCard(imagePath: '🟤', name: 'Brown Circle Sock'),
    SockCard(imagePath: '🟠', name: 'Orange Circle Sock'),
    SockCard(imagePath: '⚫', name: 'Black Circle Sock'),
    SockCard(imagePath: '⚪', name: 'White Circle Sock'),
  ];

  List<SockCard> cards = [];
  List<bool> cardFlips = [];
  List<int> matchedPairs = [];

  int? firstCardIndex;
  int? secondCardIndex;

  // Time-based game variables
  int moves = 0;
  late int gameTimeSeconds;
  int remainingSeconds = 0;
  Timer? gameTimer;
  Timer? previewTimer;
  Timer? bonusAnimationTimer;
  bool isProcessing = false;
  bool isPreviewMode = false;
  int previewCountdown = 10;
  bool showTimeBonus = false;
  bool useImages = true;
  int pairsCount = 2;
  int highestLevel = 1;
  bool isShowingLevelSummary = false;

  // Color scheme
  final Color primaryColor = AppConstants.primaryColor;
  final Color secondaryColor = AppConstants.secondaryColor;
  final Color accentColor = AppConstants.accentColor;
  final Color backgroundColor = AppConstants.backgroundColor;
  final Color successColor = AppConstants.successColor;
  final Color cardColor = AppConstants.cardColor;

  // In-app purchase variables - REMOVED (now using SubscriptionService)

  @override
  void initState() {
    super.initState();
    // Initialize centralized services
    _initializeServices().then((_) {
      _loadHighestLevel().then((_) {
        // Check if player has hearts before starting the game
        _checkHasHeartsToPlay();
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
      highestLevel = prefs.getInt('highestTimeLevel') ?? 1;
    });
  }

  Future<void> _saveHighestLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    if (level > highestLevel) {
      await prefs.setInt('highestTimeLevel', level);
      setState(() {
        highestLevel = level;
      });
    }
  }

  void initGame() {
    // Calculate pairs and game time based on the current level
    pairsCount = _calculatePairsForLevel(widget.level);
    gameTimeSeconds = _calculateTimeForLevel(widget.level);
    remainingSeconds = 0; // Start from 0 instead of gameTimeSeconds

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
      print('Time Level ${widget.level} Color Distribution: $distribution');
      print(
          'Time Level ${widget.level} Visual Difficulty: ${difficulty.toStringAsFixed(2)}');
    }

    // Double the cards to create pairs
    cards = [...uniqueSocks, ...uniqueSocks];

    // Shuffle the cards
    cards.shuffle(Random());

    // Initialize all cards as face UP for preview
    cardFlips = List.generate(cards.length, (index) => true);

    // Clear matched pairs
    matchedPairs = [];

    // Reset game state
    firstCardIndex = null;
    secondCardIndex = null;
    moves = 0;
    isProcessing = false;

    // Start preview mode
    isPreviewMode = true;
    previewCountdown = 10;

    // Cancel any existing timers
    gameTimer?.cancel();
    previewTimer?.cancel();
  }

  void startGameTimers() {
    // Start 5-second preview timer with countdown
    previewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        previewCountdown--;
      });

      if (previewCountdown <= 0) {
        timer.cancel();
        setState(() {
          // Flip all cards face down
          cardFlips = List.generate(cards.length, (index) => false);
          isPreviewMode = false;
        });
        // Start the actual game timer
        _startGameTimer();
      }
    });
  }

  int _calculatePairsForLevel(int level) {
    // Custom progression for time mode with specific grid layouts
    switch (level) {
      case 1:
        return 6; // 6 pairs (4 columns * 3 rows = 12 cards)
      case 2:
        return 8; // 8 pairs (4 columns * 4 rows = 16 cards)
      case 3:
        return 10; // 10 pairs (5 columns * 4 rows = 20 cards)
      case 4:
        return 12; // 12 pairs (6 columns * 4 rows = 24 cards)
      case 5:
        return 14; // 14 pairs (7 columns * 4 rows = 28 cards)
      case 6:
        return 15; // 15 pairs (6 columns * 5 rows = 30 cards)
      case 7:
        return 18; // 18 pairs (6 columns * 6 rows = 36 cards)
      case 8:
        return 20; // 20 pairs (8 columns * 5 rows = 40 cards)
      case 9:
        return 21; // 21 pairs (7 columns * 6 rows = 42 cards)
      default:
        // For levels beyond 9, continue with a progressive pattern
        if (level <= 15) {
          return 21 + (level - 9); // Gradually increase by 1 pair per level
        } else {
          return min(25, 25); // Cap at 25 pairs for very high levels
        }
    }
  }

  int _calculateTimeForLevel(int level) {
    // Start with 30 seconds base time for all levels
    // Players get +5 seconds for each correct match
    return 30;
  }

  void _startGameTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds < gameTimeSeconds) {
        setState(() {
          remainingSeconds++; // Count up instead of down
        });
      } else {
        timer.cancel();
        if (matchedPairs.length < cards.length) {
          HeartManager().loseHeart();
          showGameOverDialog();
        }
      }
    });
  }

  void resetGame() {
    gameTimer?.cancel();
    previewTimer?.cancel();
    bonusAnimationTimer?.cancel();
    setState(() {
      showTimeBonus = false;
    });

    // Check hearts before restarting the game
    _checkHasHeartsToPlay();
  }

  void flipCard(int index) {
    if (isPreviewMode ||
        isProcessing ||
        cardFlips[index] ||
        matchedPairs.contains(index) ||
        remainingSeconds >= gameTimeSeconds) {
      return;
    }

    setState(() {
      if (firstCardIndex == null) {
        firstCardIndex = index;
        cardFlips[index] = true;
      } else if (secondCardIndex == null && firstCardIndex != index) {
        secondCardIndex = index;
        cardFlips[index] = true;
        isProcessing = true;
        moves++;
        checkForMatch();
      }
    });
  }

  void checkForMatch() {
    if (firstCardIndex == null || secondCardIndex == null) return;

    if (cards[firstCardIndex!].imagePath == cards[secondCardIndex!].imagePath) {
      matchedPairs.add(firstCardIndex!);
      matchedPairs.add(secondCardIndex!);

      // Add 5 seconds bonus for correct match (increase max time instead of reducing current time)
      setState(() {
        gameTimeSeconds += 5; // Increase the maximum time
        showTimeBonus = true;
      });

      // Hide the bonus indicator after 1 second
      bonusAnimationTimer?.cancel();
      bonusAnimationTimer = Timer(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            showTimeBonus = false;
          });
        }
      });

      firstCardIndex = null;
      secondCardIndex = null;
      isProcessing = false;

      if (matchedPairs.length == cards.length) {
        gameTimer?.cancel();
        _saveHighestLevel(widget.level + 1);
        Timer(const Duration(milliseconds: 500), () {
          showGameCompleteDialog();
        });
      }
    } else {
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
  }

  void showGameCompleteDialog() {
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
              Icon(Icons.emoji_events, color: Colors.amber, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Time Challenge Completed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'You matched all socks!\nTime taken: ${_formatTime(remainingSeconds)}\nMoves: $moves',
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
                      backgroundColor: successColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Play Again',
                        style: TextStyle(fontSize: 16)),
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
                                  TimeGamePage(level: widget.level + 1),
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
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Next Level',
                        style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Back to Menu',
                        style: TextStyle(fontSize: 16)),
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
    // Heart was already consumed when the game started, don't consume another one

    // Only show no hearts dialog if player actually has no hearts left
    if (HeartManager().hearts <= 0) {
      SubscriptionService().showNoHeartsDialog(
        context,
        onBackToMenu: () => Navigator.of(context).pop(),
        onHeartRecharge: () {
          HeartManager().rechargeHearts();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hearts fully recharged!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        },
        showRechargeButton: false,
      );
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
                Icon(Icons.timer_off, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                const Text(
                  'Time\'s Up!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'You ran out of time!\nMoves: $moves\nHearts remaining: ${HeartManager().hearts}',
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
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Try Again',
                          style: TextStyle(fontSize: 16)),
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
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Back to Menu',
                          style: TextStyle(fontSize: 16)),
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

  Widget buildSockWidget(SockCard sock) {
    if (useImages) {
      return Image.asset(
        sock.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text('🧦', style: TextStyle(fontSize: 40)),
          );
        },
      );
    } else {
      return Center(
        child: Text(sock.imagePath, style: TextStyle(fontSize: 40)),
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getTimeColor() {
    final timeLeft = gameTimeSeconds - remainingSeconds;
    if (timeLeft <= 10)
      return AppConstants.errorColor; // Soft coral red for urgency
    if (timeLeft <= 30)
      return AppConstants.primaryColor; // Warm yellow for caution
    return AppConstants.primaryColor; // Blue for normal time
  }

  void _showLevelSummary() {
    setState(() {
      isShowingLevelSummary = true;
    });

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cloudColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Time Challenge Level ${widget.level}',
          style: TextStyle(color: AppConstants.primaryColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryItem(
              icon: Icons.grid_4x4,
              text: 'Find $pairsCount pairs of socks',
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 10),
            _buildSummaryItem(
              icon: Icons.timer,
              text: 'Start with 30 seconds',
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 10),
            _buildSummaryItem(
              icon: Icons.add_circle,
              text: '+5 seconds for each correct match',
              color: AppConstants.successColor,
            ),
            const SizedBox(height: 10),
            _buildSummaryItem(
              icon: Icons.flash_on,
              text: 'Keep matching to stay alive!',
              color: AppConstants.accentColor,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                isShowingLevelSummary = false;
              });
              initGame();
              startGameTimers();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.primaryColor,
            ),
            child: const Text('Start Challenge!'),
          ),
        ],
      ),
    ).then((_) {
      // This handles when dialog is dismissed by tapping outside or back button
      setState(() {
        isShowingLevelSummary = false;
      });
      // Initialize game if dialog was dismissed without clicking the button
      if (cards.isEmpty) {
        initGame();
        startGameTimers();
      }
    });
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String text,
    Color color = AppConstants.primaryColor, // Changed default to blue
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: AppConstants.primaryColor.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameAppBar(
        titlePrefix: 'Time Level',
        level: widget.level,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onReset: resetGame,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor.withOpacity(0.1), backgroundColor],
          ),
        ),
        child: isShowingLevelSummary
            ? Container() // Hide content when level summary dialog is shown
            : cards.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  )
                : SafeArea(
                    child: OrientationBuilder(
                      builder: (context, orientation) {
                        if (orientation == Orientation.portrait) {
                          return _buildPortraitLayout();
                        } else {
                          return _buildLandscapeLayout();
                        }
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return BottomBannerAdWidget(
      child: Column(
        children: [
          // Timer widget spanning the full width
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 4.0),
            child: ProgressTimerWidget(
              currentTime: isPreviewMode ? previewCountdown : remainingSeconds,
              maxTime: isPreviewMode ? 10 : gameTimeSeconds,
              showMaxTime: !isPreviewMode,
              progressColor: isPreviewMode ? Colors.orange : _getTimeColor(),
              backgroundColor: Colors.grey.shade300,
              textColor: isPreviewMode ? Colors.orange : _getTimeColor(),
            ),
          ),
          // Moves and other info row
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Moves: $moves',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    if (showTimeBonus)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.successColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '+5s',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  'Highest Level: $highestLevel',
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.purple,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pairs: $pairsCount',
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(), // Empty space for balance
              ],
            ),
          ),

          Expanded(child: _buildCardGrid()),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return BottomBannerAdWidget(
      child: Row(
        children: [
          Container(
            width: 200,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Level: ${widget.level}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Progress timer widget
                ProgressTimerWidget(
                  currentTime:
                      isPreviewMode ? previewCountdown : remainingSeconds,
                  maxTime: isPreviewMode ? 10 : gameTimeSeconds,
                  showMaxTime: !isPreviewMode,
                  progressColor: isPreviewMode
                      ? AppConstants.primaryColor
                      : _getTimeColor(),
                  backgroundColor: AppConstants.backgroundColor,
                  textColor: isPreviewMode
                      ? AppConstants.primaryColor
                      : _getTimeColor(),
                ),

                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Moves: $moves', style: const TextStyle(fontSize: 16)),
                    if (showTimeBonus)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.successColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '+5s',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Pairs: $pairsCount',
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  'Highest: $highestLevel',
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.purple,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(child: _buildCardGrid()),
        ],
      ),
    );
  }

  Widget _buildCardGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final itemCount = cards.length;

        final gridConfig =
            _calculateOptimalGrid(availableWidth, availableHeight, itemCount);
        final crossAxisCount = gridConfig['columns'] as int;
        final rowCount = gridConfig['rows'] as int;
        final cardSize = gridConfig['cardSize'] as double;
        final spacing = gridConfig['spacing'] as double;

        final totalGridWidth =
            (crossAxisCount * cardSize) + ((crossAxisCount - 1) * spacing);
        final totalGridHeight =
            (rowCount * cardSize) + ((rowCount - 1) * spacing);

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
                      childAspectRatio: 1.0,
                    ),
                    itemCount: cards.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => flipCard(index),
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          color: matchedPairs.contains(index)
                              ? successColor.withOpacity(0.3)
                              : cardFlips[index]
                                  ? Colors.white
                                  : cardColor,
                          child:
                              cardFlips[index] || matchedPairs.contains(index)
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
      },
    );
  }

  Map<String, dynamic> _calculateOptimalGrid(
      double availableWidth, double availableHeight, int cardCount) {
    // Define preferred grid layouts based on card count
    Map<int, Map<String, int>> preferredLayouts = {
      12: {'columns': 3, 'rows': 4}, // Level 1: 6 pairs
      16: {'columns': 4, 'rows': 4}, // Level 2: 8 pairs
      20: {'columns': 4, 'rows': 5}, // Level 3: 10 pairs
      24: {'columns': 4, 'rows': 6}, // Level 4: 12 pairs
      28: {'columns': 4, 'rows': 7}, // Level 5: 14 pairs
      30: {'columns': 5, 'rows': 6}, // Level 6: 15 pairs
      36: {'columns': 6, 'rows': 6}, // Level 7: 18 pairs
      40: {'columns': 5, 'rows': 8}, // Level 8: 20 pairs
      42: {'columns': 6, 'rows': 7}, // Level 9: 21 pairs
    };

    // Use preferred layout if available
    if (preferredLayouts.containsKey(cardCount)) {
      final layout = preferredLayouts[cardCount]!;
      int columns = layout['columns']!;
      int rows = layout['rows']!;

      double spacing = (availableWidth > 400)
          ? 6.0
          : (availableWidth > 300)
              ? 4.0
              : 2.0;

      double cardWidthBasedOnColumns =
          (availableWidth - (spacing * (columns - 1))) / columns;
      double cardHeightBasedOnRows =
          (availableHeight - (spacing * (rows - 1))) / rows;

      double cardSize = min(cardWidthBasedOnColumns, cardHeightBasedOnRows);

      return {
        'columns': columns,
        'rows': rows,
        'cardSize': cardSize.floorToDouble(),
        'spacing': spacing,
      };
    }

    // Fallback to dynamic calculation for other card counts
    double bestCardSize = 0;
    int bestColumns = 2;
    int bestRows = 2;
    double bestSpacing = 4.0;
    double bestEfficiency = 0;

    for (int columns = 2; columns <= min(cardCount, 8); columns++) {
      int rows = (cardCount / columns).ceil();

      if ((columns * rows) - cardCount > columns) continue;

      double spacing = (availableWidth > 400)
          ? 6.0
          : (availableWidth > 300)
              ? 4.0
              : 2.0;

      double cardWidthBasedOnColumns =
          (availableWidth - (spacing * (columns - 1))) / columns;
      double cardHeightBasedOnRows =
          (availableHeight - (spacing * (rows - 1))) / rows;

      double cardSize = min(cardWidthBasedOnColumns, cardHeightBasedOnRows);

      if (cardSize < 40) continue;

      double totalCardArea = cardCount * (cardSize * cardSize);
      double totalScreenArea = availableWidth * availableHeight;
      double efficiency = totalCardArea / totalScreenArea;

      if (efficiency > bestEfficiency && cardSize >= bestCardSize * 0.9) {
        bestCardSize = cardSize;
        bestColumns = columns;
        bestRows = rows;
        bestSpacing = spacing;
        bestEfficiency = efficiency;
      }
    }

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
      'cardSize': bestCardSize.floorToDouble(),
      'spacing': bestSpacing,
    };
  }

  // Check if player has hearts to play, start game or show dialog
  void _checkHasHeartsToPlay() {
    if (HeartManager().hasHeartsToPlay()) {
      // Player has hearts, check for level summary first
      _checkAndShowLevelSummary(widget.level);
    } else {
      // No hearts available, show dialog
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !HeartManager().hasHeartsToPlay()) {
          _showNoHeartsDialog();
        }
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
            print('Navigating back to menu from time game');
            Navigator.of(context).pop(); // Return to menu
          } catch (e) {
            print('Navigation error: $e');
          }
        }
      },
    );
  }

  Future<void> _checkAndShowLevelSummary(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final shownLevels = prefs.getStringList('shownTimeLevelSummaries') ?? [];

    if (!shownLevels.contains(level.toString())) {
      shownLevels.add(level.toString());
      await prefs.setStringList('shownTimeLevelSummaries', shownLevels);

      Future.delayed(const Duration(milliseconds: 500), () {
        _showLevelSummary();
      });
    } else {
      // No level summary to show, initialize game and start timers immediately
      initGame();
      startGameTimers();
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    previewTimer?.cancel();
    bonusAnimationTimer?.cancel();
    super.dispose();
  }
}
