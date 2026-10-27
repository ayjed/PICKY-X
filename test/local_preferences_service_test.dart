import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:picky_x/services/local_preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalPreferencesService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    service = await LocalPreferencesService.init();
  });

  group('LocalPreferencesService Tests', () {
    test('Sound is enabled by default and persists updates', () async {
      expect(service.isSoundEnabled, true);

      await service.setSoundEnabled(false);
      expect(service.isSoundEnabled, false);

      await service.setSoundEnabled(true);
      expect(service.isSoundEnabled, true);
    });

    test('Initial completed game sets initial best records', () async {
      expect(service.bestMoves, isNull);
      expect(service.bestTimeSeconds, isNull);

      final result = await service.recordGameResult(moves: 12, timeSeconds: 45);

      expect(result.isNewBestMoves, true);
      expect(result.isNewBestTime, true);
      expect(service.bestMoves, 12);
      expect(service.bestTimeSeconds, 45);
    });

    test('Lower moves update bestMoves; higher moves do not', () async {
      await service.recordGameResult(moves: 15, timeSeconds: 50);
      expect(service.bestMoves, 15);

      // Slower moves attempt (18 moves) -> should NOT update bestMoves
      final worseMovesResult = await service.recordGameResult(moves: 18, timeSeconds: 30);
      expect(worseMovesResult.isNewBestMoves, false);
      expect(service.bestMoves, 15);

      // Better moves attempt (10 moves) -> SHOULD update bestMoves
      final betterMovesResult = await service.recordGameResult(moves: 10, timeSeconds: 60);
      expect(betterMovesResult.isNewBestMoves, true);
      expect(service.bestMoves, 10);
    });

    test('Faster time updates bestTimeSeconds; slower time does not', () async {
      await service.recordGameResult(moves: 15, timeSeconds: 60);
      expect(service.bestTimeSeconds, 60);

      // Slower time (75s) -> should NOT update bestTimeSeconds
      final worseTimeResult = await service.recordGameResult(moves: 8, timeSeconds: 75);
      expect(worseTimeResult.isNewBestTime, false);
      expect(service.bestTimeSeconds, 60);

      // Faster time (40s) -> SHOULD update bestTimeSeconds
      final betterTimeResult = await service.recordGameResult(moves: 20, timeSeconds: 40);
      expect(betterTimeResult.isNewBestTime, true);
      expect(service.bestTimeSeconds, 40);
    });

    test('Moves and Time records update independently', () async {
      await service.recordGameResult(moves: 14, timeSeconds: 50);

      // New game: Better moves (12), but worse time (60)
      final result1 = await service.recordGameResult(moves: 12, timeSeconds: 60);
      expect(result1.isNewBestMoves, true);
      expect(result1.isNewBestTime, false);
      expect(service.bestMoves, 12);
      expect(service.bestTimeSeconds, 50);

      // New game: Worse moves (15), but better time (35)
      final result2 = await service.recordGameResult(moves: 15, timeSeconds: 35);
      expect(result2.isNewBestMoves, false);
      expect(result2.isNewBestTime, true);
      expect(service.bestMoves, 12);
      expect(service.bestTimeSeconds, 35);
    });

    test('clearScores removes best moves and best time', () async {
      await service.recordGameResult(moves: 10, timeSeconds: 30);
      expect(service.bestMoves, 10);
      expect(service.bestTimeSeconds, 30);

      await service.clearScores();
      expect(service.bestMoves, isNull);
      expect(service.bestTimeSeconds, isNull);
    });
  });
}
