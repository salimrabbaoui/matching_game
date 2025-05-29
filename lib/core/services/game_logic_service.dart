import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/sock_card.dart';
import '../models/game_state.dart';
import '../constants/app_constants.dart';
import 'color_group_service.dart';

class GameLogicService {
  static final GameLogicService _instance = GameLogicService._internal();
  factory GameLogicService() => _instance;
  GameLogicService._internal();

  /// Calculate number of pairs for a given level
  int calculatePairsForLevel(int level) {
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
        // For levels beyond 9, continue with a pattern
        if (level > 9) {
          return 21 +
              ((level - 9) * 2); // Increase by 2 pairs per level after 9
        }
        return 6;
    }
  }

  /// Calculate maximum moves allowed for a level
  int calculateMaxMovesForLevel(int level) {
    final pairs = calculatePairsForLevel(level);

    switch (level) {
      case 1:
        return 16; // 6 pairs × 3.16
      case 2:
        return 20; // 8 pairs × 2.87
      case 3:
        return 24; // 10 pairs × 2.8
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

  /// Calculate time limit for time-based games
  int calculateTimeForLevel(int level) {
    final pairs = calculatePairsForLevel(level);

    // Base time: 30 seconds per pair for level 1
    //increases by 5 seconds per every correct match
    int timePerPair = 30;

    return ((pairs * 5) + timePerPair);
  }

  /// Initialize game cards for a level
  List<SockCard> initializeCards(int level, {bool useImages = true}) {
    final pairsCount = calculatePairsForLevel(level);

    List<SockCard> selectedSymbols;

    if (useImages) {
      // Use the new color group service for smart selection
      selectedSymbols = ColorGroupService.selectSocksForLevel(
          level, pairsCount, AppConstants.sockImagePaths);
    } else {
      // Use fallback emojis with random selection
      final shuffledEmojis = List.from(AppConstants.fallbackEmojis)
        ..shuffle(Random());
      selectedSymbols = shuffledEmojis
          .take(pairsCount)
          .map((emoji) => SockCard(imagePath: emoji, name: 'Sock $emoji'))
          .toList();
    }

    // Create pairs and shuffle
    final cards = [...selectedSymbols, ...selectedSymbols];
    cards.shuffle(Random());

    return cards;
  }

  /// Check if two cards match
  bool doCardsMatch(SockCard card1, SockCard card2) {
    return card1.imagePath == card2.imagePath && card1.name == card2.name;
  }

  /// Get level color based on difficulty
  Color getLevelColor(int level) {
    if (level <= 3) return AppConstants.successColor; // Soft green for easy
    if (level <= 6) return AppConstants.accentColor; // Warm yellow for medium
    if (level <= 9) return const Color(0xFFFF8A50); // Soft orange for hard
    if (level <= 12) return AppConstants.errorColor; // Soft coral for expert
    return AppConstants.primaryColor; // Blue for master levels
  }

  /// Get difficulty icon for level
  Widget getLevelDifficultyIcon(int level) {
    if (level <= 3) {
      return const Icon(Icons.star, color: AppConstants.successColor, size: 20);
    } else if (level <= 6) {
      return const Icon(Icons.star_half,
          color: AppConstants.accentColor, size: 20);
    } else if (level <= 9) {
      return const Icon(Icons.whatshot, color: Color(0xFFFF8A50), size: 20);
    } else if (level <= 12) {
      return const Icon(Icons.local_fire_department,
          color: AppConstants.errorColor, size: 20);
    } else {
      return const Icon(Icons.diamond,
          color: AppConstants.primaryColor, size: 20);
    }
  }

  /// Get difficulty label for level
  String getDifficultyLabel(int level) {
    if (level <= 3) return 'Easy';
    if (level <= 6) return 'Medium';
    if (level <= 9) return 'Hard';
    if (level <= 12) return 'Expert';
    return 'Master';
  }

  /// Calculate score based on performance
  int calculateScore(GameState gameState) {
    if (gameState.status != GameStatus.won) return 0;

    final baseScore = gameState.pairsCount * 100;
    final moveEfficiency = (gameState.maxMoves - gameState.moves) * 10;
    final levelBonus = gameState.level * 5;

    return baseScore + moveEfficiency + levelBonus;
  }

  /// Check if level is unlocked
  bool isLevelUnlocked(int level, int highestUnlockedLevel) {
    return level <= highestUnlockedLevel;
  }

  /// Get next level after completion
  int getNextLevel(int currentLevel) {
    return min(currentLevel + 1, AppConstants.totalLevels);
  }
}
