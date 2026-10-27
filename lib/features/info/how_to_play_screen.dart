import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.instructionsTitle),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              _buildStepCard(
                icon: Icons.touch_app_rounded,
                title: 'Step 1: Flip',
                description: AppStrings.step1,
                color: AppColors.primaryPurpleLight,
              ),
              const SizedBox(height: 14),
              _buildStepCard(
                icon: Icons.filter_2_rounded,
                title: 'Step 2: Match',
                description: AppStrings.step2,
                color: AppColors.accentCyan,
              ),
              const SizedBox(height: 14),
              _buildStepCard(
                icon: Icons.check_circle_outline_rounded,
                title: 'Step 3: Keep Pairs',
                description: AppStrings.step3,
                color: AppColors.accentGreen,
              ),
              const SizedBox(height: 14),
              _buildStepCard(
                icon: Icons.psychology_rounded,
                title: 'Step 4: Memorize',
                description: AppStrings.step4,
                color: AppColors.accentYellow,
              ),
              const SizedBox(height: 14),
              _buildStepCard(
                icon: Icons.military_tech_rounded,
                title: 'Step 5: Win',
                description: AppStrings.step5,
                color: AppColors.accentPink,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Got it, let’s play!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
