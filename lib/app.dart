import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/retention/daily_reward_service.dart';
import 'features/retention/piggy_bank_service.dart';
import 'services/ad_service.dart';
import 'services/api_service.dart';
import 'services/iap_service.dart';
import 'services/leaderboard_service.dart';
import 'services/level_progress_service.dart';
import 'services/life_service.dart';
import 'services/local_preferences_service.dart';
import 'services/wallet_service.dart';

class PickyXApp extends StatelessWidget {
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

  const PickyXApp({
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeScreen(
        prefsService: prefsService,
        lifeService: lifeService,
        walletService: walletService,
        progressService: progressService,
        dailyRewardService: dailyRewardService,
        piggyBankService: piggyBankService,
        iapService: iapService,
        adService: adService,
        leaderboardService: leaderboardService,
        apiService: apiService,
      ),
    );
  }
}
