import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../services/ad_service.dart';
import '../../services/api_service.dart';
import '../../services/iap_service.dart';
import '../../services/leaderboard_service.dart';
import '../../services/level_progress_service.dart';
import '../../services/life_service.dart';
import '../../services/local_preferences_service.dart';
import '../../services/wallet_service.dart';
import '../achievements/achievements_screen.dart';
import '../campaign/data/level_catalog.dart';
import '../campaign/saga_map_screen.dart';
import '../game/game_screen.dart';
import '../info/how_to_play_screen.dart';
import '../info/privacy_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../retention/daily_reward_dialog.dart';
import '../retention/daily_reward_service.dart';
import '../retention/lucky_wheel_dialog.dart';
import '../retention/piggy_bank_service.dart';
import '../retention/starter_pack_dialog.dart';
import '../store/store_screen.dart';

/// Main Menu Screen displaying Energy HUD, Retention Live-Ops, Campaign, Leaderboards, and Arcade mode.
class HomeScreen extends StatefulWidget {
  final LocalPreferencesService prefsService;
  final LifeService lifeService;
  final WalletService walletService;
  final LevelProgressService progressService;
  final DailyRewardService dailyRewardService;
  final PiggyBankService piggyBankService;
  final IapService iapService;
  final AdService adService;
  final LeaderboardService leaderboardService;
  final ApiService? apiService;

