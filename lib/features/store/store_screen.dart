import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/life_service.dart';
import '../../services/local_preferences_service.dart';
import '../../services/wallet_service.dart';

/// In-Game Store Screen for purchasing Lives, Boosters, Currency bundles, and VIP Pass.
class StoreScreen extends StatefulWidget {
  final LifeService lifeService;
  final WalletService walletService;
  final LocalPreferencesService prefsService;

  const StoreScreen({
    super.key,
    required this.lifeService,
    required this.walletService,
    required this.prefsService,
  });

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _buyLivesWithCoins() {
    if (widget.walletService.spendCoins(100)) {
      widget.lifeService.refillMaxLives();
      _showFeedbackSnackBar('❤️ Lives fully restored to 5!');
    } else {
      _showFeedbackSnackBar('❌ Not enough coins! Need 🪙 100.', isError: true);
    }
  }

  void _buyLivesWithGems() {
    if (widget.walletService.spendGems(20)) {
      widget.lifeService.refillMaxLives();
      _showFeedbackSnackBar('❤️ Lives fully restored to 5!');
    } else {
      _showFeedbackSnackBar('❌ Not enough gems! Need 💎 20.', isError: true);
    }
  }

  void _watchAdForLife() {
    // Phase 5 integration hook: awards +1 life
    widget.lifeService.addLives(1);
    _showFeedbackSnackBar('🎬 Ad Watched! +1 ❤️ Life restored!');
  }

  void _buyUnlimitedLivesPass() {
    if (widget.walletService.spendGems(50)) {
      widget.lifeService.grantUnlimitedLives(const Duration(hours: 2));
      _showFeedbackSnackBar('⚡ Unlimited Lives active for 2 Hours!');
    } else {
      _showFeedbackSnackBar('❌ Not enough gems! Need 💎 50.', isError: true);
    }
  }

  void _buyBooster(String key, String name, int cost, int count) {
    if (widget.walletService.spendCoins(cost)) {
      widget.walletService.addBooster(key, count);
      _showFeedbackSnackBar('✨ Purchased $count× $name!');
    } else {
      _showFeedbackSnackBar('❌ Not enough coins! Need 🪙 $cost.', isError: true);
    }
  }

  void _showFeedbackSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isError ? AppColors.accentPink : AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Store Header & Wallet Balance
              _buildStoreHeader(),

