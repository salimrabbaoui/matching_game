import 'package:flutter/material.dart';

class AppConstants {
  // Colors - Updated to match screenshot aesthetic
  static const Color primaryColor = Color(0xFF4A90E2); // Blue from screenshot
  static const Color secondaryColor = Color(0xFF7BB3F7); // Lighter blue
  static const Color accentColor = Color(0xFFFFC947); // Warm yellow accent
  static const Color backgroundColor =
      Color(0xFFF8FAFE); // Very light blue-white
  static const Color successColor = Color(0xFF6BCF7F); // Soft green
  static const Color cardColor = Color(0xFFFFFFFF); // Pure white for cards
  static const Color errorColor = Color(0xFFFF6B6B); // Soft coral red
  static const Color warningColor = Color(0xFFFFC947); // Same as accent

  // Gradient colors for backgrounds
  static const Color gradientStart = Color(0xFF4A90E2); // Main blue
  static const Color gradientEnd = Color(0xFF7BB3F7); // Lighter blue
  static const Color cloudColor = Color(0xFFFFFFFF); // White clouds

  // Button colors that harmonize
  static const Color timeButtonColor = Color(0xFF5BA0F2); // Blue variant
  static const Color classicButtonColor = Color(0xFF4A90E2); // Primary blue
  static const Color helpButtonColor = Color(0xFF7BB3F7); // Light blue
  static const Color subscriptionButtonColor =
      Color(0xFFFFC947); // Yellow accent

  // Heart System
  static const int maxHearts = 5;
  static const int heartRegenerationMinutes = 30;

  // Game Settings
  static const int basePairs = 2;
  static const int maxPairs = 16;
  static const int levelIncrementInterval = 3;
  static const double baseMultiplier = 3.0;
  static const double minMultiplier = 2.0;
  static const int totalLevels = 50;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Dimensions
  static const double borderRadius = 12.0;
  static const double largeBorderRadius = 20.0;
  static const double padding = 16.0;
  static const double largePadding = 24.0;
  static const double spacing = 8.0;
  static const double largeSpacing = 16.0;

  // Typography
  static const double headingFontSize = 24.0;
  static const double titleFontSize = 20.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;
  static const double smallFontSize = 12.0;

  // Game Specific
  static const List<String> sockImagePaths = [
    'assets/images/socks/red_sock.png',
    'assets/images/socks/blue_sock.png',
    'assets/images/socks/black_sock.png',
    'assets/images/socks/pink_sock.png',
    'assets/images/socks/white_sock.png',
    'assets/images/socks/grey_sock.png',
    'assets/images/socks/brown_sock.png',
    'assets/images/socks/purple_sock.png',
    'assets/images/socks/off_white_sock.png',
    'assets/images/socks/green_sock.png',
    'assets/images/socks/yellow_sock.png',
    'assets/images/socks/light_green_sock.png',
    'assets/images/socks/pastel_purple_sock.png',
    'assets/images/socks/sky_bleu_sock.png',
    'assets/images/socks/burgundi_sock.png',
    'assets/images/socks/burnt_orange_sock.png',
    'assets/images/socks/citrus_yellow_sock.png',
    'assets/images/socks/navy_sock.png',
    'assets/images/socks/maroon_sock.png',
    'assets/images/socks/teal_sock.png',
    'assets/images/socks/coral_sock.png',
    'assets/images/socks/indigo_sock.png',
    'assets/images/socks/lime_sock.png',
    'assets/images/socks/salmon_sock.png',
    'assets/images/socks/turquoise_sock.png',
  ];

  static const List<String> fallbackEmojis = [
    '🧦',
    '👟',
    '👞',
    '👠',
    '👡',
    '🥿',
    '👣',
    '🦶',
    '🧤',
    '🧣',
    '⭐',
    '❤️',
    '⚡',
    '🔷',
    '🔴',
    '🔵',
    '🟢',
    '🟡',
    '🟣',
    '🟤',
  ];
}
