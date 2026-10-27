import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/level_progress_service.dart';
import '../../services/life_service.dart';
import '../../services/local_preferences_service.dart';
import '../../services/wallet_service.dart';
import '../game/game_screen.dart';
import '../store/store_screen.dart';
import 'data/level_catalog.dart';
import 'models/level_model.dart';
import 'widgets/level_node_widget.dart';
import 'widgets/level_preview_dialog.dart';

/// Scrollable Saga Campaign World Map featuring 60 levels, live energy countdown, and currency HUD.
class SagaMapScreen extends StatefulWidget {
  final LocalPreferencesService prefsService;
  final LevelProgressService progressService;
  final LifeService lifeService;
  final WalletService walletService;

  const SagaMapScreen({
    super.key,
    required this.prefsService,
    required this.progressService,
    required this.lifeService,
    required this.walletService,
  });

  @override
  State<SagaMapScreen> createState() => _SagaMapScreenState();
}

class _SagaMapScreenState extends State<SagaMapScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentLevel();
    });
  }

  void _scrollToCurrentLevel() {
    final unlocked = widget.progressService.unlockedLevel;
    // Each level item takes ~95 pixels height
    final targetOffset = ((unlocked - 1) * 95.0).clamp(0.0, _scrollController.position.maxScrollExtent);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onSelectLevel(LevelModel level) {
    final stars = widget.progressService.getStarsForLevel(level.id);

    showDialog(
      context: context,
      builder: (ctx) => LevelPreviewDialog(
        level: level,
        currentStars: stars,
        currentLives: widget.lifeService.currentLives,
        isUnlimitedLives: widget.lifeService.isUnlimited,
        onPlay: () {
          Navigator.of(ctx).pop();
          _startLevel(level);
        },
        onOpenStore: () {
          Navigator.of(ctx).pop();
          _openStore();
        },
      ),
    );
  }

  void _startLevel(LevelModel level) {
    if (!widget.lifeService.canPlay()) {
      _openStore();
      return;
    }

    // Consume 1 life
    widget.lifeService.consumeLife();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          prefsService: widget.prefsService,
          progressService: widget.progressService,
          lifeService: widget.lifeService,
          walletService: widget.walletService,
          level: level,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
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
              // Top Bar with Energy & Currencies
              _buildTopBar(),

              // Saga Map Path
              Expanded(
                child: ListenableBuilder(
                  listenable: Listenable.merge([widget.progressService, widget.lifeService, widget.walletService]),
                  builder: (context, _) {
                    final unlockedLevel = widget.progressService.unlockedLevel;

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      itemCount: LevelCatalog.levels.length,
                      itemBuilder: (context, index) {
                        final level = LevelCatalog.levels[index];
                        final isUnlocked = widget.progressService.isLevelUnlocked(level.id);
                        final isCurrent = level.id == unlockedLevel;
                        final stars = widget.progressService.getStarsForLevel(level.id);

                        // Calculate curved horizontal alignment for winding path effect
                        final curvePattern = [0.0, 0.5, 1.0, 0.5, 0.0, -0.5, -1.0, -0.5];
                        final alignmentX = curvePattern[index % curvePattern.length];

                        return Column(
                          children: [
                            // World Header Banner on the first level of each world
                            if (index == 0 || LevelCatalog.levels[index - 1].worldNumber != level.worldNumber)
                              _buildWorldHeader(level.worldNumber, level.worldName),

                            // Level Node with horizontal alignment
                            Align(
                              alignment: Alignment(alignmentX * 0.7, 0),
                              child: LevelNodeWidget(
                                level: level,
                                isUnlocked: isUnlocked,
                                isCurrent: isCurrent,
                                stars: stars,
                                onTap: () => _onSelectLevel(level),
                              ),
                            ),
                          ],
                        );
                      },
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            border: const Border(bottom: BorderSide(color: AppColors.surfaceCardBorder)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Main Menu',
              ),

              // Lives Counter & Timer Badge
              GestureDetector(
                onTap: _openStore,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accentPink.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: AppColors.accentPink, size: 20),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUnlimited ? 'INF' : '$lives/5',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                          ),
                          Text(
                            timerText,
                            style: const TextStyle(fontSize: 10, color: AppColors.accentYellow, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Coins Badge
              GestureDetector(
                onTap: _openStore,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceCardBorder),
                  ),
                  child: Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        '$coins',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accentYellow),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Gems Badge
              GestureDetector(
                onTap: _openStore,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceCardBorder),
                  ),
                  child: Row(
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        '$gems',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accentCyan),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Store Button
              IconButton(
                icon: const Icon(Icons.shopping_bag_rounded, color: AppColors.accentOrange, size: 26),
                onPressed: _openStore,
                tooltip: 'Store',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorldHeader(int worldNumber, String worldName) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple.withOpacity(0.6),
            AppColors.backgroundSurface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryPurpleLight.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.explore_rounded, color: AppColors.accentCyan, size: 20),
          const SizedBox(width: 8),
          Text(
            'WORLD $worldNumber: ${worldName.toUpperCase()}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
