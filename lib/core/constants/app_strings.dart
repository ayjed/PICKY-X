/// Centralized user-facing strings and offline copy for Picky X
class AppStrings {
  AppStrings._();

  static const String appName = 'Picky X';
  static const String appTagline = 'Master Your Memory';
  static const String play = 'Play';
  static const String howToPlay = 'How to Play';
  static const String sound = 'Sound';
  static const String soundOn = 'Sound: ON';
  static const String soundOff = 'Sound: OFF';
  static const String privacyAndAbout = 'Privacy & About';
  static const String version = 'Version 2.0.0 (Build 2)';

  // Game Screen
  static const String moves = 'Moves';
  static const String pairs = 'Pairs';
  static const String time = 'Time';
  static const String restart = 'Restart';

  // Result State
  static const String victoryTitle = 'Puzzle Completed!';
  static const String victorySubtitle = 'Great memory! You matched all pairs.';
  static const String currentMoves = 'Final Moves';
  static const String currentTime = 'Final Time';
  static const String bestMoves = 'Best Moves';
  static const String bestTime = 'Best Time';
  static const String newBest = 'NEW BEST!';
  static const String playAgain = 'Play Again';
  static const String backToHome = 'Main Menu';

  // Instructions
  static const String instructionsTitle = 'How to Play';
  static const String step1 = '1. Tap any card on the 4×4 board to reveal its hidden symbol.';
  static const String step2 = '2. Tap a second card to find its matching twin.';
  static const String step3 = '3. If they match, they stay face up permanently!';
  static const String step4 = '4. If they do not match, remember their positions before they flip back.';
  static const String step5 = '5. Match all 8 pairs with the fewest moves and fastest time!';

  // Privacy Policy (Offline Draft)
  static const String privacyTitle = 'Privacy & About';
  static const String privacyBody = '''
Picky X is an offline-first card matching game.

• Zero Data Collection: We do not collect, transmit, track, or share any personal information, device identifiers, or usage analytics.
• 100% Offline: All gameplay, best scores, and sound preferences remain exclusively on your device.
• No Permissions: No sensitive device permissions (location, camera, microphone, storage, contacts) are requested or required.
• No Ads or In-App Purchases: The complete game experience is accessible without payments, logins, or ads.

Version: 1.0.0
Platform: Android (API 36 / Android 16 Baseline)
''';
}
