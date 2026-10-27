import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Modal dialog presented when a player runs out of moves in a Campaign Level.
class OutOfMovesDialog extends StatelessWidget {
  final int coinsBalance;
  final VoidCallback onBuyMovesWithCoins;
  final VoidCallback onWatchAdForMoves;
  final VoidCallback onGiveUp;

  const OutOfMovesDialog({
    super.key,
    required this.coinsBalance,
    required this.onBuyMovesWithCoins,
    required this.onWatchAdForMoves,
    required this.onGiveUp,
  });

  @override
  Widget build(BuildContext context) {
    final canAffordCoins = coinsBalance >= 50;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.accentOrange, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentOrange.withOpacity(0.35),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Out of Moves Header Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentOrange.withOpacity(0.2),
                border: Border.all(color: AppColors.accentOrange, width: 2),
              ),
              child: const Icon(
                Icons.hourglass_bottom_rounded,
                size: 44,
                color: AppColors.accentOrange,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Out of Moves!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Do not give up now! Get +5 extra moves to keep your winning streak alive.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Option 1: Buy +5 Moves with Coins
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: canAffordCoins
                    ? AppColors.playButtonGradient
                    : const LinearGradient(colors: [Color(0xFF4A4468), Color(0xFF322E4A)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: canAffordCoins
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
                onPressed: canAffordCoins ? onBuyMovesWithCoins : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      '+5 Moves',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Text('🪙 50', style: TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Option 2: Watch Ad for +5 Moves
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onWatchAdForMoves,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_fill_rounded, color: AppColors.accentGreen, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Watch Ad for +5 Moves',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Option 3: Give up & Lose Life
            TextButton(
              onPressed: onGiveUp,
              child: const Text(
                'Give Up (-1 ❤️ Life)',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