  const HomeScreen({
    super.key,
    required this.prefsService,
    required this.lifeService,
    required this.walletService,
    required this.progressService,
    required this.dailyRewardService,
    required this.piggyBankService,
    required this.iapService,
    required this.adService,
    required this.leaderboardService,
    this.apiService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _soundEnabled;

  @override
  void initState() {
    super.initState();
    _soundEnabled = widget.prefsService.isSoundEnabled;

    // Show daily reward automatically if ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.dailyRewardService.isRewardAvailableToday()) {
        _openDailyRewards();
      }
    });
  }

  void _toggleSound() async {
    final updated = !_soundEnabled;
    await widget.prefsService.setSoundEnabled(updated);
    setState(() {
      _soundEnabled = updated;
    });
  }

  void _openStore() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoreScreen(
          lifeService: widget.lifeService,
          walletService: widget.walletService,
          prefsService: widget.prefsService,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openSagaMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SagaMapScreen(
          prefsService: widget.prefsService,
          progressService: widget.progressService,
          lifeService: widget.lifeService,
          walletService: widget.walletService,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openLeaderboards() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LeaderboardScreen(
          leaderboardService: widget.leaderboardService,
        ),
      ),
    );
  }

  void _openCloudServerModal() {
    final api = widget.apiService;
    if (api == null) return;

    final urlCtrl = TextEditingController(text: api.baseUrl);
    String pingResult = '';
    bool isPinging = false;
    bool isSyncing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.cloud_sync_rounded, color: AppColors.accentCyan, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Cloud & Backend Server',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Device ID: ${api.deviceId}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  const Text('Backend Server URL:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: urlCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceCard,
                      hintText: 'http://192.168.18.6/pickyx_api/',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.surfaceCardBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Quick Server Presets
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      ActionChip(
                        label: const Text('Wi-Fi LAN (192.168.18.6)', style: TextStyle(fontSize: 11)),
                        backgroundColor: AppColors.surfaceCard,
                        onPressed: () {
                          urlCtrl.text = 'http://192.168.18.6/pickyx_api/';
                          setModalState(() {});
                        },
                      ),
                      ActionChip(
                        label: const Text('Emulator (10.0.2.2)', style: TextStyle(fontSize: 11)),
                        backgroundColor: AppColors.surfaceCard,
                        onPressed: () {
                          urlCtrl.text = 'http://10.0.2.2/pickyx_api/';
                          setModalState(() {});
                        },
                      ),
                      ActionChip(
                        label: const Text('Localhost', style: TextStyle(fontSize: 11)),
                        backgroundColor: AppColors.surfaceCard,
                        onPressed: () {
                          urlCtrl.text = 'http://localhost/pickyx_api/';
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (pingResult.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: pingResult.contains('✔')
                            ? Colors.green.withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: pingResult.contains('✔') ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            pingResult.contains('✔') ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                            color: pingResult.contains('✔') ? Colors.green : Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pingResult,
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isPinging
                              ? null
                              : () async {
                                  setModalState(() {
                                    isPinging = true;
                                    pingResult = 'Connecting to server...';
                                  });
                                  await api.setBaseUrl(urlCtrl.text.trim());
                                  final success = await api.ping();
                                  setModalState(() {
                                    isPinging = false;
                                    if (success) {
                                      pingResult = '✔ Connected successfully to XAMPP MySQL Backend!';
                                      widget.leaderboardService.refreshOnlineLeaderboard();
                                    } else {
                                      pingResult = '✖ Cannot reach server. Verify XAMPP is running & IP is correct.';
                                    }
                                  });
                                },
                          icon: isPinging
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.network_ping_rounded, size: 16),
                          label: const Text('Test Connection'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentCyan,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isSyncing
                              ? null
                              : () async {
                                  setModalState(() {
                                    isSyncing = true;
                                  });
                                  await api.setBaseUrl(urlCtrl.text.trim());
                                  // Send snapshot
                                  final wallet = {
                                    'coins': widget.walletService.coins,
                                    'gems': widget.walletService.gems,
                                    'booster_peek': widget.walletService.peekBoosters,
                                    'booster_freeze': widget.walletService.freezeBoosters,
                                    'booster_wand': widget.walletService.wandBoosters,
                                    'booster_shuffle': widget.walletService.shuffleBoosters,
                                    'piggy_coins': widget.piggyBankService.piggyCoins,
                                  };
                                  final levels = <Map<String, dynamic>>[];
                                  for (int i = 1; i <= widget.progressService.unlockedLevel; i++) {
                                    levels.add({
                                      'level_number': i,
                                      'stars': widget.progressService.getStarsForLevel(i),
                                      'high_score': widget.progressService.getScoreForLevel(i),
                                      'is_completed': true,
                                    });
                                  }
                                  final energy = {'current_lives': widget.lifeService.currentLives};
                                  final res = await api.syncProgress(wallet: wallet, levels: levels, energy: energy);
                                  setModalState(() {
                                    isSyncing = false;
                                    if (res != null) {
                                      pingResult = '✔ Cloud Progress Synced! All stars & coins saved.';
                                    } else {
                                      pingResult = '✖ Sync failed. Please check connection.';
                                    }
                                  });
                                },
                          icon: isSyncing
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.cloud_upload_rounded, size: 16),
                          label: const Text('Sync Progress'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.surfaceCardBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openAchievements() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AchievementsScreen(
          leaderboardService: widget.leaderboardService,
        ),
      ),
    );
  }

  void _openArcadeMode() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(prefsService: widget.prefsService),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openDailyRewards() {
    showDialog(
      context: context,
      builder: (ctx) => DailyRewardDialog(
        dailyRewardService: widget.dailyRewardService,
        walletService: widget.walletService,
        lifeService: widget.lifeService,
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openLuckyWheel() {
    showDialog(
      context: context,
      builder: (ctx) => LuckyWheelDialog(
        walletService: widget.walletService,
        lifeService: widget.lifeService,
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openStarterPack() {
    showDialog(
      context: context,
      builder: (ctx) => StarterPackDialog(
        walletService: widget.walletService,
        lifeService: widget.lifeService,
        onPurchase: () {
          Navigator.of(ctx).pop();
          widget.iapService.purchaseProduct('starter_pack_special', widget.walletService, widget.lifeService);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('🎉 Starter Pack Claimed! Enjoy your bonuses!'),
              backgroundColor: AppColors.accentGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
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
              // Top Currency & Energy Bar
              _buildTopBar(),

              // Scrollable Menu Content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo
                        Hero(
                          tag: 'app_logo',
                          child: Image.asset(
                            AppAssets.appLogo,
                            width: 155,
                            height: 155,
                            errorBuilder: (context, error, stackTrace) => const Column(
                              children: [
                                Icon(Icons.style_rounded, size: 70, color: AppColors.accentOrange),
                                SizedBox(height: 8),
                                Text(
                                  AppStrings.appName,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          AppStrings.appTagline,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Retention Quick Actions (Daily Rewards, Lucky Spin, Starter Pack)
                        _buildRetentionQuickBar(),
                        const SizedBox(height: 14),

                        // Campaign Progression Status Card
                        _buildCampaignStatusCard(),
                        const SizedBox(height: 14),

                        // Play Campaign CTA (Primary Action)
                        Container(
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: AppColors.playButtonGradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentPink.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _openSagaMap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map_rounded, size: 28, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'CAMPAIGN SAGA',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Social Row: Leaderboards & Achievements
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: _openLeaderboards,
                                  icon: const Icon(Icons.leaderboard_rounded, color: AppColors.accentYellow, size: 20),
                                  label: const Text(
                                    'Leaderboard',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.surfaceCard,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: _openAchievements,
                                  icon: const Icon(Icons.emoji_events_rounded, color: AppColors.accentCyan, size: 20),
                                  label: const Text(
                                    'Achievements',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.surfaceCard,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Classic 4x4 Arcade Mode Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _openArcadeMode,
                            icon: const Icon(Icons.grid_view_rounded, color: AppColors.accentCyan, size: 20),
                            label: const Text(
                              'Classic 4×4 Arcade',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.surfaceCardBorder, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: AppColors.surfaceCard.withOpacity(0.4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Game Store Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _openStore,
                            icon: const Icon(Icons.shopping_bag_rounded, color: AppColors.accentOrange, size: 20),
                            label: const Text(
                              'Game Store (Lives & VIP)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.surfaceCardBorder, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: AppColors.surfaceCard.withOpacity(0.4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Secondary Options Row (How to play & Sound)
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => const HowToPlayScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.help_outline_rounded, size: 16, color: AppColors.textPrimary),
                                  label: const Text(
                                    'How to Play',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.surfaceCardBorder),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    backgroundColor: AppColors.surfaceCard.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: OutlinedButton.icon(
                                  onPressed: _toggleSound,
                                  icon: Icon(
                                    _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                                    size: 16,
                                    color: _soundEnabled ? AppColors.accentYellow : AppColors.textMuted,
                                  ),
                                  label: Text(
                                    _soundEnabled ? 'Sound ON' : 'Sound OFF',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _soundEnabled ? AppColors.textPrimary : AppColors.textMuted,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.surfaceCardBorder),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    backgroundColor: AppColors.surfaceCard.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Cloud Server Status & Sync Button
                        if (widget.apiService != null)
                          SizedBox(
                            height: 38,
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _openCloudServerModal,
                              icon: const Icon(Icons.cloud_sync_rounded, size: 16, color: AppColors.accentCyan),
                              label: const Text(
                                'Cloud Server & XAMPP Sync',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentCyan),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.accentCyan.withOpacity(0.4)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: AppColors.accentCyan.withOpacity(0.08),
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),

                        // Privacy / About Link
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const PrivacyScreen()),
                            );
                          },
                          icon: const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textMuted),
                          label: const Text(
                            AppStrings.privacyAndAbout,
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetentionQuickBar() {
    final hasDailyReward = widget.dailyRewardService.isRewardAvailableToday();

    return Row(
      children: [
        // Daily Login
        Expanded(
          child: GestureDetector(
            onTap: _openDailyRewards,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasDailyReward ? AppColors.accentYellow : AppColors.surfaceCardBorder,
                  width: hasDailyReward ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Text('🎁', style: TextStyle(fontSize: 20)),
                      if (hasDailyReward)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accentPink,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Text('Daily Gift', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Lucky Spin Wheel
        Expanded(
          child: GestureDetector(
            onTap: _openLuckyWheel,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.accentCyan.withOpacity(0.5)),
              ),
              child: const Column(
                children: [
                  Text('🎡', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 3),
                  Text('Lucky Spin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Starter Pack
        Expanded(
          child: GestureDetector(
            onTap: _openStarterPack,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.accentPink.withOpacity(0.6)),
              ),
              child: const Column(
                children: [
                  Text('⚡', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 3),
                  Text('80% Off Pack', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentPink)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.lifeService, widget.walletService]),
      builder: (context, _) {
        final lives = widget.lifeService.currentLives;
        final isUnlimited = widget.lifeService.isUnlimited;
        final timerText = widget.lifeService.formattedTimer;
        final coins = widget.walletService.coins;
        final gems = widget.walletService.gems;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.backgroundSurface,
            border: Border(bottom: BorderSide(color: AppColors.surfaceCardBorder)),
          ),
          child: Row(
            children: [
              // Lives Pill
              GestureDetector(
                onTap: _openStore,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accentPink.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: AppColors.accentPink, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        isUnlimited ? 'INF' : '$lives/5',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($timerText)',
                        style: const TextStyle(fontSize: 11, color: AppColors.accentYellow, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Coins Pill
              GestureDetector(
                onTap: _openStore,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceCardBorder),
                  ),
                  child: Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '$coins',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accentYellow),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Gems Pill
              GestureDetector(
                onTap: _openStore,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceCardBorder),
                  ),
                  child: Row(
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '$gems',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accentCyan),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCampaignStatusCard() {
    return ListenableBuilder(
      listenable: widget.progressService,
      builder: (context, _) {
        final unlocked = widget.progressService.unlockedLevel;
        final totalStars = widget.progressService.totalStarsEarned;
        final currentLvl = LevelCatalog.getLevel(unlocked);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primaryPurpleLight.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.playButtonGradient,
                ),
                child: Center(
                  child: Text(
                    '$unlocked',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level $unlocked • ${currentLvl.worldName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '⭐ $totalStars Stars Collected • 60 Levels',
                      style: const TextStyle(
                        color: AppColors.accentYellow,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
            ],
          ),
        );
      },
    );
  }
}
