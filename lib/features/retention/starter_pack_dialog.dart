import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/life_service.dart';
import '../../services/wallet_service.dart';

/// Limited-time high-conversion Starter Pack promotion modal.
class StarterPackDialog extends StatelessWidget {
  final WalletService walletService;
  final LifeService lifeService;
  final VoidCallback onPurchase;

  const StarterPackDialog({
    super.key,
    required this.walletService,
    required this.lifeService,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.accentPink, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPink.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Limited Offer Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentPink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '⚡ SPECIAL 80% OFF STARTER PACK ⚡',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
            const SizedBox(height: 14),

            const Text(
              'MASTER BUNDLE',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.accentYellow,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Supercharge your memory journey with this one-time mega pack!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),

            // Itemized Contents Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.surfaceCardBorder),
              ),
              child: Column(
                children: [
                  _buildItemRow('🪙 500 Gold Coins', 'Massive wealth'),
                  _buildItemRow('💎 25 Shiny Gems', 'Premium unlocks'),
                  _buildItemRow('👁️ 2x Peek Boosters', 'Reveal all cards'),
                  _buildItemRow('❄️ 2x Freeze Boosters', '+3 Extra moves'),
                  _buildItemRow('🪄 2x Magic Wands', 'Instant pair match'),
                  _buildItemRow('❤️ 2-Hour Unlimited Lives', 'Infinite plays'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Purchase Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.playButtonGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPink.withOpacity(0.5),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'GET BUNDLE - \$0.99',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '(\$4.99 Value)',
                      style: TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No thanks, maybe later', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
          const Spacer(),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.accentCyan)),
        ],
      ),
    );
  }
}
