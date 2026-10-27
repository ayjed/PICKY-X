import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

/// Top HUD widget displaying game metrics (Moves Left, Pairs, Time/Countdown).
class GameStats extends StatelessWidget {
  final int moves;
  final bool isMovesRemainingMode;
  final bool isLowOnMoves;
  final int matchedPairs;
  final int totalPairs;
  final int elapsedSeconds;
  final int? timeLimitSeconds;

  const GameStats({
    super.key,
    required this.moves,
    this.isMovesRemainingMode = false,
    this.isLowOnMoves = false,
    required this.matchedPairs,
    required this.totalPairs,
    required this.elapsedSeconds,
    this.timeLimitSeconds,
  });

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final movesLabel = isMovesRemainingMode ? 'Moves Left' : AppStrings.moves;
    final movesColor = isLowOnMoves ? AppColors.accentPink : AppColors.accentYellow;

    final timeLabel = timeLimitSeconds != null ? 'Time Left' : AppStrings.time;
    final timeValue = timeLimitSeconds != null
        ? _formatDuration((timeLimitSeconds! - elapsedSeconds).clamp(0, 999))
        : _formatDuration(elapsedSeconds);
    final timeColor = timeLimitSeconds != null && (timeLimitSeconds! - elapsedSeconds) <= 10
        ? AppColors.accentPink
        : AppColors.accentCyan;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isLowOnMoves ? AppColors.accentPink : AppColors.surfaceCardBorder),
        boxShadow: [
          BoxShadow(
            color: isLowOnMoves ? AppColors.accentPink.withOpacity(0.25) : Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(movesLabel, '$moves', movesColor, Icons.touch_app_rounded, isWarning: isLowOnMoves),
          Container(height: 32, width: 1.5, color: AppColors.surfaceCardBorder),
          _buildItem(AppStrings.pairs, '$matchedPairs/$totalPairs', AppColors.accentGreen, Icons.check_circle_rounded),
          Container(height: 32, width: 1.5, color: AppColors.surfaceCardBorder),
          _buildItem(timeLabel, timeValue, timeColor, Icons.timer_rounded),
        ],
      ),
    );
  }

  Widget _buildItem(String label, String value, Color color, IconData icon, {bool isWarning = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isWarning ? AppColors.accentPink : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
