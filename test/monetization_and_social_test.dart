import 'package:flutter_test/flutter_test.dart';
import 'package:picky_x/features/retention/daily_reward_service.dart';
import 'package:picky_x/features/retention/piggy_bank_service.dart';
import 'package:picky_x/services/ad_service.dart';
import 'package:picky_x/services/iap_service.dart';
import 'package:picky_x/services/leaderboard_service.dart';
import 'package:picky_x/services/level_progress_service.dart';
import 'package:picky_x/services/life_service.dart';
import 'package:picky_x/services/wallet_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IapService Tests', () {
    test('Catalog contains consumable packs, permanent remove ads, and VIP Pass', () {
      expect(IapService.catalog.length, greaterThanOrEqualTo(6));
      expect(IapService.catalog.any((p) => p.id == 'vip_pass_monthly' && p.isSubscription), true);
      expect(IapService.catalog.any((p) => p.id == 'remove_ads_permanent' && !p.isConsumable), true);
    });

    test('Purchasing VIP Pass activates VIP status and grants unlimited lives', () async {
      SharedPreferences.setMockInitialValues({});
      final wallet = await WalletService.init();
      final lives = await LifeService.init();
      final iap = await IapService.init();

      expect(iap.isVipActive, false);
      expect(lives.isUnlimited, false);

      final success = await iap.purchaseProduct('vip_pass_monthly', wallet, lives);
      expect(success, true);
      expect(iap.isVipActive, true);
      expect(lives.isUnlimited, true);
    });
  });

  group('AdService Tests', () {
    test('Rewarded video executes onUserEarnedReward callback', () async {
      SharedPreferences.setMockInitialValues({});
      final iap = await IapService.init();
      final adService = AdService(iapService: iap);

      bool rewardClaimed = false;
      await adService.showRewardedVideo(
        onUserEarnedReward: () => rewardClaimed = true,
      );

      expect(rewardClaimed, true);
    });

    test('Ads are suppressed when user has VIP Pass or Remove Ads', () async {
      SharedPreferences.setMockInitialValues({
        IapService.keyVipActive: true,
      });
      final iap = await IapService.init();
      final adService = AdService(iapService: iap);

      expect(adService.shouldShowAds, false);
    });
  });

  group('DailyReward & PiggyBank Tests', () {
    test('Claiming daily reward updates streak and awards currency', () async {
      SharedPreferences.setMockInitialValues({});
      final wallet = await WalletService.init();
      final lives = await LifeService.init();
      final daily = await DailyRewardService.init();

      expect(daily.isRewardAvailableToday(), true);
      final item = daily.claimTodayReward(wallet, lives);

      expect(item, isNotNull);
      expect(item!.coins, 50);
      expect(wallet.coins, 150); // 100 starter + 50 reward
      expect(daily.isRewardAvailableToday(), false);
    });

    test('Piggy bank deposits coins on level win and can be broken open', () async {
      SharedPreferences.setMockInitialValues({});
      final wallet = await WalletService.init();
      final piggy = await PiggyBankService.init();

      expect(piggy.piggyCoins, 0);
      piggy.recordLevelWinDeposit();
      expect(piggy.piggyCoins, 30);

      final broken = piggy.breakPiggyBank(wallet);
      expect(broken, 30);
      expect(piggy.piggyCoins, 0);
      expect(wallet.coins, 130);
    });
  });

  group('LeaderboardService Tests', () {
    test('Provides ranked list for Global and National leaderboards', () async {
      SharedPreferences.setMockInitialValues({});
      final progress = await LevelProgressService.init();
      final leaderboard = await LeaderboardService.init(progress);

      final globalList = leaderboard.getGlobalLeaderboard();
      expect(globalList.length, greaterThanOrEqualTo(5));
      expect(globalList.any((p) => p.isMe), true);

      final nationalList = leaderboard.getNationalLeaderboard();
      expect(nationalList.length, greaterThanOrEqualTo(3));
      expect(nationalList.every((p) => p.countryCode == leaderboard.playerCountryCode), true);
    });

    test('Achievements track unlock condition based on campaign progress', () async {
      SharedPreferences.setMockInitialValues({});
      final progress = await LevelProgressService.init();
      final leaderboard = await LeaderboardService.init(progress);

      final achList = leaderboard.getAchievements();
      expect(achList.length, 5);
      expect(achList.first.isUnlocked, false);

      // Complete level 1
      await progress.recordLevelCompletion(levelId: 1, stars: 3, score: 1200);

      final updatedAchList = leaderboard.getAchievements();
      expect(updatedAchList.first.isUnlocked, true);
    });
  });
}
