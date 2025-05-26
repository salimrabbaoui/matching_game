import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Storage keys
  static const String _highestLevelKey = 'highestLevel';
  static const String _highestTimeLevelKey = 'highestTimeLevel';
  static const String _heartsKey = 'hearts';
  static const String _lastHeartLossTimeKey = 'lastHeartLossTime';
  static const String _totalScoreKey = 'totalScore';
  static const String _gamesPlayedKey = 'gamesPlayed';
  static const String _gamesWonKey = 'gamesWon';
  static const String _useImagesKey = 'useImages';
  static const String _soundEnabledKey = 'soundEnabled';
  static const String _musicEnabledKey = 'musicEnabled';

  /// Initialize the storage service
  Future<void> initialize() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  /// Ensure initialization before operations
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
          'StorageService not initialized. Call initialize() first.');
    }
  }

  // Level Progress
  Future<int> getHighestLevel() async {
    _ensureInitialized();
    return _prefs.getInt(_highestLevelKey) ?? 1;
  }

  Future<void> setHighestLevel(int level) async {
    _ensureInitialized();
    await _prefs.setInt(_highestLevelKey, level);
  }

  Future<int> getHighestTimeLevel() async {
    _ensureInitialized();
    return _prefs.getInt(_highestTimeLevelKey) ?? 1;
  }

  Future<void> setHighestTimeLevel(int level) async {
    _ensureInitialized();
    await _prefs.setInt(_highestTimeLevelKey, level);
  }

  // Heart System
  Future<int> getHearts() async {
    _ensureInitialized();
    return _prefs.getInt(_heartsKey) ?? 5;
  }

  Future<void> setHearts(int hearts) async {
    _ensureInitialized();
    await _prefs.setInt(_heartsKey, hearts);
  }

  Future<DateTime?> getLastHeartLossTime() async {
    _ensureInitialized();
    final milliseconds = _prefs.getInt(_lastHeartLossTimeKey);
    return milliseconds != null
        ? DateTime.fromMillisecondsSinceEpoch(milliseconds)
        : null;
  }

  Future<void> setLastHeartLossTime(DateTime? time) async {
    _ensureInitialized();
    if (time != null) {
      await _prefs.setInt(_lastHeartLossTimeKey, time.millisecondsSinceEpoch);
    } else {
      await _prefs.remove(_lastHeartLossTimeKey);
    }
  }

  // Game Statistics
  Future<int> getTotalScore() async {
    _ensureInitialized();
    return _prefs.getInt(_totalScoreKey) ?? 0;
  }

  Future<void> addToTotalScore(int score) async {
    _ensureInitialized();
    final currentScore = await getTotalScore();
    await _prefs.setInt(_totalScoreKey, currentScore + score);
  }

  Future<int> getGamesPlayed() async {
    _ensureInitialized();
    return _prefs.getInt(_gamesPlayedKey) ?? 0;
  }

  Future<void> incrementGamesPlayed() async {
    _ensureInitialized();
    final current = await getGamesPlayed();
    await _prefs.setInt(_gamesPlayedKey, current + 1);
  }

  Future<int> getGamesWon() async {
    _ensureInitialized();
    return _prefs.getInt(_gamesWonKey) ?? 0;
  }

  Future<void> incrementGamesWon() async {
    _ensureInitialized();
    final current = await getGamesWon();
    await _prefs.setInt(_gamesWonKey, current + 1);
  }

  // Settings
  Future<bool> getUseImages() async {
    _ensureInitialized();
    return _prefs.getBool(_useImagesKey) ?? true;
  }

  Future<void> setUseImages(bool useImages) async {
    _ensureInitialized();
    await _prefs.setBool(_useImagesKey, useImages);
  }

  Future<bool> getSoundEnabled() async {
    _ensureInitialized();
    return _prefs.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _ensureInitialized();
    await _prefs.setBool(_soundEnabledKey, enabled);
  }

  Future<bool> getMusicEnabled() async {
    _ensureInitialized();
    return _prefs.getBool(_musicEnabledKey) ?? true;
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _ensureInitialized();
    await _prefs.setBool(_musicEnabledKey, enabled);
  }

  // Utility Methods
  Future<void> clearAllData() async {
    _ensureInitialized();
    await _prefs.clear();
  }

  Future<void> resetProgress() async {
    _ensureInitialized();
    await _prefs.remove(_highestLevelKey);
    await _prefs.remove(_highestTimeLevelKey);
    await _prefs.remove(_totalScoreKey);
    await _prefs.remove(_gamesPlayedKey);
    await _prefs.remove(_gamesWonKey);
  }

  Future<Map<String, dynamic>> exportData() async {
    _ensureInitialized();
    return {
      'highestLevel': await getHighestLevel(),
      'highestTimeLevel': await getHighestTimeLevel(),
      'totalScore': await getTotalScore(),
      'gamesPlayed': await getGamesPlayed(),
      'gamesWon': await getGamesWon(),
      'useImages': await getUseImages(),
      'soundEnabled': await getSoundEnabled(),
      'musicEnabled': await getMusicEnabled(),
    };
  }
}
