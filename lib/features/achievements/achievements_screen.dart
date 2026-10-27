import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/leaderboard_service.dart';

/// Screen displaying Google Play Games Services Achievements and XP Rewards.
class AchievementsScreen extends StatelessWidget {
  final LeaderboardService leaderboardService;

  const AchievementsScreen({
    super.key,
    required this.leaderboardService,
  });

  @override
  Widget build(BuildContext context) {
    final achievements = leaderboardService.getAchievements();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Achievements & Badges',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Achievements List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final ach = achievements[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ach.isUnlocked
                            ? AppColors.surfaceCard
                            : const Color(0xFF201D33),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: ach.isUnlocked
                              ? AppColors.accentYellow.withOpacity(0.6)
                              : AppColors.surfaceCardBorder,
                          width: ach.isUnlocked ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          if (ach.isUnlocked)
                            BoxShadow(
                              color: AppColors.accentYellow.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Achievement Icon Badge
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ach.isUnlocked
                                  ? AppColors.primaryPurple.withOpacity(0.5)
                                  : Colors.black26,
                              border: Border.all(
                                color: ach.isUnlocked ? AppColors.accentYellow : AppColors.textMuted,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                ach.icon,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: ach.isUnlocked ? null : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Title & Description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ach.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: ach.isUnlocked ? Colors.white : AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  ach.description,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      '+${ach.xpReward} XP',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentCyan),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '+${ach.coinsReward} 🪙',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentYellow),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Status Icon
                          Icon(
                            ach.isUnlocked ? Icons.verified_rounded : Icons.lock_rounded,
                            color: ach.isUnlocked ? AppColors.accentGreen : AppColors.textMuted,
                            size: 24,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
