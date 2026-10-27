import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Modal dialog presented when a level is failed (lost 1 life).
class LevelFailedDialog extends StatelessWidget {
  final int levelId;
  final int remainingLives;
  final String lifeTimerText;
  final VoidCallback onRetry;
  final VoidCallback onReturnToMap;

  const LevelFailedDialog({
    super.key,
    required this.levelId,
    required this.remainingLives,
    required this.lifeTimerText,
    required this.onRetry,
    required this.onReturnToMap,
  });

  @override
  Widget build(BuildContext context) {
    final hasLives = remainingLives > 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.accentPink.withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPink.withOpacity(0.25),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Broken Heart Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentPink.withOpacity(0.15),
                border: Border.all(color: AppColors.accentPink, width: 2),
              ),
              child: const Icon(
                Icons.heart_broken_rounded,
                size: 46,
                color: AppColors.accentPink,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Level $levelId Failed',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You ran out of moves! You lost 1 life.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Lives Status Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceCardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_rounded, color: AppColors.accentPink, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Lives: $remainingLives / 5',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (remainingLives < 5) ...[
                    const SizedBox(width: 12),
                    Text(
                      '(+1 in $lifeTimerText)',
                      style: const TextStyle(
                        color: AppColors.accentYellow,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Retry Button
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: hasLives
                    ? AppColors.playButtonGradient
                    : const LinearGradient(colors: [Color(0xFF4A4468), Color(0xFF322E4A)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: hasLives
                    ? [
                        BoxShadow(
                          color: AppColors.accentPink.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed: hasLives ? onRetry : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      hasLives ? 'Retry Level (Cost 1 ❤️)' : 'No Lives Remaining',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Back to Map Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: onReturnToMap,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.surfaceCardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: AppColors.surfaceCard.withOpacity(0.3),
                ),
                child: const Text(
                  'Back to Saga Map',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
