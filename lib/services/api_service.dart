import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Client REST API Service for Picky X Backend (PHP 8 + MySQL on XAMPP).
class ApiService extends ChangeNotifier {
  static const String keyDeviceId = 'pickyx_api_device_id';
  static const String keyAuthToken = 'pickyx_api_auth_token';
  static const String keyCustomBaseUrl = 'pickyx_api_base_url';

  // Configured default LAN server IP for Android APK & physical device testing
  static const String defaultLanServerUrl = 'http://192.168.18.6/pickyx_api/';

  // Default to localhost for desktop/unit tests, LAN IP for Android APK
  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost/pickyx_api/';
    if (Platform.isAndroid) return defaultLanServerUrl;
    return 'http://localhost/pickyx_api/';
  }

  final SharedPreferences _prefs;
  late String _baseUrl;
  late String _deviceId;
  String? _authToken;
  bool _isOnline = false;

  ApiService(this._prefs) {
    _baseUrl = _prefs.getString(keyCustomBaseUrl) ?? defaultBaseUrl;
    _authToken = _prefs.getString(keyAuthToken);
    
    // Load or generate unique device ID
    var devId = _prefs.getString(keyDeviceId);
    if (devId == null || devId.isEmpty) {
      devId = 'dev_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (DateTime.now().microsecond % 9000))}';
      _prefs.setString(keyDeviceId, devId);
    }
    _deviceId = devId;
  }

  static Future<ApiService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return ApiService(prefs);
  }

  String get baseUrl => _baseUrl;
  String get deviceId => _deviceId;
  String? get authToken => _authToken;
  bool get isOnline => _isOnline;

  /// Test server connectivity
  Future<bool> ping() async {
    final res = await _sendRequest(
      path: 'api/leaderboard/global.php',
      method: 'GET',
    );
    return res != null && res['success'] == true;
  }

  Future<void> setBaseUrl(String newUrl) async {
    _baseUrl = newUrl.endsWith('/') ? newUrl : '$newUrl/';
    await _prefs.setString(keyCustomBaseUrl, _baseUrl);
    notifyListeners();
  }

  /// Helper to send HTTP requests using standard dart:io HttpClient
  Future<Map<String, dynamic>?> _sendRequest({
    required String path,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uriString = '$_baseUrl$path';
      var uri = Uri.parse(uriString);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);

      HttpClientRequest request;
      if (method == 'POST') {
        request = await client.postUrl(uri);
      } else {
        request = await client.getUrl(uri);
      }

      request.headers.set('Content-Type', 'application/json');
      request.headers.set('X-Device-Id', _deviceId);
      if (_authToken != null && _authToken!.isNotEmpty) {
        request.headers.set('X-Auth-Token', _authToken!);
      }

      if (body != null) {
        final jsonStr = jsonEncode(body);
        request.write(jsonStr);
      }

      final response = await request.close().timeout(const Duration(seconds: 4));
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _isOnline = true;
        final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
        notifyListeners();
        return decoded;
      } else {
        _isOnline = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isOnline = false;
      notifyListeners();
      return null;
    }
  }

  /// 1. Login / Register with backend
  Future<Map<String, dynamic>?> login({String? username, String? countryCode}) async {
    final res = await _sendRequest(
      path: 'api/auth/login.php',
      method: 'POST',
      body: {
        'device_id': _deviceId,
        if (username != null) 'username': username,
        if (countryCode != null) 'country_code': countryCode,
      },
    );

    if (res != null && res['success'] == true && res['data'] != null) {
      final data = res['data'] as Map<String, dynamic>;
      final token = data['auth_token'] as String?;
      if (token != null) {
        _authToken = token;
        await _prefs.setString(keyAuthToken, token);
      }
      return data;
    }
    return null;
  }

  /// 2. Fetch Global Leaderboard
  Future<Map<String, dynamic>?> fetchGlobalLeaderboard() async {
    final res = await _sendRequest(
      path: 'api/leaderboard/global.php',
      method: 'GET',
    );
    if (res != null && res['success'] == true) {
      return res['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// 3. Fetch Country Leaderboard
  Future<Map<String, dynamic>?> fetchCountryLeaderboard(String countryCode) async {
    final res = await _sendRequest(
      path: 'api/leaderboard/country.php',
      method: 'GET',
      queryParams: {'country_code': countryCode},
    );
    if (res != null && res['success'] == true) {
      return res['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// 4. Submit Level Victory & Score to backend
  Future<Map<String, dynamic>?> submitScore({
    required int levelNumber,
    required int stars,
    required int score,
    int coinsEarned = 0,
    int gemsEarned = 0,
  }) async {
    final res = await _sendRequest(
      path: 'api/leaderboard/submit_score.php',
      method: 'POST',
      body: {
        'level_number': levelNumber,
        'stars': stars,
        'score': score,
        'coins_earned': coinsEarned,
        'gems_earned': gemsEarned,
      },
    );
    if (res != null && res['success'] == true) {
      return res['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// 5. Full Cloud Save Sync
  Future<Map<String, dynamic>?> syncProgress({
    required Map<String, dynamic> wallet,
    required List<Map<String, dynamic>> levels,
    required Map<String, dynamic> energy,
  }) async {
    final res = await _sendRequest(
      path: 'api/sync/save_progress.php',
      method: 'POST',
      body: {
        'wallet': wallet,
        'levels': levels,
        'energy': energy,
      },
    );
    if (res != null && res['success'] == true) {
      return res['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// 6. Energy / Life Server Sync
  Future<Map<String, dynamic>?> syncLives({String action = 'check', int hours = 2}) async {
    final res = await _sendRequest(
      path: 'api/energy/sync_lives.php',
      method: 'POST',
      body: {
        'action': action,
        'hours': hours,
      },
    );
    if (res != null && res['success'] == true) {
      return res['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// 7. Daily Reward Check / Claim
  Future<Map<String, dynamic>?> checkDailyReward({bool claim = false}) async {
    final res = await _sendRequest(
      path: 'api/retention/daily_reward.php',
      method: 'POST',
      body: {
        'action': claim ? 'claim' : 'check',
      },
    );
    if (res != null && res['success'] == true) {
      return res['data'] as Map<String, dynamic>?;
    }
    return null;
  }
}
