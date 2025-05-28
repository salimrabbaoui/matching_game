import 'dart:math';
import '../models/sock_card.dart';

/// Service for managing color groups of sock cards to ensure visual variety
class ColorGroupService {
  /// Color groups organized by visual similarity
  static const Map<String, List<String>> colorGroups = {
    // Red/Pink/Warm group
    'warm': [
      'assets/images/socks/red_sock.png',
      'assets/images/socks/pink_sock.png',
      'assets/images/socks/salmon_sock.png',
      'assets/images/socks/coral_sock.png',
      'assets/images/socks/burnt_orange_sock.png',
      'assets/images/socks/maroon_sock.png',
      'assets/images/socks/burgundi_sock.png',
    ],

    // Blue/Cool group
    'cool': [
      'assets/images/socks/blue_sock.png',
      'assets/images/socks/sky_bleu_sock.png',
      'assets/images/socks/navy_sock.png',
      'assets/images/socks/teal_sock.png',
      'assets/images/socks/turquoise_sock.png',
      'assets/images/socks/indigo_sock.png',
    ],

    // Green group
    'green': [
      'assets/images/socks/green_sock.png',  
      'assets/images/socks/lime_sock.png',
    ],

    // Yellow/Bright group
    'bright': [
      'assets/images/socks/yellow_sock.png',
      'assets/images/socks/citrus_yellow_sock.png',
    ],

    // Purple group
    'purple': [
      'assets/images/socks/purple_sock.png',
      'assets/images/socks/pastel_purple_sock.png',
    ],

    // Neutral/Dark group
    'neutral': [
      'assets/images/socks/black_sock.png',
      'assets/images/socks/grey_sock.png',
      'assets/images/socks/brown_sock.png',
    ],

    // Light group
    'light': [
      'assets/images/socks/white_sock.png',
      'assets/images/socks/off_white_sock.png',
      'assets/images/socks/light_green_sock.png',
    ],
  };

