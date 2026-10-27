import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:picky_x/services/api_service.dart';
import 'package:picky_x/services/level_progress_service.dart';
import 'package:picky_x/services/leaderboard_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late ApiService apiService;
  late LevelProgressService progressService;
  late LeaderboardService leaderboardService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      ApiService.keyDeviceId: 'mock_test_device_42',
      ApiService.keyCustomBaseUrl: 'http://localhost/pickyx_api/',
    });
    prefs = await SharedPreferences.getInstance();
    apiService = ApiService(prefs);
    progressService = LevelProgressService(prefs);
    leaderboardService = LeaderboardService(prefs, progressService, apiService);
  });

  group('ApiService & Cloud Backend Tests', () {
    test('ApiService initializes with correct device ID and base URL', () {
      expect(apiService.deviceId, 'mock_test_device_42');
      expect(apiService.baseUrl, 'http://localhost/pickyx_api/');
      expect(apiService.authToken, isNull);
    });

    test('Custom base URL updates properly', () async {
      await apiService.setBaseUrl('http://192.168.1.100/pickyx_api');
      expect(apiService.baseUrl, 'http://192.168.1.100/pickyx_api/');
    });

    test('LeaderboardService handles API integration gracefully offline/online', () {
      final global = leaderboardService.getGlobalLeaderboard();
      expect(global, isNotEmpty);
      expect(global.first.rank, 1);

      final national = leaderboardService.getNationalLeaderboard();
      expect(national, isNotEmpty);
      expect(national.first.countryCode, 'NG');
    });

    test('Profile updates trigger local and API updates', () async {
      await leaderboardService.updateProfile(name: 'GoldMatch', countryCode: 'US');
      expect(leaderboardService.playerName, 'GoldMatch');
      expect(leaderboardService.playerCountryCode, 'US');
      expect(prefs.getString(LeaderboardService.keyPlayerName), 'GoldMatch');
      expect(prefs.getString(LeaderboardService.keyPlayerCountry), 'US');
    });
  });
}
