import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picky_x/core/constants/app_strings.dart';
import 'package:picky_x/features/home/home_screen.dart';
import 'package:picky_x/features/info/how_to_play_screen.dart';
import 'package:picky_x/features/info/privacy_screen.dart';
import 'package:picky_x/features/retention/daily_reward_service.dart';
import 'package:picky_x/features/retention/piggy_bank_service.dart';
import 'package:picky_x/services/ad_service.dart';
import 'package:picky_x/services/iap_service.dart';
import 'package:picky_x/services/leaderboard_service.dart';
import 'package:picky_x/services/level_progress_service.dart';
import 'package:picky_x/services/life_service.dart';
import 'package:picky_x/services/local_preferences_service.dart';
import 'package:picky_x/services/wallet_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalPreferencesService prefsService;
  late LifeService lifeService;
  late WalletService walletService;
  late LevelProgressService progressService;
  late DailyRewardService dailyRewardService;
  late PiggyBankService piggyBankService;
  late IapService iapService;
  late AdService adService;
  late LeaderboardService leaderboardService;

  setUp(() async {
    // Set mock date to prevent auto-opening daily reward in general tests
    SharedPreferences.setMockInitialValues({
      DailyRewardService.keyLastClaimDate: '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
    });
    prefsService = await LocalPreferencesService.init();
    lifeService = await LifeService.init();
    walletService = await WalletService.init();
    progressService = await LevelProgressService.init();
    dailyRewardService = await DailyRewardService.init();
    piggyBankService = await PiggyBankService.init();
    iapService = await IapService.init();
    adService = AdService(iapService: iapService);
    leaderboardService = await LeaderboardService.init(progressService);
  });

  Widget createTestableHomeScreen() {
    return MaterialApp(
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
      ),
    );
  }

  group('HomeScreen Widget Tests', () {
    testWidgets('Renders Campaign Saga, Arcade, Store, Retention quick actions, and Sound toggle', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestableHomeScreen());

      expect(find.text('Daily Gift'), findsOneWidget);
      expect(find.text('Lucky Spin'), findsOneWidget);
      expect(find.text('80% Off Pack'), findsOneWidget);
      expect(find.text('CAMPAIGN SAGA'), findsOneWidget);
      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);
      expect(find.text('Classic 4×4 Arcade'), findsOneWidget);
      expect(find.text('How to Play'), findsOneWidget);
      expect(find.text('Sound ON'), findsOneWidget);
      expect(find.text(AppStrings.privacyAndAbout), findsOneWidget);
    });

    testWidgets('Tapping Sound button toggles state between ON and OFF', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestableHomeScreen());

      expect(find.text('Sound ON'), findsOneWidget);

      await tester.ensureVisible(find.text('Sound ON'));
      await tester.tap(find.text('Sound ON'));
      await tester.pumpAndSettle();

      expect(find.text('Sound OFF'), findsOneWidget);
      expect(prefsService.isSoundEnabled, false);

      await tester.tap(find.text('Sound OFF'));
      await tester.pumpAndSettle();

      expect(find.text('Sound ON'), findsOneWidget);
      expect(prefsService.isSoundEnabled, true);
    });

    testWidgets('Displays energy and currency HUD on top bar', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestableHomeScreen());

      expect(find.text('5/5'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('Navigates to HowToPlayScreen on secondary action tap', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestableHomeScreen());

      await tester.ensureVisible(find.text('How to Play'));
      await tester.tap(find.text('How to Play'));
      await tester.pumpAndSettle();

      expect(find.byType(HowToPlayScreen), findsOneWidget);
      expect(find.text(AppStrings.instructionsTitle), findsOneWidget);
    });

    testWidgets('Navigates to PrivacyScreen on privacy link tap', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestableHomeScreen());

      await tester.ensureVisible(find.text(AppStrings.privacyAndAbout));
      await tester.tap(find.text(AppStrings.privacyAndAbout));
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyScreen), findsOneWidget);
      expect(find.text(AppStrings.privacyTitle), findsOneWidget);
    });
  });
}
