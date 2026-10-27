import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/level_model.dart';

/// Interactive Level Node on the Candy Crush-style Saga Level Map.
class LevelNodeWidget extends StatelessWidget {
  final LevelModel level;
  final bool isUnlocked;
  final bool isCurrent;
  final int stars;
  final VoidCallback onTap;

  const LevelNodeWidget({
    super.key,
    required this.level,
    required this.isUnlocked,
    required this.isCurrent,
    required this.stars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current Pin Indicator (Bouncing animation or beacon)
          if (isCurrent)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accentPink,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPink.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Text(
                'HERE',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            )
          else
            const SizedBox(height: 18),

          // Main Level Node Circle
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isCurrent
                  ? AppColors.playButtonGradient
                  : isUnlocked
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primaryPurpleLight, AppColors.primaryPurple],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF322E4A), Color(0xFF221F36)],
                        ),
              border: Border.all(
                color: isCurrent
                    ? AppColors.accentYellow
                    : isUnlocked
                        ? AppColors.primaryPurpleLight
                        : AppColors.surfaceCardBorder,
                width: isCurrent ? 3.0 : 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isCurrent
                      ? AppColors.accentPink.withOpacity(0.6)
                      : isUnlocked
                          ? AppColors.primaryPurple.withOpacity(0.4)
                          : Colors.black.withOpacity(0.2),
                  blurRadius: isCurrent ? 14 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: isUnlocked
                  ? Text(
                      '${level.id}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isCurrent ? Colors.white : AppColors.textPrimary,
                        shadows: const [
                          Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                        ],
                      ),
                    )
                  : const Icon(
                      Icons.lock_rounded,
                      size: 24,
                      color: AppColors.textMuted,
                    ),
            ),
          ),
          const SizedBox(height: 4),

          // Stars Rating Bar (for completed levels)
          if (isUnlocked && stars > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final isFilled = stars > index;
                return Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 14,
                  color: isFilled ? AppColors.accentYellow : AppColors.textMuted.withOpacity(0.4),
                );
              }),
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }
}
