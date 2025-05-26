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
    int additionalPairs = (level - 1) ~/ AppConstants.levelIncrementInterval;
    return min(AppConstants.basePairs + additionalPairs, AppConstants.maxPairs);
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
    // Decreases to 15 seconds per pair for higher levels
    double timePerPair = 30.0 - (level - 1) * 0.3;
    timePerPair = max(timePerPair, 15.0); // Minimum 15 seconds per pair

    return (pairs * timePerPair).round();
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
