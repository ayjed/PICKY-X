import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'level_progress_service.dart';

class LeaderboardPlayer {
  final int rank;
  final String username;
  final String countryCode;
  final String countryFlag;
  final int totalStars;
  final int maxLevel;
  final int totalScore;
  final bool isMe;

  const LeaderboardPlayer({
    required this.rank,
    required this.username,
    required this.countryCode,
    required this.countryFlag,
    required this.totalStars,
    required this.maxLevel,
    required this.totalScore,
    this.isMe = false,
  });
}

class GameAchievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int xpReward;
  final int coinsReward;
  final bool isUnlocked;

  const GameAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.coinsReward,
    required this.isUnlocked,
  });
}

/// Service managing Global and National (Country-level) Leaderboards and GPGS Achievements.
class LeaderboardService extends ChangeNotifier {
  static const String keyPlayerName = 'pickyx_player_username';
  static const String keyPlayerCountry = 'pickyx_player_country_code';

  final SharedPreferences _prefs;
  final LevelProgressService progressService;
  final dynamic apiService; // Optional ApiService

  String _playerName = 'MemoryChampion';
  String _playerCountryCode = 'NG'; // Nigeria default, configurable
  List<LeaderboardPlayer>? _cachedOnlineGlobal;
  List<LeaderboardPlayer>? _cachedOnlineNational;

  LeaderboardService(this._prefs, this.progressService, [this.apiService]) {
    _playerName = _prefs.getString(keyPlayerName) ?? 'Player_${DateTime.now().millisecond % 1000}';
    _playerCountryCode = _prefs.getString(keyPlayerCountry) ?? 'NG';
    refreshOnlineLeaderboard();
  }

  static Future<LeaderboardService> init(LevelProgressService progress, [dynamic api]) async {
    final prefs = await SharedPreferences.getInstance();
    return LeaderboardService(prefs, progress, api);
  }

  String get playerName => _playerName;
  String get playerCountryCode => _playerCountryCode;

