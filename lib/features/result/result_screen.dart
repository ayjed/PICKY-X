import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../services/local_preferences_service.dart';
import '../game/game_screen.dart';

/// Results Screen presented upon matching all 8 pairs.
class ResultScreen extends StatelessWidget {
  final int moves;
  final int elapsedSeconds;
  final int? bestMoves;
  final int? bestTimeSeconds;
  final bool isNewBestMoves;
  final bool isNewBestTime;
  final LocalPreferencesService prefsService;

  const ResultScreen({
    super.key,
    required this.moves,
    required this.elapsedSeconds,
    this.bestMoves,
    this.bestTimeSeconds,
    this.isNewBestMoves = false,
    this.isNewBestTime = false,
    required this.prefsService,
  });

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Celebratory Trophy
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentYellow.withOpacity(0.15),
                      border: Border.all(color: AppColors.accentYellow, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentYellow.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      size: 60,
                      color: AppColors.accentYellow,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title & Subtitle
                  const Text(
                    AppStrings.victoryTitle,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.victorySubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Current Match Performance Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.surfaceCardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMetricRow(
                          title: AppStrings.currentMoves,
                          value: '$moves moves',
                          isNewBest: isNewBestMoves,
                          valueColor: AppColors.accentYellow,
                        ),
                        const Divider(color: AppColors.surfaceCardBorder, height: 24),
                        _buildMetricRow(
                          title: AppStrings.currentTime,
                          value: _formatDuration(elapsedSeconds),
                          isNewBest: isNewBestTime,
                          valueColor: AppColors.accentCyan,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lifetime Best Comparison Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceCardBorder.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              AppStrings.bestMoves,
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bestMoves != null ? '$bestMoves moves' : '--',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(height: 28, width: 1.5, color: AppColors.surfaceCardBorder),
                        Column(
                          children: [
                            const Text(
                              AppStrings.bestTime,
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bestTimeSeconds != null ? _formatDuration(bestTimeSeconds!) : '--:--',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Play Again Button (Primary CTA)
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.playButtonGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentPink.withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => GameScreen(prefsService: prefsService),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        AppStrings.playAgain,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Main Menu Button (Secondary Action)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.surfaceCardBorder, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: AppColors.surfaceCard.withOpacity(0.3),
                      ),
                      child: const Text(
                        AppStrings.backToHome,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow({
    required String title,
    required String value,
    required bool isNewBest,
    required Color valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            if (isNewBest) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accentYellow),
                ),
                child: const Text(
                  AppStrings.newBest,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentYellow,
                  ),
                ),
              ),
            ],
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor),
            ),
          ],
        ),
      ],
    );
  }
}
