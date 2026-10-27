import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/level_model.dart';

/// Modal dialog previewing a level's targets, move limits, and rules before entering.
class LevelPreviewDialog extends StatelessWidget {
  final LevelModel level;
  final int currentStars;
  final int currentLives;
  final bool isUnlimitedLives;
  final VoidCallback onPlay;
  final VoidCallback onOpenStore;

  const LevelPreviewDialog({
    super.key,
    required this.level,
    required this.currentStars,
    required this.currentLives,
    required this.isUnlimitedLives,
    required this.onPlay,
    required this.onOpenStore,
  });

  @override
  Widget build(BuildContext context) {
    final canPlay = isUnlimitedLives || currentLives > 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primaryPurpleLight, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // World Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryPurpleLight.withOpacity(0.5)),
              ),
              child: Text(
                'WORLD ${level.worldNumber}: ${level.worldName.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.accentCyan,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Level Title
            Text(
              'Level ${level.id}',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Stars Earned So Far
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isFilled = currentStars > index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 28,
                    color: isFilled ? AppColors.accentYellow : AppColors.textMuted.withOpacity(0.4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Targets & Constraints Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.surfaceCardBorder),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.grid_view_rounded,
                    title: 'Grid Size',
                    value: '${level.gridRows} × ${level.gridCols} (${level.totalPairs} Pairs)',
                    color: AppColors.accentGreen,
                  ),
                  const Divider(color: AppColors.surfaceCardBorder, height: 16),
                  _buildDetailRow(
                    icon: Icons.touch_app_rounded,
                    title: 'Moves Limit',
                    value: '${level.maxMoves} Moves',
                    color: AppColors.accentYellow,
                  ),
                  if (level.timeLimitSeconds != null) ...[
                    const Divider(color: AppColors.surfaceCardBorder, height: 16),
                    _buildDetailRow(
                      icon: Icons.timer_rounded,
                      title: 'Time Limit',
                      value: '${level.timeLimitSeconds} Seconds',
                      color: AppColors.accentPink,
                    ),
                  ],
                  if (level.hasIceObstacles) ...[
                    const Divider(color: AppColors.surfaceCardBorder, height: 16),
                    _buildDetailRow(
                      icon: Icons.ac_unit_rounded,
                      title: 'Obstacle',
                      value: 'Frozen Cards (2x Hits)',
                      color: AppColors.accentCyan,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Play CTA
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: canPlay
                    ? AppColors.playButtonGradient
                    : const LinearGradient(colors: [Color(0xFF4A4468), Color(0xFF322E4A)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: canPlay
                    ? [
                        BoxShadow(
                          color: AppColors.accentPink.withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed: canPlay ? onPlay : onOpenStore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      canPlay ? Icons.play_arrow_rounded : Icons.favorite_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      canPlay ? 'PLAY LEVEL' : 'GET LIVES (Store)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (canPlay) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isUnlimitedLives ? 'INF ❤️' : '1 ❤️',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const Spacer(),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
