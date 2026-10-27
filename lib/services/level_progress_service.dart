import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing level progression, star ratings, and campaign unlocks.
class LevelProgressService extends ChangeNotifier {
  static const String keyUnlockedLevel = 'pickyx_unlocked_level';
  static const String keyLevelStarsJson = 'pickyx_level_stars_json';
  static const String keyLevelScoresJson = 'pickyx_level_scores_json';

  final SharedPreferences _prefs;

  int _unlockedLevel = 1;
  final Map<int, int> _levelStars = {};
  final Map<int, int> _levelScores = {};

  LevelProgressService(this._prefs) {
    _loadState();
  }

  static Future<LevelProgressService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LevelProgressService(prefs);
  }

  int get unlockedLevel => _unlockedLevel;
  Map<int, int> get levelStars => Map.unmodifiable(_levelStars);
  Map<int, int> get levelScores => Map.unmodifiable(_levelScores);

  int get totalStarsEarned => _levelStars.values.fold(0, (sum, stars) => sum + stars);

  int getStarsForLevel(int levelId) => _levelStars[levelId] ?? 0;
  int getScoreForLevel(int levelId) => _levelScores[levelId] ?? 0;
  bool isLevelUnlocked(int levelId) => levelId <= _unlockedLevel;

  void _loadState() {
    _unlockedLevel = _prefs.getInt(keyUnlockedLevel) ?? 1;

    final starsString = _prefs.getString(keyLevelStarsJson);
    if (starsString != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(starsString);
        decoded.forEach((key, value) {
          final levelId = int.tryParse(key);
          if (levelId != null && value is int) {
            _levelStars[levelId] = value;
          }
        });
      } catch (_) {}
    }

    final scoresString = _prefs.getString(keyLevelScoresJson);
    if (scoresString != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(scoresString);
        decoded.forEach((key, value) {
          final levelId = int.tryParse(key);
          if (levelId != null && value is int) {
            _levelScores[levelId] = value;
          }
        });
      } catch (_) {}
    }
  }

  Future<void> _saveState() async {
    await _prefs.setInt(keyUnlockedLevel, _unlockedLevel);

    final starsMap = _levelStars.map((k, v) => MapEntry(k.toString(), v));
    await _prefs.setString(keyLevelStarsJson, jsonEncode(starsMap));

    final scoresMap = _levelScores.map((k, v) => MapEntry(k.toString(), v));
    await _prefs.setString(keyLevelScoresJson, jsonEncode(scoresMap));
  }

  /// Records a completed level result and unlocks the next level if applicable.
  Future<({bool isNewStarRecord, bool isNextLevelUnlocked})> recordLevelCompletion({
    required int levelId,
    required int stars,
    required int score,
  }) async {
    bool isNewStarRecord = false;
    bool isNextLevelUnlocked = false;

    // Update Stars
    final currentStars = _levelStars[levelId] ?? 0;
    if (stars > currentStars) {
      _levelStars[levelId] = stars;
      isNewStarRecord = true;
    }

    // Update High Score
    final currentScore = _levelScores[levelId] ?? 0;
    if (score > currentScore) {
      _levelScores[levelId] = score;
    }

    // Unlock Next Level
    if (levelId == _unlockedLevel && _unlockedLevel < 60) {
      _unlockedLevel = levelId + 1;
      isNextLevelUnlocked = true;
    }

    await _saveState();
    notifyListeners();

    return (isNewStarRecord: isNewStarRecord, isNextLevelUnlocked: isNextLevelUnlocked);
  }
}
