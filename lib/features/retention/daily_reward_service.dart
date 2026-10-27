import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/life_service.dart';
import '../../services/wallet_service.dart';

class DailyRewardItem {
  final int day;
  final int coins;
  final int gems;
  final String? boosterKey;
  final int boosterCount;
  final bool isFullLifeRefill;

  const DailyRewardItem({
    required this.day,
    this.coins = 0,
    this.gems = 0,
    this.boosterKey,
    this.boosterCount = 0,
    this.isFullLifeRefill = false,
  });
}

/// Service managing the 7-day escalating Daily Login streak calendar.
class DailyRewardService extends ChangeNotifier {
  static const String keyLastClaimDate = 'pickyx_last_claim_date';
  static const String keyStreakDay = 'pickyx_daily_streak_day';

  final SharedPreferences _prefs;

  static const List<DailyRewardItem> rewardsCalendar = [
    DailyRewardItem(day: 1, coins: 50),
    DailyRewardItem(day: 2, coins: 80, boosterKey: 'peek', boosterCount: 1),
    DailyRewardItem(day: 3, coins: 100, gems: 2),
    DailyRewardItem(day: 4, coins: 120, boosterKey: 'freeze', boosterCount: 1),
    DailyRewardItem(day: 5, coins: 150, boosterKey: 'wand', boosterCount: 1),
    DailyRewardItem(day: 6, coins: 200, gems: 5, isFullLifeRefill: true),
    DailyRewardItem(day: 7, coins: 500, gems: 15, boosterKey: 'wand', boosterCount: 2),
  ];

  DailyRewardService(this._prefs);

  static Future<DailyRewardService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return DailyRewardService(prefs);
  }

  int get currentStreak => _prefs.getInt(keyStreakDay) ?? 1;

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _getYesterdayString() {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return '${y.year}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}';
  }

  /// Checks if a reward is ready to be claimed today
  bool isRewardAvailableToday() {
    final lastClaim = _prefs.getString(keyLastClaimDate);
    if (lastClaim == null) return true;
    return lastClaim != _getTodayString();
  }

  /// Claims today's reward, applies items to wallet/lives, advances streak, and persists.
  DailyRewardItem? claimTodayReward(WalletService wallet, LifeService lives) {
    if (!isRewardAvailableToday()) return null;

    final lastClaim = _prefs.getString(keyLastClaimDate);
    final yesterday = _getYesterdayString();

    int streak = currentStreak;
    if (lastClaim == yesterday) {
      // Continuing streak
      streak = (streak % 7) + 1;
    } else if (lastClaim != null) {
      // Streak broken -> reset to day 1
      streak = 1;
    }

    final reward = rewardsCalendar[streak - 1];

    if (reward.coins > 0) wallet.addCoins(reward.coins);
    if (reward.gems > 0) wallet.addGems(reward.gems);
    if (reward.boosterKey != null && reward.boosterCount > 0) {
      wallet.addBooster(reward.boosterKey!, reward.boosterCount);
    }
    if (reward.isFullLifeRefill) {
      lives.refillMaxLives();
    }

    _prefs.setString(keyLastClaimDate, _getTodayString());
    _prefs.setInt(keyStreakDay, streak);
    notifyListeners();

    return reward;
  }
}
