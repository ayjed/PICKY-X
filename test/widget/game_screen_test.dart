import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:picky_x/core/constants/app_strings.dart';
import 'package:picky_x/features/game/game_screen.dart';
import 'package:picky_x/features/game/widgets/game_stats.dart';
import 'package:picky_x/features/game/widgets/memory_card.dart';
import 'package:picky_x/services/local_preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalPreferencesService prefsService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefsService = await LocalPreferencesService.init();
  });

  Widget createTestableGameScreen() {
    return MaterialApp(
      home: GameScreen(prefsService: prefsService),
    );
  }

  group('GameScreen Widget Tests', () {
    testWidgets('Renders top HUD stats and 16 memory cards', (tester) async {
      await tester.pumpWidget(createTestableGameScreen());

      expect(find.byType(GameStats), findsOneWidget);
      expect(find.text(AppStrings.moves), findsOneWidget);
      expect(find.text(AppStrings.pairs), findsOneWidget);
      expect(find.text('0/8'), findsOneWidget);

      // Verify all 16 memory card widgets exist
      expect(find.byType(MemoryCard), findsNWidgets(16));
    });

    testWidgets('Tapping first card initiates flip', (tester) async {
      await tester.pumpWidget(createTestableGameScreen());

      final firstCardFinder = find.byType(MemoryCard).first;
      await tester.tap(firstCardFinder);
      await tester.pumpAndSettle();

      // Semantics should indicate revealed
      expect(find.bySemanticsLabel(RegExp(r'Revealed')), findsOneWidget);
    });

    testWidgets('Restart button resets HUD stats and regenerates board', (tester) async {
      await tester.pumpWidget(createTestableGameScreen());

      // Tap card 0 and card 1
      await tester.tap(find.byType(MemoryCard).at(0));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byType(MemoryCard).at(1));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1'), findsOneWidget); // 1 move

      // Tap restart
      final restartBtn = find.byTooltip(AppStrings.restart);
      expect(restartBtn, findsOneWidget);
      await tester.tap(restartBtn);
      await tester.pumpAndSettle();

      // Metrics should be reset to 0
      expect(find.text('0/8'), findsOneWidget);
    });
  });
}
