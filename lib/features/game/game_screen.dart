import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../services/audio_service.dart';
import '../../services/level_progress_service.dart';
import '../../services/life_service.dart';
import '../../services/local_preferences_service.dart';
import '../../services/wallet_service.dart';
import '../campaign/data/level_catalog.dart';
import '../campaign/models/level_model.dart';
import '../result/result_screen.dart';
import 'controllers/game_controller.dart';
import 'widgets/game_stats.dart';
import 'widgets/level_failed_dialog.dart';
import 'widgets/level_victory_dialog.dart';
import 'widgets/memory_card.dart';
import 'widgets/out_of_moves_dialog.dart';

class GameScreen extends StatefulWidget {
  final LocalPreferencesService prefsService;
  final LevelProgressService? progressService;
  final LifeService? lifeService;
  final WalletService? walletService;
  final LevelModel? level;

  const GameScreen({
    super.key,
    required this.prefsService,
    this.progressService,
    this.lifeService,
    this.walletService,
    this.level,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _controller;
  late final AudioService _audioService;
  bool _dialogActive = false;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService(widget.prefsService);

    _controller = GameController(
      level: widget.level,
      onFlip: _audioService.playFlip,
      onMatch: _audioService.playMatch,
      onMismatch: _audioService.playMismatch,
      onWin: _onGameWin,
      onOutOfMoves: _onOutOfMoves,
      onTimeUp: _onTimeUp,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onOutOfMoves() {
    if (!mounted || _dialogActive) return;
    _dialogActive = true;

    final coins = widget.walletService?.coins ?? 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => OutOfMovesDialog(
        coinsBalance: coins,
        onBuyMovesWithCoins: () {
          Navigator.of(ctx).pop();
          _dialogActive = false;
          if (widget.walletService?.spendCoins(50) ?? false) {
            _controller.addExtraMoves(5);
          }
        },
        onWatchAdForMoves: () {
          Navigator.of(ctx).pop();
          _dialogActive = false;
          // Phase 5 AdMob hook
          _controller.addExtraMoves(5);
        },
        onGiveUp: () {
          Navigator.of(ctx).pop();
          _dialogActive = false;
          _showLevelFailed();
        },
      ),
    );
  }

  void _onTimeUp() {
    if (!mounted || _dialogActive) return;
    _showLevelFailed();
  }

  void _showLevelFailed() {
    _dialogActive = true;
    final remainingLives = widget.lifeService?.currentLives ?? 0;
    final timerText = widget.lifeService?.formattedTimer ?? 'FULL';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LevelFailedDialog(
        levelId: widget.level?.id ?? 1,
        remainingLives: remainingLives,
        lifeTimerText: timerText,
        onRetry: () {
          Navigator.of(ctx).pop();
          _dialogActive = false;
          if (widget.lifeService?.consumeLife() ?? true) {
            _controller.resetGame();
          } else {
            Navigator.of(context).pop();
          }
        },
        onReturnToMap: () {
          Navigator.of(ctx).pop();
          _dialogActive = false;
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _onGameWin() async {
    await _audioService.playWin();
    if (!mounted) return;

    if (widget.level != null && widget.progressService != null) {
      // Campaign Level Mode Victory
      final lvl = widget.level!;
      final movesLeft = _controller.movesRemaining;
      final stars = lvl.calculateStars(movesLeft);
      final score = 1000 + (movesLeft * 100) - (_controller.elapsedSeconds * 5);

      await widget.progressService!.recordLevelCompletion(
        levelId: lvl.id,
        stars: stars,
        score: score,
      );

      final earnedCoins = lvl.rewardCoins;
      final earnedGems = lvl.rewardGems;
      widget.walletService?.addCoins(earnedCoins);
      widget.walletService?.addGems(earnedGems);

      if (!mounted) return;
      _dialogActive = true;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => LevelVictoryDialog(
          levelId: lvl.id,
          stars: stars,
          score: score,
          movesRemaining: movesLeft,
          earnedCoins: earnedCoins,
          earnedGems: earnedGems,
          onDoubleCoinsWithAd: () {
            // Phase 5: Double rewards with AdMob
            widget.walletService?.addCoins(earnedCoins);
            Navigator.of(ctx).pop();
            _dialogActive = false;
            _proceedToNextLevel(lvl.id);
          },
          onNextLevel: () {
            Navigator.of(ctx).pop();
            _dialogActive = false;
            _proceedToNextLevel(lvl.id);
          },
          onReturnToMap: () {
            Navigator.of(ctx).pop();
            _dialogActive = false;
            Navigator.of(context).pop();
          },
        ),
      );
    } else {
      // Classic Arcade Mode
      final result = await widget.prefsService.recordGameResult(
        moves: _controller.moves,
        timeSeconds: _controller.elapsedSeconds,
      );

      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            moves: _controller.moves,
            elapsedSeconds: _controller.elapsedSeconds,
            bestMoves: widget.prefsService.bestMoves,
            bestTimeSeconds: widget.prefsService.bestTimeSeconds,
            isNewBestMoves: result.isNewBestMoves,
            isNewBestTime: result.isNewBestTime,
            prefsService: widget.prefsService,
          ),
        ),
      );
    }
  }

  void _proceedToNextLevel(int currentLevelId) {
    if (currentLevelId < 60) {
      final nextLevel = LevelCatalog.getLevel(currentLevelId + 1);
      if (widget.lifeService?.canPlay() ?? true) {
        widget.lifeService?.consumeLife();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => GameScreen(
              prefsService: widget.prefsService,
              progressService: widget.progressService,
              lifeService: widget.lifeService,
              walletService: widget.walletService,
              level: nextLevel,
            ),
          ),
        );
      } else {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  void _useBooster(String key) {
    final wallet = widget.walletService;
    if (wallet == null) return;

    if (wallet.getBoosterCount(key) > 0) {
      if (wallet.useBooster(key)) {
        switch (key) {
          case 'peek':
            _controller.applyPeekBooster();
            break;
          case 'freeze':
            _controller.applyFreezeBooster();
            break;
          case 'wand':
            _controller.applyWandBooster();
            break;
          case 'shuffle':
            _controller.applyShuffleBooster();
            break;
        }
      }
    } else {
      // Prompt buy booster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No $key boosters left! Visit store to buy more.'),
          backgroundColor: AppColors.accentPink,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cols = widget.level?.gridCols ?? 4;
    final rows = widget.level?.gridRows ?? 4;
    final isCampaign = widget.level != null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              final state = _controller.state;

              return Column(
                children: [
                  // Top Navigation Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Back',
                        ),
                        Text(
                          isCampaign ? 'Level ${widget.level!.id}' : AppStrings.appName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: AppColors.accentYellow, size: 28),
                          onPressed: _controller.resetGame,
                          tooltip: AppStrings.restart,
                        ),
                      ],
                    ),
                  ),

                  // HUD Stats Row (Moves remaining & Pairs)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: GameStats(
                      moves: isCampaign ? state.movesRemaining : state.moves,
                      isMovesRemainingMode: isCampaign,
                      isLowOnMoves: state.isLowOnMoves,
                      matchedPairs: state.matchedPairs,
                      totalPairs: state.totalPairs,
                      elapsedSeconds: state.elapsedSeconds,
                      timeLimitSeconds: state.timeLimitSeconds,
                    ),
                  ),

                  // Dynamic Puzzle Grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: cols / rows,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: state.deck.length,
                            itemBuilder: (context, index) {
                              final card = state.deck[index];
                              return MemoryCard(
                                card: card,
                                index: index,
                                onTap: () => _controller.handleCardTap(index),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // In-Game Booster Dock (Bottom Bar)
                  if (widget.walletService != null)
                    _buildBoosterDock(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBoosterDock() {
    return ListenableBuilder(
      listenable: widget.walletService!,
      builder: (context, _) {
        final peekCount = widget.walletService!.peekBoosters;
        final freezeCount = widget.walletService!.freezeBoosters;
        final wandCount = widget.walletService!.wandBoosters;
        final shuffleCount = widget.walletService!.shuffleBoosters;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceCardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBoosterItem('👁️', 'Peek', peekCount, () => _useBooster('peek')),
              _buildBoosterItem('❄️', '+Moves', freezeCount, () => _useBooster('freeze')),
              _buildBoosterItem('🪄', 'Wand', wandCount, () => _useBooster('wand')),
              _buildBoosterItem('🔀', 'Shuffle', shuffleCount, () => _useBooster('shuffle')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoosterItem(String iconEmoji, String label, int count, VoidCallback onTap) {
    final hasStock = count > 0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: hasStock ? AppColors.surfaceCard : const Color(0xFF232038),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasStock ? AppColors.primaryPurpleLight : AppColors.surfaceCardBorder,
                  ),
                ),
                child: Center(
                  child: Text(iconEmoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: hasStock ? AppColors.accentPink : AppColors.textMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    hasStock ? '$count' : '+',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: hasStock ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
