import 'package:flutter/services.dart';
import 'local_preferences_service.dart';

/// Service managing offline sound effects and haptic feedback.
class AudioService {
  final LocalPreferencesService _prefsService;

  AudioService(this._prefsService);

  bool get isSoundEnabled => _prefsService.isSoundEnabled;

  /// Card flip audio and light haptic feedback
  Future<void> playFlip() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {
      // Haptics unavailable on device, ignore
    }
  }

  /// Match found audio and positive haptic feedback
  Future<void> playMatch() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // Haptics unavailable on device, ignore
    }
  }

  /// Mismatch audio and double-tap haptic feedback
  Future<void> playMismatch() async {
    try {
      await HapticFeedback.lightImpact();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Haptics unavailable on device, ignore
    }
  }

  /// Victory fanfare audio and celebratory vibration
  Future<void> playWin() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.mediumImpact();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.heavyImpact();
    } catch (_) {
      // Haptics unavailable on device, ignore
    }
  }
}
