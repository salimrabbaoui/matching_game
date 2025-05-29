import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../shared/widgets/dialogs/level_selection_dialog.dart';
import '../../game_page.dart';
import '../../time_game_page.dart';
import '../../subscription_service.dart';

class MenuPage extends StatefulWidget {
  final bool showSubscriptionDialog;

  const MenuPage({super.key, this.showSubscriptionDialog = false});

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
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await StorageService().initialize();
    await SubscriptionService().initialize();
    await _loadLevels();

    // Show subscription dialog if requested
    if (widget.showSubscriptionDialog) {
      // Small delay to ensure the menu is fully loaded
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showSubscriptionDialog();
        }
      });
    }
  }

  Future<void> _loadLevels() async {
    final storage = StorageService();
    final level = await storage.getHighestLevel();
    final timeLevel = await storage.getHighestTimeLevel();

    setState(() {
      highestLevel = level;
      highestTimeLevel = timeLevel;
      isLoading = false;
    });
  }

  void _showClassicLevelSelection() {
    LevelSelectionDialog.show(
      context: context,
      highestLevel: highestLevel,
      onLevelSelected: (level) => _startClassicGame(level),
      isTimeMode: false,
      title: 'Select Level',
      primaryColor: AppConstants.classicButtonColor,
    );
  }

  void _showTimeLevelSelection() {
    LevelSelectionDialog.show(
      context: context,
      highestLevel: highestTimeLevel,
      onLevelSelected: (level) => _startTimeGame(level),
      isTimeMode: true,
      title: 'Time Challenge',
      primaryColor: AppConstants.timeButtonColor,
    );
  }

  void _startClassicGame(int level) {
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
    ).then((_) => _loadLevels());
  }

  void _startTimeGame(int level) {
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
    ).then((_) => _loadLevels());
  }

  void _showSubscriptionDialog() {
    SubscriptionService().showSubscriptionDialog(
      context,
      onSuccess: (subscriptionType) {
        // Additional success handling specific to menu
        print('Subscription purchased from menu: $subscriptionType');

        // Optionally reload levels or update UI state
        _loadLevels();
      },
      onError: (error) {
        // Handle subscription error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      },
      onCancel: () {
        // Handle user cancellation
        print('User cancelled subscription');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.gradientStart,
              AppConstants.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Cloud decorations to match screenshot
              _buildCloudDecorations(),

              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title with shadow - keeping your game title
                        Container(
                          decoration: BoxDecoration(
                            color: AppConstants.cloudColor.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 20),
                          child: const Text(
                            'Sock Matching Game',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
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
                            _buildSockImage(
                                'assets/images/socks/blue_sock.png'),
                            _buildSockImage(
                                'assets/images/socks/green_sock.png'),
                          ],
                        ),

                        const SizedBox(height: 40),

                        const SizedBox(height: 15),

                        // Time Mode Button
                        _buildButton(
                          context,
                          text: highestTimeLevel > 1
                              ? 'Time Challenge'
                              : 'New Time Challenge',
                          icon: Icons.timer,
                          color: AppConstants.timeButtonColor,
                          onPressed: highestTimeLevel > 1
                              ? _showTimeLevelSelection
                              : () => _startTimeGame(1),
                        ),

                        const SizedBox(height: 15),

                        // Select Level Button
                        _buildButton(
                          context,
                          text: 'Moves Challenge',
                          icon: Icons.list,
                          color: AppConstants.classicButtonColor,
                          onPressed: _showClassicLevelSelection,
                        ),

                        const SizedBox(height: 15),

                        // Subscription Button
                        _buildButton(
                          context,
                          text: 'Remove Ads',
                          icon: Icons.remove_red_eye,
                          color: AppConstants.subscriptionButtonColor,
                          onPressed: _showSubscriptionDialog,
                        ),

                        const SizedBox(height: 30),

                        // How to Play Button
                        _buildButton(
                          context,
                          text: 'How to Play',
                          icon: Icons.help_outline,
                          color: AppConstants.helpButtonColor,
                          onPressed: () => _showHowToPlayDialog(context),
                        ),

                        const SizedBox(height: 30),

                        // Game description with new colors
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppConstants.cloudColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'Match all the sock pairs!',
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloudDecorations() {
    return Stack(
      children: [
        // Top clouds
        Positioned(
          top: -20,
          left: -50,
          child: _buildCloudShape(120, 60),
        ),
        Positioned(
          top: 30,
          right: -30,
          child: _buildCloudShape(100, 50),
        ),
        Positioned(
          top: 150,
          left: -40,
          child: _buildCloudShape(80, 40),
        ),

        // Bottom clouds
        Positioned(
          bottom: 100,
          right: -60,
          child: _buildCloudShape(140, 70),
        ),
        Positioned(
          bottom: -10,
          left: -20,
          child: _buildCloudShape(120, 60),
        ),
        Positioned(
          bottom: 200,
          left: 50,
          child: _buildCloudShape(90, 45),
        ),
      ],
    );
  }

  Widget _buildCloudShape(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppConstants.cloudColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(height / 2),
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
          color: AppConstants.cloudColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
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
        backgroundColor: AppConstants.cloudColor,
        title: Row(
          children: [
            Icon(Icons.help_outline, color: AppConstants.primaryColor),
            const SizedBox(width: 10),
            Text(
              'How to Play',
              style: TextStyle(color: AppConstants.primaryColor),
            ),
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
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.primaryColor,
            ),
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
        Icon(icon, color: AppConstants.primaryColor, size: 20),
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
}