  /// Trigger asynchronous background refresh from live XAMPP API
  Future<void> refreshOnlineLeaderboard() async {
    if (apiService == null) return;
    try {
      final globalData = await apiService.fetchGlobalLeaderboard();
      if (globalData != null && globalData['leaderboard'] is List) {
        final list = (globalData['leaderboard'] as List).map<LeaderboardPlayer>((item) {
          final m = item as Map<String, dynamic>;
          return LeaderboardPlayer(
            rank: (m['rank'] as num?)?.toInt() ?? 1,
            username: (m['username'] as String?) ?? 'Player',
            countryCode: (m['country_code'] as String?) ?? 'NG',
            countryFlag: (m['country_flag'] as String?) ?? '🌍',
            totalStars: (m['total_stars'] as num?)?.toInt() ?? 0,
            maxLevel: (m['max_level'] as num?)?.toInt() ?? 1,
            totalScore: (m['total_score'] as num?)?.toInt() ?? 0,
            isMe: (m['is_me'] as bool?) ?? false,
          );
        }).toList();
        _cachedOnlineGlobal = list;
      }

      final nationalData = await apiService.fetchCountryLeaderboard(_playerCountryCode);
      if (nationalData != null && nationalData['leaderboard'] is List) {
        final list = (nationalData['leaderboard'] as List).map<LeaderboardPlayer>((item) {
          final m = item as Map<String, dynamic>;
          return LeaderboardPlayer(
            rank: (m['rank'] as num?)?.toInt() ?? 1,
            username: (m['username'] as String?) ?? 'Player',
            countryCode: (m['country_code'] as String?) ?? 'NG',
            countryFlag: (m['country_flag'] as String?) ?? '🌍',
            totalStars: (m['total_stars'] as num?)?.toInt() ?? 0,
            maxLevel: (m['max_level'] as num?)?.toInt() ?? 1,
            totalScore: (m['total_score'] as num?)?.toInt() ?? 0,
            isMe: (m['is_me'] as bool?) ?? false,
          );
        }).toList();
        _cachedOnlineNational = list;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> updateProfile({required String name, required String countryCode}) async {
    _playerName = name;
    _playerCountryCode = countryCode;
    await _prefs.setString(keyPlayerName, name);
    await _prefs.setString(keyPlayerCountry, countryCode);
    if (apiService != null) {
      await apiService.login(username: name, countryCode: countryCode);
    }
    await refreshOnlineLeaderboard();
    notifyListeners();
  }

  /// Global Leaderboard (Worldwide)
  List<LeaderboardPlayer> getGlobalLeaderboard() {
    if (_cachedOnlineGlobal != null && _cachedOnlineGlobal!.isNotEmpty) {
      return _cachedOnlineGlobal!;
    }
    final myStars = progressService.totalStarsEarned;
    final myLevel = progressService.unlockedLevel;

    final List<LeaderboardPlayer> players = [
      const LeaderboardPlayer(rank: 1, username: 'AeroNinja', countryCode: 'US', countryFlag: '🇺🇸', totalStars: 178, maxLevel: 60, totalScore: 98450),
      const LeaderboardPlayer(rank: 2, username: 'Kofi_King', countryCode: 'GH', countryFlag: '🇬🇭', totalStars: 172, maxLevel: 58, totalScore: 94200),
      const LeaderboardPlayer(rank: 3, username: 'ChukaVortex', countryCode: 'NG', countryFlag: '🇳🇬', totalStars: 165, maxLevel: 55, totalScore: 89100),
      const LeaderboardPlayer(rank: 4, username: 'SakuraMatch', countryCode: 'JP', countryFlag: '🇯🇵', totalStars: 154, maxLevel: 52, totalScore: 83400),
      const LeaderboardPlayer(rank: 5, username: 'LondonBrain', countryCode: 'GB', countryFlag: '🇬🇧', totalStars: 148, maxLevel: 50, totalScore: 79200),
      LeaderboardPlayer(
        rank: 6,
        username: '$_playerName (You)',
        countryCode: _playerCountryCode,
        countryFlag: _getFlagForCode(_playerCountryCode),
        totalStars: myStars,
        maxLevel: myLevel,
        totalScore: myStars * 1200 + (myLevel * 500),
        isMe: true,
      ),
      const LeaderboardPlayer(rank: 7, username: 'PixelMaster', countryCode: 'DE', countryFlag: '🇩🇪', totalStars: 135, maxLevel: 45, totalScore: 72000),
      const LeaderboardPlayer(rank: 8, username: 'CyberRider', countryCode: 'CA', countryFlag: '🇨🇦', totalStars: 120, maxLevel: 40, totalScore: 65000),
    ];

    players.sort((a, b) => b.totalStars.compareTo(a.totalStars));
    return List.generate(players.length, (i) {
      final p = players[i];
      return LeaderboardPlayer(
        rank: i + 1,
        username: p.username,
        countryCode: p.countryCode,
        countryFlag: p.countryFlag,
        totalStars: p.totalStars,
        maxLevel: p.maxLevel,
        totalScore: p.totalScore,
        isMe: p.isMe,
      );
    });
  }

  /// National Leaderboard (Filtered by country)
  List<LeaderboardPlayer> getNationalLeaderboard() {
    if (_cachedOnlineNational != null && _cachedOnlineNational!.isNotEmpty) {
      return _cachedOnlineNational!;
    }
    final myStars = progressService.totalStarsEarned;
    final myLevel = progressService.unlockedLevel;
    final flag = _getFlagForCode(_playerCountryCode);

    final List<LeaderboardPlayer> list = [
      LeaderboardPlayer(rank: 1, username: 'ChukaVortex', countryCode: _playerCountryCode, countryFlag: flag, totalStars: 165, maxLevel: 55, totalScore: 89100),
      LeaderboardPlayer(
        rank: 2,
        username: '$_playerName (You)',
        countryCode: _playerCountryCode,
        countryFlag: flag,
        totalStars: myStars,
        maxLevel: myLevel,
        totalScore: myStars * 1200 + (myLevel * 500),
        isMe: true,
      ),
      LeaderboardPlayer(rank: 3, username: 'Zainab_X', countryCode: _playerCountryCode, countryFlag: flag, totalStars: 112, maxLevel: 38, totalScore: 59000),
      LeaderboardPlayer(rank: 4, username: 'Emeka_Flash', countryCode: _playerCountryCode, countryFlag: flag, totalStars: 95, maxLevel: 32, totalScore: 48000),
      LeaderboardPlayer(rank: 5, username: 'Tunde_Memory', countryCode: _playerCountryCode, countryFlag: flag, totalStars: 78, maxLevel: 26, totalScore: 39000),
    ];

    list.sort((a, b) => b.totalStars.compareTo(a.totalStars));
    return List.generate(list.length, (i) {
      final p = list[i];
      return LeaderboardPlayer(
        rank: i + 1,
        username: p.username,
        countryCode: p.countryCode,
        countryFlag: p.countryFlag,
        totalStars: p.totalStars,
        maxLevel: p.maxLevel,
        totalScore: p.totalScore,
        isMe: p.isMe,
      );
    });
  }

  /// GPGS Achievements list
  List<GameAchievement> getAchievements() {
    final unlocked = progressService.unlockedLevel;
    final stars = progressService.totalStarsEarned;

    return [
      GameAchievement(
        id: 'ach_first_win',
        title: 'First Step',
        description: 'Complete Level 1 of the Campaign Saga',
        icon: '🎯',
        xpReward: 500,
        coinsReward: 50,
        isUnlocked: unlocked > 1,
      ),
      GameAchievement(
        id: 'ach_world_1',
        title: 'Neon Plains Master',
        description: 'Conquer World 1 (Clear Level 12)',
        icon: '🌿',
        xpReward: 2000,
        coinsReward: 150,
        isUnlocked: unlocked > 12,
      ),
      GameAchievement(
        id: 'ach_stars_30',
        title: 'Star Collector',
        description: 'Collect 30 Stars across the campaign',
        icon: '⭐',
        xpReward: 3000,
        coinsReward: 200,
        isUnlocked: stars >= 30,
      ),
      GameAchievement(
        id: 'ach_world_2',
        title: 'Cyber City Champion',
        description: 'Conquer World 2 (Clear Level 24)',
        icon: '🏙️',
        xpReward: 5000,
        coinsReward: 300,
        isUnlocked: unlocked > 24,
      ),
      GameAchievement(
        id: 'ach_stars_100',
        title: 'Centurion of Memory',
        description: 'Collect 100 Stars across the campaign',
        icon: '👑',
        xpReward: 10000,
        coinsReward: 500,
        isUnlocked: stars >= 100,
      ),
    ];
  }

  String _getFlagForCode(String code) {
    switch (code.toUpperCase()) {
      case 'NG':
        return '🇳🇬';
      case 'US':
        return '🇺🇸';
      case 'GB':
        return '🇬🇧';
      case 'CA':
        return '🇨🇦';
      case 'GH':
        return '🇬🇭';
      case 'IN':
        return '🇮🇳';
      case 'DE':
        return '🇩🇪';
      case 'JP':
        return '🇯🇵';
      default:
        return '🌍';
    }
  }
}