  /// Get color group for a given sock image path
  static String? getColorGroup(String imagePath) {
    for (final entry in colorGroups.entries) {
      if (entry.value.contains(imagePath)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Get all socks from a specific color group
  static List<String> getSocksFromGroup(String groupName) {
    return colorGroups[groupName] ?? [];
  }

  /// Smart selection of socks that prioritizes visual variety for early levels
  static List<SockCard> selectSocksForLevel(
      int level, int pairsCount, List<String> allSockPaths) {
    // For very early levels (1-3), prioritize maximum visual variety
    if (level <= 3) {
      return _selectWithMaximumVariety(pairsCount, allSockPaths);
    }

    // For early levels (4-8), still prioritize variety but allow some within-group selection
    if (level <= 8) {
      return _selectWithModeratVariety(pairsCount, allSockPaths);
    }

    // For higher levels, use random selection (current behavior)
    return _selectRandomly(pairsCount, allSockPaths);
  }

  /// Select socks with maximum visual variety (different color groups)
  static List<SockCard> _selectWithMaximumVariety(
      int pairsCount, List<String> allSockPaths) {
    final selectedSocks = <SockCard>[];
    final usedGroups = <String>{};
    final availableGroups = colorGroups.keys.toList()..shuffle(Random());

    // First, try to select one sock from each color group
    for (final groupName in availableGroups) {
      if (selectedSocks.length >= pairsCount) break;

      final groupSocks = getSocksFromGroup(groupName);
      if (groupSocks.isNotEmpty) {
        final shuffledGroupSocks = List<String>.from(groupSocks)
          ..shuffle(Random());
        final selectedPath = shuffledGroupSocks.first;

        selectedSocks.add(_createSockCard(selectedPath));
        usedGroups.add(groupName);
      }
    }

    // If we need more socks and have exhausted groups, add more from different groups
    while (selectedSocks.length < pairsCount) {
      bool added = false;

      // Try to add from groups we haven't used much
      for (final groupName in availableGroups) {
        if (selectedSocks.length >= pairsCount) break;

        final groupSocks = getSocksFromGroup(groupName);
        final alreadySelectedFromGroup = selectedSocks
            .where((sock) => getColorGroup(sock.imagePath) == groupName)
            .length;

        // Limit to 2 socks per group in maximum variety mode
        if (alreadySelectedFromGroup < 2 && groupSocks.isNotEmpty) {
          final availableFromGroup = groupSocks
              .where((path) =>
                  !selectedSocks.any((sock) => sock.imagePath == path))
              .toList();

          if (availableFromGroup.isNotEmpty) {
            availableFromGroup.shuffle(Random());
            selectedSocks.add(_createSockCard(availableFromGroup.first));
            added = true;
            break;
          }
        }
      }

      // If we couldn't add from preferred groups, add any available sock
      if (!added) {
        final usedPaths = selectedSocks.map((sock) => sock.imagePath).toSet();
        final availablePaths =
            allSockPaths.where((path) => !usedPaths.contains(path)).toList();

        if (availablePaths.isNotEmpty) {
          availablePaths.shuffle(Random());
          selectedSocks.add(_createSockCard(availablePaths.first));
        } else {
          break; // No more socks available
        }
      }
    }

    return selectedSocks;
  }

  /// Select socks with moderate variety (some grouping allowed)
  static List<SockCard> _selectWithModeratVariety(
      int pairsCount, List<String> allSockPaths) {
    final selectedSocks = <SockCard>[];
    final groupUsageCount = <String, int>{};

    // Initialize group usage counts
    for (final groupName in colorGroups.keys) {
      groupUsageCount[groupName] = 0;
    }

    final shuffledPaths = List<String>.from(allSockPaths)..shuffle(Random());

    for (final path in shuffledPaths) {
      if (selectedSocks.length >= pairsCount) break;

      final group = getColorGroup(path);
      if (group != null) {
        final currentUsage = groupUsageCount[group] ?? 0;

        // Allow up to 3 socks per group in moderate variety mode
        if (currentUsage < 3) {
          selectedSocks.add(_createSockCard(path));
          groupUsageCount[group] = currentUsage + 1;
        }
      } else {
        // If no group found, just add it
        selectedSocks.add(_createSockCard(path));
      }
    }

    // Fill remaining spots if needed
    while (selectedSocks.length < pairsCount) {
      final usedPaths = selectedSocks.map((sock) => sock.imagePath).toSet();
      final availablePaths =
          allSockPaths.where((path) => !usedPaths.contains(path)).toList();

      if (availablePaths.isNotEmpty) {
        availablePaths.shuffle(Random());
        selectedSocks.add(_createSockCard(availablePaths.first));
      } else {
        break;
      }
    }

    return selectedSocks;
  }

  /// Random selection (current behavior for higher levels)
  static List<SockCard> _selectRandomly(
      int pairsCount, List<String> allSockPaths) {
    final shuffledPaths = List<String>.from(allSockPaths)..shuffle(Random());
    return shuffledPaths
        .take(pairsCount)
        .map((path) => _createSockCard(path))
        .toList();
  }

  /// Create a SockCard from an image path
  static SockCard _createSockCard(String path) {
    final name = path.split('/').last.split('.').first.replaceAll('_', ' ');
    return SockCard(imagePath: path, name: name);
  }

  /// Get debug information about color distribution
  static Map<String, int> analyzeColorDistribution(List<SockCard> socks) {
    final distribution = <String, int>{};

    for (final sock in socks) {
      final group = getColorGroup(sock.imagePath) ?? 'unknown';
      distribution[group] = (distribution[group] ?? 0) + 1;
    }

    return distribution;
  }

  /// Get visual difficulty score (lower is easier)
  static double calculateVisualDifficulty(List<SockCard> socks) {
    final distribution = analyzeColorDistribution(socks);
    final uniqueGroups = distribution.keys.length;
    final totalSocks = socks.length;

    if (totalSocks == 0) return 0.0;

    // More groups = easier (lower difficulty)
    // Perfect distribution would be each sock from different group
    final groupVarietyScore = uniqueGroups / totalSocks;

    // Calculate concentration penalty (higher concentration = harder)
    double concentrationPenalty = 0.0;
    for (final count in distribution.values) {
      if (count > 1) {
        concentrationPenalty += (count - 1) * 0.2;
      }
    }

    // Return difficulty score (0 = easiest, 1+ = harder)
    return (1.0 - groupVarietyScore) + concentrationPenalty;
  }
}
