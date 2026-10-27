import 'package:flutter_test/flutter_test.dart';
import 'package:picky_x/features/campaign/data/level_catalog.dart';
import 'package:picky_x/services/level_progress_service.dart';
import 'package:picky_x/services/life_service.dart';
import 'package:picky_x/services/wallet_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LevelCatalog Tests', () {
    test('Catalog contains 60 progressive campaign levels across 5 worlds', () {
      expect(LevelCatalog.levels.length, 60);

      // Verify World distribution (12 levels per world)
      for (int w = 1; w <= 5; w++) {
        final worldLevels = LevelCatalog.getLevelsForWorld(w);
        expect(worldLevels.length, 12);
      }
    });

    test('Early levels have small grids and generous moves', () {
      final lvl1 = LevelCatalog.getLevel(1);
      expect(lvl1.gridRows, 2);
      expect(lvl1.gridCols, 3);
      expect(lvl1.totalPairs, 3);
      expect(lvl1.maxMoves, 8);

      final lvl4 = LevelCatalog.getLevel(4);
      expect(lvl4.gridRows, 2);
      expect(lvl4.gridCols, 4);
      expect(lvl4.totalPairs, 4);
    });

    test('Star calculation logic awards 1, 2, or 3 stars based on moves left', () {
      final lvl = LevelCatalog.getLevel(10); // World 1 Level 10
      expect(lvl.calculateStars(lvl.star3MinMovesRemaining), 3);
      expect(lvl.calculateStars(lvl.star2MinMovesRemaining), 2);
      expect(lvl.calculateStars(0), 1);
    });
  });

  group('LifeService Tests', () {
    test('Default starts with 5 max lives', () async {
      SharedPreferences.setMockInitialValues({});
      final lifeService = await LifeService.init();

      expect(lifeService.currentLives, 5);
      expect(lifeService.isFull, true);
      expect(lifeService.canPlay(), true);
      expect(lifeService.formattedTimer, 'FULL');
    });

    test('Consuming life decrements count and starts regen timer', () async {
      SharedPreferences.setMockInitialValues({});
      final lifeService = await LifeService.init();

      final consumed = lifeService.consumeLife();
      expect(consumed, true);
      expect(lifeService.currentLives, 4);
      expect(lifeService.isFull, false);
      expect(lifeService.secondsUntilNextLife, greaterThan(0));
    });

    test('Unlimited lives pass allows infinite plays without decrementing lives', () async {
      SharedPreferences.setMockInitialValues({});
      final lifeService = await LifeService.init();

      lifeService.grantUnlimitedLives(const Duration(hours: 2));
      expect(lifeService.isUnlimited, true);

      final consumed = lifeService.consumeLife();
      expect(consumed, true);
      expect(lifeService.currentLives, 5); // Count remains 5
    });
  });

  group('WalletService Tests', () {
    test('Initializes with default starter bonus coins and gems', () async {
      SharedPreferences.setMockInitialValues({});
      final wallet = await WalletService.init();

      expect(wallet.coins, 100);
      expect(wallet.gems, 10);
      expect(wallet.peekBoosters, 2);
      expect(wallet.freezeBoosters, 2);
    });

    test('Adding and spending coins updates balance accurately', () async {
      SharedPreferences.setMockInitialValues({});
      final wallet = await WalletService.init();

      wallet.addCoins(50);
      expect(wallet.coins, 150);

      final spent = wallet.spendCoins(60);
      expect(spent, true);
      expect(wallet.coins, 90);

      final failedSpend = wallet.spendCoins(200);
      expect(failedSpend, false);
      expect(wallet.coins, 90);
    });

    test('Using boosters decrements booster inventory', () async {
      SharedPreferences.setMockInitialValues({});
      final wallet = await WalletService.init();

      expect(wallet.getBoosterCount('peek'), 2);
      final used = wallet.useBooster('peek');
      expect(used, true);
      expect(wallet.getBoosterCount('peek'), 1);
    });
  });

  group('LevelProgressService Tests', () {
    test('Starts at Level 1 with 0 stars', () async {
      SharedPreferences.setMockInitialValues({});
      final progress = await LevelProgressService.init();

      expect(progress.unlockedLevel, 1);
      expect(progress.totalStarsEarned, 0);
      expect(progress.isLevelUnlocked(1), true);
      expect(progress.isLevelUnlocked(2), false);
    });

    test('Completing level unlocks next level and saves stars', () async {
      SharedPreferences.setMockInitialValues({});
      final progress = await LevelProgressService.init();

      final result = await progress.recordLevelCompletion(levelId: 1, stars: 3, score: 1450);

      expect(result.isNewStarRecord, true);
      expect(result.isNextLevelUnlocked, true);
      expect(progress.unlockedLevel, 2);
      expect(progress.getStarsForLevel(1), 3);
      expect(progress.totalStarsEarned, 3);
      expect(progress.isLevelUnlocked(2), true);
    });
  });
}
