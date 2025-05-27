import 'dart:math';
import 'package:flutter/material.dart';
import '../models/sock_card.dart';
import '../models/game_state.dart';
import '../constants/app_constants.dart';

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
        // For levels beyond 9, continue with a progressive pattern
        if (level <= 15) {
          return 21 + (level - 9); // Gradually increase by 1 pair per level
        } else {
          return min(25, 25); // Cap at 25 pairs for very high levels
        }
    }
  }

  /// Calculate maximum moves allowed for a level
  int calculateMaxMovesForLevel(int level) {
    final pairs = calculatePairsForLevel(level);

    // Calculate progress through total levels (0.0 to 1.0)
    double progressFactor =
        min((level - 1) / (AppConstants.totalLevels - 1), 1.0);

    // Start with multiplier of 3.0, end with 2.0
    double multiplier = AppConstants.baseMultiplier - progressFactor;

    // Calculate base moves
    int baseMoves = (pairs * multiplier).floor();

    // Apply level-specific adjustment
    int levelMod = level % 3;
    int movesAdjustment = 0;

    if (levelMod == 1) {
      movesAdjustment = 1; // Slightly easier
    } else if (levelMod == 0) {
      movesAdjustment = -1; // Slightly harder
    }
    // levelMod == 2 keeps standard calculation

    return max(
        baseMoves + movesAdjustment, pairs); // Never less than perfect play
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
      // Shuffle and select from image paths
      final shuffledPaths = List.from(AppConstants.sockImagePaths)
        ..shuffle(Random());
      selectedSymbols = shuffledPaths.take(pairsCount).map((path) {
        final name = path.split('/').last.split('.').first.replaceAll('_', ' ');
        return SockCard(imagePath: path, name: name);
      }).toList();
    } else {
      // Use fallback emojis
      final shuffledEmojis = List.from(AppConstants.fallbackEmojis)
        ..shuffle(Random());
      selectedSymbols = shuffledEmojis
          .take(pairsCount)
          .map((emoji) => SockCard(imagePath: emoji, name: 'Sock ${emoji}'))
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
    if (level <= 5) return AppConstants.successColor;
    if (level <= 15) return AppConstants.accentColor;
    if (level <= 30) return Colors.orange;
    if (level <= 45) return AppConstants.errorColor;
    return Colors.purple;
  }

  /// Get difficulty icon for level
  Widget getLevelDifficultyIcon(int level) {
    if (level <= 5) {
      return const Icon(Icons.star, color: Colors.green, size: 20);
    } else if (level <= 15) {
      return const Icon(Icons.star_half, color: Colors.orange, size: 20);
    } else if (level <= 30) {
      return const Icon(Icons.whatshot, color: Colors.red, size: 20);
    } else if (level <= 45) {
      return const Icon(Icons.local_fire_department,
          color: Colors.red, size: 20);
    } else {
      return const Icon(Icons.diamond, color: Colors.purple, size: 20);
    }
  }

  /// Get difficulty label for level
  String getDifficultyLabel(int level) {
    if (level <= 5) return 'Easy';
    if (level <= 15) return 'Medium';
    if (level <= 30) return 'Hard';
    if (level <= 45) return 'Expert';
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
