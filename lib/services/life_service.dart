import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing the Candy Crush-style Lives/Energy system (Hearts ❤️).
/// Handles real-time countdown, background offline regeneration, and VIP unlimited lives.
class LifeService extends ChangeNotifier {
  static const int maxLives = 5;
  static const int secondsPerLife = 1200; // 20 minutes per life

  static const String keyLivesCount = 'pickyx_lives_count';
  static const String keyLastRegenTimestamp = 'pickyx_last_regen_timestamp';
  static const String keyUnlimitedUntil = 'pickyx_unlimited_lives_until';

  final SharedPreferences _prefs;
  Timer? _ticker;

  int _lives = maxLives;
  int _lastRegenTimestampMs = 0;
  int _unlimitedUntilMs = 0;

  LifeService(this._prefs) {
    _loadState();
    _recalculateLives();
    _startTicker();
  }

  static Future<LifeService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LifeService(prefs);
  }

  int get currentLives => _lives;
  bool get isFull => _lives >= maxLives;
  bool get isUnlimited => DateTime.now().millisecondsSinceEpoch < _unlimitedUntilMs;

  Duration get unlimitedRemaining {
    if (!isUnlimited) return Duration.zero;
    final remainingMs = _unlimitedUntilMs - DateTime.now().millisecondsSinceEpoch;
    return Duration(milliseconds: max(0, remainingMs));
  }

  /// Seconds until next life is restored (0 if full)
  int get secondsUntilNextLife {
    if (isFull) return 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedSeconds = (now - _lastRegenTimestampMs) ~/ 1000;
    final remaining = secondsPerLife - (elapsedSeconds % secondsPerLife);
    return max(0, remaining);
  }

  /// Formatted countdown display (e.g., "19:42", "FULL", "UNLIMITED")
  String get formattedTimer {
    if (isUnlimited) {
      final rem = unlimitedRemaining;
      final h = rem.inHours;
      final m = rem.inMinutes % 60;
      final s = rem.inSeconds % 60;
      if (h > 0) {
        return '${h}h ${m}m';
      }
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    if (isFull) return 'FULL';
    final sec = secondsUntilNextLife;
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _loadState() {
    _lives = _prefs.getInt(keyLivesCount) ?? maxLives;
    _lastRegenTimestampMs = _prefs.getInt(keyLastRegenTimestamp) ?? DateTime.now().millisecondsSinceEpoch;
    _unlimitedUntilMs = _prefs.getInt(keyUnlimitedUntil) ?? 0;
  }

  Future<void> _saveState() async {
    await _prefs.setInt(keyLivesCount, _lives);
    await _prefs.setInt(keyLastRegenTimestamp, _lastRegenTimestampMs);
    await _prefs.setInt(keyUnlimitedUntil, _unlimitedUntilMs);
  }

  /// Calculates lives gained while app was closed or ticking
  void _recalculateLives() {
    if (_lives >= maxLives) {
      _lastRegenTimestampMs = DateTime.now().millisecondsSinceEpoch;
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedSeconds = (now - _lastRegenTimestampMs) ~/ 1000;

    if (elapsedSeconds >= secondsPerLife) {
      final livesGained = elapsedSeconds ~/ secondsPerLife;
      _lives = min(maxLives, _lives + livesGained);

      // Advance regen timestamp by full life cycles consumed
      final consumedSeconds = livesGained * secondsPerLife;
      _lastRegenTimestampMs += consumedSeconds * 1000;

      if (_lives >= maxLives) {
        _lastRegenTimestampMs = now;
      }
      _saveState();
      notifyListeners();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recalculateLives();
      notifyListeners();
    });
  }

  /// Checks if the player can start a level
  bool canPlay() {
    if (isUnlimited) return true;
    return _lives > 0;
  }

  /// Consumes 1 life when starting/failing a level.
  /// Returns true if life was consumed or player has unlimited lives.
  bool consumeLife() {
    if (isUnlimited) return true;
    if (_lives <= 0) return false;

    final wasFull = isFull;
    _lives--;
    if (wasFull) {
      _lastRegenTimestampMs = DateTime.now().millisecondsSinceEpoch;
    }
    _saveState();
    notifyListeners();
    return true;
  }

  /// Instant full refill (e.g. from store purchase or VIP reward)
  void refillMaxLives() {
    _lives = maxLives;
    _lastRegenTimestampMs = DateTime.now().millisecondsSinceEpoch;
    _saveState();
    notifyListeners();
  }

  /// Add specific amount of lives (+1 from Rewarded Ad, etc.)
  void addLives(int count) {
    if (count <= 0) return;
    _lives = min(maxLives, _lives + count);
    if (isFull) {
      _lastRegenTimestampMs = DateTime.now().millisecondsSinceEpoch;
    }
    _saveState();
    notifyListeners();
  }

  /// Grant unlimited lives for a duration (VIP subscription or timed booster)
  void grantUnlimitedLives(Duration duration) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final currentEnd = max(now, _unlimitedUntilMs);
    _unlimitedUntilMs = currentEnd + duration.inMilliseconds;
    _saveState();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    super.dispose();
  }
}
