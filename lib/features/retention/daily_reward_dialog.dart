import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/life_service.dart';
import '../../services/wallet_service.dart';
import 'daily_reward_service.dart';

/// Modal dialog displaying the 7-day Daily Login streak reward calendar.
class DailyRewardDialog extends StatefulWidget {
  final DailyRewardService dailyRewardService;
  final WalletService walletService;
  final LifeService lifeService;

  const DailyRewardDialog({
    super.key,
    required this.dailyRewardService,
    required this.walletService,
    required this.lifeService,
  });

  @override
  State<DailyRewardDialog> createState() => _DailyRewardDialogState();
}

class _DailyRewardDialogState extends State<DailyRewardDialog> {
  DailyRewardItem? _claimedReward;

  void _claim() {
    final reward = widget.dailyRewardService.claimTodayReward(
      widget.walletService,
      widget.lifeService,
    );

    if (reward != null) {
      setState(() {
        _claimedReward = reward;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStreak = widget.dailyRewardService.currentStreak;
    final isAvailable = widget.dailyRewardService.isRewardAvailableToday();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.accentYellow, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentYellow.withOpacity(0.35),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                const Text(
                  'DAILY LOGIN REWARDS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accentYellow,
                    letterSpacing: 0.8,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 7-Day Grid of Rewards
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: DailyRewardService.rewardsCalendar.length,
              itemBuilder: (context, index) {
                final item = DailyRewardService.rewardsCalendar[index];
                final isToday = item.day == currentStreak;
                final isPast = item.day < currentStreak;
                final isDay7 = item.day == 7;

                return Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.primaryPurple.withOpacity(0.6)
                        : isPast
                            ? const Color(0xFF232038)
                            : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isToday
                          ? AppColors.accentYellow
                          : isPast
                              ? AppColors.accentGreen.withOpacity(0.5)
                              : AppColors.surfaceCardBorder,
                      width: isToday ? 2.0 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Day ${item.day}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isToday ? AppColors.accentYellow : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isDay7
                            ? '👑'
                            : item.gems > 0
                                ? '💎'
                                : item.boosterKey != null
                                    ? '⚡'
                                    : '🪙',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+${item.coins}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      if (isPast)
                        const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 14),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Claimed Feedback or Action Button
            if (_claimedReward != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accentGreen),
                ),
                child: Text(
                  '🎉 Claimed Day ${_claimedReward!.day} Reward! (+${_claimedReward!.coins} 🪙)',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentGreen, fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Awesome!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: isAvailable
                      ? AppColors.playButtonGradient
                      : const LinearGradient(colors: [Color(0xFF4A4468), Color(0xFF322E4A)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isAvailable
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
                  onPressed: isAvailable ? _claim : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    isAvailable ? 'CLAIM REWARD 🎁' : 'CLAIMED FOR TODAY (Come Back Tomorrow)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
