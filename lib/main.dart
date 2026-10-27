import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure edge-to-edge system window overlays
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock to portrait orientation for consistent mobile experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Pre-warm core services
  final prefsService = await LocalPreferencesService.init();
  final lifeService = await LifeService.init();
  final walletService = await WalletService.init();
  final progressService = await LevelProgressService.init();
  final dailyRewardService = await DailyRewardService.init();
  final piggyBankService = await PiggyBankService.init();
  final iapService = await IapService.init();
  final adService = AdService(iapService: iapService);
  final apiService = await ApiService.init();
  final leaderboardService = await LeaderboardService.init(progressService, apiService);

  runApp(PickyXApp(
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
  ));
}
