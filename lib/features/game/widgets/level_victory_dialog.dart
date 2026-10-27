import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Celebratory Victory Dialog presented upon completing a Campaign Level.
class LevelVictoryDialog extends StatelessWidget {
  final int levelId;
  final int stars;
  final int score;
  final int movesRemaining;
  final int earnedCoins;
  final int earnedGems;
  final VoidCallback onNextLevel;
  final VoidCallback onReturnToMap;
  final VoidCallback? onDoubleCoinsWithAd;

  const LevelVictoryDialog({
    super.key,
    required this.levelId,
    required this.stars,
    required this.score,
    required this.movesRemaining,
    required this.earnedCoins,
    required this.earnedGems,
    required this.onNextLevel,
    required this.onReturnToMap,
    this.onDoubleCoinsWithAd,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.accentYellow, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentYellow.withOpacity(0.3),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stars Rating Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStar(1, isLeft: true),
                const SizedBox(width: 8),
                _buildStar(2, isCenter: true),
                const SizedBox(width: 8),
                _buildStar(3, isRight: true),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Level $levelId Completed!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              stars == 3 ? 'Flawless Victory! 3 Stars!' : 'Great Memory! Level Cleared!',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.accentGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Performance & Rewards Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.surfaceCardBorder),
              ),
              child: Column(
                children: [
                  _buildStatRow('Score', '$score pts', AppColors.accentCyan),
                  const SizedBox(height: 8),
                  _buildStatRow('Moves Left Bonus', '+$movesRemaining moves', AppColors.textSecondary),
                  const Divider(color: AppColors.surfaceCardBorder, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 6),
                          Text(
                            '+$earnedCoins Coins',
                            style: const TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      if (earnedGems > 0)
                        Row(
                          children: [
                            const Text('💎', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 6),
                            Text(
                              '+$earnedGems Gems',
                              style: const TextStyle(color: AppColors.accentCyan, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Double Coins with Ad Button
            if (onDoubleCoinsWithAd != null) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onDoubleCoinsWithAd,
                  icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.accentYellow, size: 22),
                  label: Text(
                    '2X Rewards (+${earnedCoins * 2} 🪙)',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF382F66),
                    side: const BorderSide(color: AppColors.accentYellow, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Next Level Button (Primary CTA)
            Container(
              width: double.infinity,
              height: 54,
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
                onPressed: onNextLevel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next Level',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Back to Map
            TextButton(
              onPressed: onReturnToMap,
              child: const Text(
                'Back to Saga Map',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStar(int starIndex, {bool isCenter = false, bool isLeft = false, bool isRight = false}) {
    final isFilled = stars >= starIndex;
    final size = isCenter ? 54.0 : 44.0;

    return Transform.translate(
      offset: Offset(0, isCenter ? -8 : 4),
      child: Icon(
        isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
        size: size,
        color: isFilled ? AppColors.accentYellow : AppColors.textMuted.withOpacity(0.5),
        shadows: isFilled
            ? [
                BoxShadow(
                  color: AppColors.accentYellow.withOpacity(0.6),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}
