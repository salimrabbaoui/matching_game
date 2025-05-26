import 'package:flutter/material.dart';
import 'game_page.dart';
import 'time_game_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sock Matching Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MenuPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int highestLevel = 1;
  int highestTimeLevel = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHighestLevel();
  }

  Future<void> _loadHighestLevel() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highestLevel = prefs.getInt('highestLevel') ?? 1;
      highestTimeLevel = prefs.getInt('highestTimeLevel') ?? 1;
      isLoading = false;
    });
  }

  void _showLevelSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.shade50,
                Colors.purple.shade100,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Level',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      highestLevel,
                      (index) {
                        final level = index + 1;
                        final color = _getLevelColor(level);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _startGame(context, level);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 3,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.play_circle_filled, size: 28),
                                const SizedBox(width: 12),
                                Text(
                                  'Level $level',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                _getLevelDifficultyIcon(level),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimeLevelSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade50,
                Colors.orange.shade100,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer, color: Colors.orange, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'Time Challenge',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      highestTimeLevel,
                      (index) {
                        final level = index + 1;
                        final pairs = _calculateTimePairsForLevel(level);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _startTimeGame(context, level);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 3,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timer, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Level $level',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '$pairs pairs • 10s + 5s/match',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _getTimeDifficultyIcon(level),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getLevelDifficultyIcon(int level) {
    if (level <= 2) {
      return const Icon(Icons.sentiment_satisfied_alt);
    } else if (level <= 5) {
      return const Icon(Icons.sentiment_neutral);
    } else if (level <= 9) {
      return const Icon(Icons.sentiment_dissatisfied);
    } else {
      return const Icon(Icons.psychology);
    }
  }

  Color _getLevelColor(int level) {
    if (level <= 6) return Colors.green;
    if (level <= 12) return Colors.blue;
    if (level <= 20) return Colors.orange;
    return Colors.red;
  }

  int _calculateTimePairsForLevel(int level) {
    // Same logic as in time_game_page.dart
    int pairs = 2;
    for (int i = 1; i < level; i++) {
      pairs *= 2;
    }
    return pairs > 16 ? 16 : pairs;
  }

  Widget _getTimeDifficultyIcon(int level) {
    if (level == 1) {
      return const Icon(Icons.sentiment_satisfied_alt, color: Colors.white);
    } else if (level == 2) {
      return const Icon(Icons.sentiment_neutral, color: Colors.white);
    } else if (level == 3) {
      return const Icon(Icons.sentiment_dissatisfied, color: Colors.white);
    } else {
      return const Icon(Icons.psychology, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade100,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title with shadow
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: const Text(
                        'Sock Matching Game',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Sock images in a row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSockImage('assets/images/socks/red_sock.png'),
                        _buildSockImage('assets/images/socks/blue_sock.png'),
                        _buildSockImage('assets/images/socks/green_sock.png'),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Continue Button (if there's a saved game)
                    /*   if (highestLevel > 1 && !isLoading)
                      _buildButton(
                        context,
                        text: 'Continue Level ${highestLevel}',
                        icon: Icons.play_arrow,
                        color: Colors.deepPurple,
                        onPressed: () => _startGame(context, highestLevel),
                      ),

                    const SizedBox(height: 15),

                    // New Game Button
                     _buildButton(
                      context,
                      text: 'New Game',
                      icon: Icons.fiber_new,
                      color: Colors.green,
                      onPressed: () => _startGame(context, 1),
                    ),*/

                    const SizedBox(height: 15),

                    // Time Mode Button
                    _buildButton(
                      context,
                      text: highestTimeLevel > 1
                          ? 'Time Challenge'
                          : 'New Time Challenge',
                      icon: Icons.timer,
                      color: Colors.orange,
                      onPressed: highestTimeLevel > 1
                          ? _showTimeLevelSelectionDialog
                          : () => _startTimeGame(context, 1),
                    ),

                    const SizedBox(height: 15),

                    // Select Level Button (only if they've reached higher levels)
                    if (highestLevel > 1 && !isLoading)
                      _buildButton(
                        context,
                        text: 'Moves Challenge',
                        icon: Icons.list,
                        color: Colors.blue,
                        onPressed: _showLevelSelectionDialog,
                      ),

                    const SizedBox(height: 30),

                    // How to Play Button
                    _buildButton(
                      context,
                      text: 'How to Play',
                      icon: Icons.help_outline,
                      color: Colors.purple,
                      onPressed: () => _showHowToPlayDialog(context),
                    ),

                    const SizedBox(height: 15),

                    // About Button
                    _buildButton(
                      context,
                      text: 'About',
                      icon: Icons.info_outline,
                      color: Colors.indigo,
                      onPressed: () => _showAboutDialog(context),
                    ),

                    const SizedBox(height: 30),

                    // Little animation hint
                    const Text(
                      'Match all the sock pairs!',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext context, int level) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MatchingGamePage(level: level),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _startTimeGame(BuildContext context, int level) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TimeGamePage(level: level),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Widget _buildSockImage(String imagePath) {
    return Transform.rotate(
      angle: 0.2, // slight tilt
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Text(
              '🧦',
              style: TextStyle(fontSize: 40),
              textAlign: TextAlign.center,
            );
          },
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHowToPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 10),
            Text('How to Play'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _InstructionItem(
                icon: Icons.touch_app,
                text: 'Flip cards to find matching sock pairs',
              ),
              SizedBox(height: 10),
              _InstructionItem(
                icon: Icons.psychology,
                text: 'Remember the location of each sock',
              ),
              SizedBox(height: 10),
              _InstructionItem(
                icon: Icons.fitness_center,
                text: 'Match all pairs with the fewest moves',
              ),
              SizedBox(height: 10),
              _InstructionItem(
                icon: Icons.sentiment_very_satisfied,
                text: 'Have fun and show off your memory skills!',
              ),
              SizedBox(height: 10),
              _InstructionItem(
                icon: Icons.bar_chart,
                text:
                    'Choose different difficulty levels to challenge yourself',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.purple),
            SizedBox(width: 10),
            Text('About'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sock Matching Game',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'A fun memory game where you match pairs of socks. Great for all ages!',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Version 1.0.0',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InstructionItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
