import 'package:shared_preferences/shared_preferences.dart';

/// Service managing offline local storage for scores and sound settings.
/// Strictly local-only: No personal identifiable information (PII) is stored or transmitted.
class LocalPreferencesService {
  static const String keyBestMoves = 'best_moves';
  static const String keyBestTimeSeconds = 'best_time_seconds';
  static const String keySoundEnabled = 'sound_enabled';

  final SharedPreferences _prefs;

  LocalPreferencesService(this._prefs);

  /// Factory initializer for pre-warming on app launch
  static Future<LocalPreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalPreferencesService(prefs);
  }

  // --- Sound Preference ---

  /// Returns user's sound preference (defaults to true if unset).
  bool get isSoundEnabled => _prefs.getBool(keySoundEnabled) ?? true;

  /// Updates user's sound preference in local storage.
  Future<bool> setSoundEnabled(bool enabled) async {
    return _prefs.setBool(keySoundEnabled, enabled);
  }

  // --- Best Scores ---

  /// Returns the lowest move count achieved in a completed game, or null if no record exists.
  int? get bestMoves => _prefs.getInt(keyBestMoves);

  /// Returns the fastest completion time in seconds, or null if no record exists.
  int? get bestTimeSeconds => _prefs.getInt(keyBestTimeSeconds);

  /// Evaluates and updates best scores upon a completed game session.
  /// Moves and Time are tracked independently:
  /// - `bestMoves` is replaced only if `moves < stored_best_moves` (or if no previous record).
  /// - `bestTimeSeconds` is replaced only if `timeSeconds < stored_best_time` (or if no previous record).
  ///
  /// Returns a record indicating whether new records were achieved.
  Future<({bool isNewBestMoves, bool isNewBestTime})> recordGameResult({
    required int moves,
    required int timeSeconds,
  }) async {
    bool isNewBestMoves = false;
    bool isNewBestTime = false;

    final currentBestMoves = bestMoves;
    if (currentBestMoves == null || moves < currentBestMoves) {
      await _prefs.setInt(keyBestMoves, moves);
      isNewBestMoves = true;
    }

    final currentBestTime = bestTimeSeconds;
    if (currentBestTime == null || timeSeconds < currentBestTime) {
      await _prefs.setInt(keyBestTimeSeconds, timeSeconds);
      isNewBestTime = true;
    }

    return (isNewBestMoves: isNewBestMoves, isNewBestTime: isNewBestTime);
  }

  /// Clears stored best scores (useful for testing or profile reset).
  Future<void> clearScores() async {
    await _prefs.remove(keyBestMoves);
    await _prefs.remove(keyBestTimeSeconds);
  }
}