              // Store Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accentOrange,
                indicatorWeight: 3,
                labelColor: AppColors.accentYellow,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [
                  Tab(text: '❤️ LIVES', icon: Icon(Icons.favorite_rounded, size: 20)),
                  Tab(text: '⚡ BOOSTERS', icon: Icon(Icons.flash_on_rounded, size: 20)),
                  Tab(text: '👑 VIP PASS', icon: Icon(Icons.workspace_premium_rounded, size: 20)),
                ],
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLivesTab(),
                    _buildBoostersTab(),
                    _buildVipTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreHeader() {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.lifeService, widget.walletService]),
      builder: (context, _) {
        final coins = widget.walletService.coins;
        final gems = widget.walletService.gems;
        final lives = widget.lifeService.currentLives;
        final isUnlimited = widget.lifeService.isUnlimited;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.backgroundSurface,
            border: Border(bottom: BorderSide(color: AppColors.surfaceCardBorder)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Text(
                'Game Store',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),

              // Lives Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentPink.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_rounded, color: AppColors.accentPink, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      isUnlimited ? 'INF' : '$lives/5',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Coins Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceCardBorder),
                ),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      '$coins',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accentYellow),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Gems Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceCardBorder),
                ),
                child: Row(
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      '$gems',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accentCyan),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLivesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildStoreItemCard(
          iconWidget: const Icon(Icons.favorite_rounded, size: 40, color: AppColors.accentPink),
          title: 'Instant 5x Hearts Refill',
          description: 'Fully restores your energy back to maximum (5 Lives).',
          priceTag: '🪙 100 Coins',
          buttonColor: AppColors.accentOrange,
          onTap: _buyLivesWithCoins,
        ),
        const SizedBox(height: 14),
        _buildStoreItemCard(
          iconWidget: const Icon(Icons.bolt_rounded, size: 40, color: AppColors.accentCyan),
          title: 'Emergency Gems Refill',
          description: 'Instantly restore all 5 lives using gems.',
          priceTag: '💎 20 Gems',
          buttonColor: AppColors.primaryPurple,
          onTap: _buyLivesWithGems,
        ),
        const SizedBox(height: 14),
        _buildStoreItemCard(
          iconWidget: const Icon(Icons.all_inclusive_rounded, size: 40, color: AppColors.accentYellow),
          title: '2-Hour Unlimited Lives Pass',
          description: 'Play as many levels as you want without losing any lives for 2 full hours!',
          priceTag: '💎 50 Gems',
          buttonColor: AppColors.accentGreen,
          onTap: _buyUnlimitedLivesPass,
        ),
        const SizedBox(height: 14),
        _buildStoreItemCard(
          iconWidget: const Icon(Icons.play_circle_fill_rounded, size: 40, color: AppColors.accentGreen),
          title: 'Free +1 Life (Watch Ad)',
          description: 'Watch a short sponsored video to restore 1 life immediately.',
          priceTag: 'FREE (Ad)',
          buttonColor: const Color(0xFF2E7D32),
          onTap: _watchAdForLife,
        ),
      ],
    );
  }

  Widget _buildBoostersTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildStoreItemCard(
          iconWidget: const Text('👁️', style: TextStyle(fontSize: 34)),
          title: 'Peek Booster (3-Pack)',
          description: 'Reveals all hidden cards for 2.5 seconds during a level.',
          priceTag: '🪙 60 Coins',
          buttonColor: AppColors.primaryPurple,
          onTap: () => _buyBooster('peek', 'Peek Booster', 60, 3),
        ),
        const SizedBox(height: 14),
        _buildStoreItemCard(
          iconWidget: const Text('❄️', style: TextStyle(fontSize: 34)),
          title: 'Freeze / +3 Moves (3-Pack)',
          description: 'Adds +3 bonus moves instantly to beat difficult levels.',
          priceTag: '🪙 60 Coins',
          buttonColor: AppColors.accentCyan,
          onTap: () => _buyBooster('freeze', 'Freeze Booster', 60, 3),
        ),
        const SizedBox(height: 14),
        _buildStoreItemCard(
          iconWidget: const Text('🪄', style: TextStyle(fontSize: 34)),
          title: 'Magic Wand (2-Pack)',
          description: 'Instantly matches and removes 1 random pair from the board.',
          priceTag: '🪙 90 Coins',
          buttonColor: AppColors.accentPink,
          onTap: () => _buyBooster('wand', 'Magic Wand', 90, 2),
        ),
        const SizedBox(height: 14),
        _buildStoreItemCard(
          iconWidget: const Text('🔀', style: TextStyle(fontSize: 34)),
          title: 'Shuffle Booster (3-Pack)',
          description: 'Reshuffles remaining unmatched cards without wasting moves.',
          priceTag: '🪙 50 Coins',
          buttonColor: AppColors.accentYellow,
          onTap: () => _buyBooster('shuffle', 'Shuffle Booster', 50, 3),
        ),
      ],
    );
  }

  Widget _buildVipTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4A148C), Color(0xFF1A237E)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.accentYellow, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentYellow.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.workspace_premium_rounded, size: 60, color: AppColors.accentYellow),
              const SizedBox(height: 12),
              const Text(
                'PICKY X VIP PASS',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentYellow,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'The Ultimate Memory Master Experience',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              _buildVipBenefit(Icons.all_inclusive_rounded, 'Unlimited Lives (Never wait for timer)'),
              _buildVipBenefit(Icons.block_rounded, '100% Ad-Free Gameplay'),
              _buildVipBenefit(Icons.monetization_on_rounded, '2X Coins from All Completed Levels'),
              _buildVipBenefit(Icons.card_membership_rounded, 'Exclusive VIP Gold Card Theme'),
              _buildVipBenefit(Icons.card_giftcard_rounded, 'Daily 100 Bonus Coins + 2 Gems'),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 54,
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
                  onPressed: () {
                    _showFeedbackSnackBar('👑 VIP Club Subscription activates via Google Play Billing in Phase 4!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'JOIN VIP PASS - \$3.99 / Month',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVipBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.accentGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreItemCard({
    required Widget iconWidget,
    required String title,
    required String description,
    required String priceTag,
    required Color buttonColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceCardBorder),
            ),
            child: Center(child: iconWidget),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    priceTag,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
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
