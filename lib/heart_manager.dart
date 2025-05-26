import 'dart:async';
import 'dart:math' show min;
import 'package:shared_preferences/shared_preferences.dart';

class HeartManager {
  static final HeartManager _instance = HeartManager._internal();
  factory HeartManager() => _instance;
  HeartManager._internal();

  // Heart system constants
  static const int maxHearts = 5;
  static const int heartRegenerationMinutes = 30;

  // Heart state variables
  int _hearts = maxHearts;
  DateTime? _lastHeartLossTime;
  Timer? _heartRegenerationTimer;

  // Getters
  int get hearts => _hearts;
  DateTime? get lastHeartLossTime => _lastHeartLossTime;
  int get maxHeartsCount => maxHearts;

  // Initialize heart system
  Future<void> initialize() async {
    await loadHearts();
    startHeartRegenerationTimer();
  }

  // Load hearts from persistent storage
  Future<void> loadHearts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHearts = prefs.getInt('hearts') ?? maxHearts;
    final lastLossTimeMillis = prefs.getInt('lastHeartLossTime');

    DateTime? lastLoss;
    if (lastLossTimeMillis != null) {
      lastLoss = DateTime.fromMillisecondsSinceEpoch(lastLossTimeMillis);
      // Calculate regenerated hearts since last loss
      final now = DateTime.now();
      final minutesSinceLastLoss = now.difference(lastLoss).inMinutes;
      final regeneratedHearts =
          minutesSinceLastLoss ~/ heartRegenerationMinutes;

      if (regeneratedHearts > 0 && savedHearts < maxHearts) {
        final newHeartCount = min(savedHearts + regeneratedHearts, maxHearts);

        // If all hearts regenerated, clear last loss time
        if (newHeartCount >= maxHearts) {
          lastLoss = null;
          await prefs.remove('lastHeartLossTime');
        } else {
          // Update last loss time to account for regenerated hearts
          final adjustedTime = lastLoss.add(
              Duration(minutes: regeneratedHearts * heartRegenerationMinutes));
          lastLoss = adjustedTime;
          await prefs.setInt(
              'lastHeartLossTime', adjustedTime.millisecondsSinceEpoch);
        }

        // Save updated heart count
        await prefs.setInt('hearts', newHeartCount);
        _hearts = newHeartCount;
        _lastHeartLossTime = lastLoss;
      } else {
        _hearts = savedHearts;
        _lastHeartLossTime = lastLoss;
      }
    } else {
      _hearts = savedHearts;
      _lastHeartLossTime = null;
    }
  }

  // Save hearts to persistent storage
  Future<void> saveHearts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hearts', _hearts);
    if (_lastHeartLossTime != null) {
      await prefs.setInt(
          'lastHeartLossTime', _lastHeartLossTime!.millisecondsSinceEpoch);
    } else {
      await prefs.remove('lastHeartLossTime');
    }
  }

  // Lose a heart
  void loseHeart() {
    if (_hearts > 0) {
      _hearts--;
      if (_lastHeartLossTime == null) {
        _lastHeartLossTime = DateTime.now();
      }
      saveHearts();
      startHeartRegenerationTimer();
    }
  }

  // Check if player has hearts to play
  bool hasHeartsToPlay() {
    return _hearts > 0;
  }

  // Grant unlimited hearts (premium feature)
  void grantUnlimitedHearts() {
    _hearts = maxHearts;
    _lastHeartLossTime = null;
    saveHearts();
    _heartRegenerationTimer?.cancel();
  }

  // Recharge hearts (test feature)
  void rechargeHearts() {
    _hearts = maxHearts;
    _lastHeartLossTime = null;
    saveHearts();
    _heartRegenerationTimer?.cancel();
  }

  // Get next heart regeneration time as formatted string
  String getNextHeartTime() {
    if (_lastHeartLossTime == null) return '';

    final now = DateTime.now();
    final timeSinceLoss = now.difference(_lastHeartLossTime!);
    final nextHeartTime = Duration(minutes: heartRegenerationMinutes) -
        Duration(
            minutes: timeSinceLoss.inMinutes % heartRegenerationMinutes,
            seconds: timeSinceLoss.inSeconds % 60);

    final minutes = nextHeartTime.inMinutes;
    final seconds = nextHeartTime.inSeconds % 60;

    return '${minutes}m ${seconds}s';
  }

  // Start heart regeneration timer
  void startHeartRegenerationTimer() {
    // Cancel any existing timer
    _heartRegenerationTimer?.cancel();

    // Only start timer if hearts are missing and we have a last loss time
    if (_hearts < maxHearts && _lastHeartLossTime != null) {
      _heartRegenerationTimer =
          Timer.periodic(const Duration(seconds: 1), (timer) {
        checkHeartRegeneration();
      });
    }
  }

  // Check and process heart regeneration
  void checkHeartRegeneration() {
    if (_hearts >= maxHearts || _lastHeartLossTime == null) {
      _heartRegenerationTimer?.cancel();
      return;
    }

    final now = DateTime.now();
    final minutesSinceLastLoss = now.difference(_lastHeartLossTime!).inMinutes;
    final heartsToRegenerate = minutesSinceLastLoss ~/ heartRegenerationMinutes;

    if (heartsToRegenerate > 0) {
      // Add regenerated hearts, up to max
      _hearts = min(_hearts + heartsToRegenerate, maxHearts);

      // Update last heart loss time or clear if full
      if (_hearts >= maxHearts) {
        _lastHeartLossTime = null;
      } else {
        _lastHeartLossTime = _lastHeartLossTime!.add(
            Duration(minutes: heartsToRegenerate * heartRegenerationMinutes));
      }

      // Save updated hearts
      saveHearts();

      // If we've regenerated all hearts, stop the timer
      if (_hearts >= maxHearts) {
        _heartRegenerationTimer?.cancel();
      }
    }
  }

  // Dispose resources
  void dispose() {
    _heartRegenerationTimer?.cancel();
  }
}
