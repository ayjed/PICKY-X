import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing virtual currencies (Coins 🪙 & Gems 💎) and Booster inventory.
class WalletService extends ChangeNotifier {
  static const String keyCoins = 'pickyx_coins_balance';
  static const String keyGems = 'pickyx_gems_balance';
  static const String keyBoosterPeek = 'pickyx_booster_peek';
  static const String keyBoosterFreeze = 'pickyx_booster_freeze';
  static const String keyBoosterWand = 'pickyx_booster_wand';
  static const String keyBoosterShuffle = 'pickyx_booster_shuffle';

  final SharedPreferences _prefs;

  int _coins = 100;
  int _gems = 10;
  int _peekBoosters = 2;
  int _freezeBoosters = 2;
  int _wandBoosters = 2;
  int _shuffleBoosters = 2;

  WalletService(this._prefs) {
    _loadState();
  }

  static Future<WalletService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return WalletService(prefs);
  }

  int get coins => _coins;
  int get gems => _gems;
  int get peekBoosters => _peekBoosters;
  int get freezeBoosters => _freezeBoosters;
  int get wandBoosters => _wandBoosters;
  int get shuffleBoosters => _shuffleBoosters;

  void _loadState() {
    _coins = _prefs.getInt(keyCoins) ?? 100; // Starter coins
    _gems = _prefs.getInt(keyGems) ?? 10;   // Starter gems
    _peekBoosters = _prefs.getInt(keyBoosterPeek) ?? 2;
    _freezeBoosters = _prefs.getInt(keyBoosterFreeze) ?? 2;
    _wandBoosters = _prefs.getInt(keyBoosterWand) ?? 2;
    _shuffleBoosters = _prefs.getInt(keyBoosterShuffle) ?? 2;
  }

  Future<void> _saveState() async {
    await _prefs.setInt(keyCoins, _coins);
    await _prefs.setInt(keyGems, _gems);
    await _prefs.setInt(keyBoosterPeek, _peekBoosters);
    await _prefs.setInt(keyBoosterFreeze, _freezeBoosters);
    await _prefs.setInt(keyBoosterWand, _wandBoosters);
    await _prefs.setInt(keyBoosterShuffle, _shuffleBoosters);
  }

  // --- Coins ---
  void addCoins(int amount) {
    if (amount <= 0) return;
    _coins += amount;
    _saveState();
    notifyListeners();
  }

  bool spendCoins(int amount) {
    if (amount <= 0 || _coins < amount) return false;
    _coins -= amount;
    _saveState();
    notifyListeners();
    return true;
  }

  // --- Gems ---
  void addGems(int amount) {
    if (amount <= 0) return;
    _gems += amount;
    _saveState();
    notifyListeners();
  }

  bool spendGems(int amount) {
    if (amount <= 0 || _gems < amount) return false;
    _gems -= amount;
    _saveState();
    notifyListeners();
    return true;
  }

  // --- Boosters ---
  int getBoosterCount(String boosterKey) {
    switch (boosterKey) {
      case 'peek':
        return _peekBoosters;
      case 'freeze':
        return _freezeBoosters;
      case 'wand':
        return _wandBoosters;
      case 'shuffle':
        return _shuffleBoosters;
      default:
        return 0;
    }
  }

  void addBooster(String boosterKey, int count) {
    if (count <= 0) return;
    switch (boosterKey) {
      case 'peek':
        _peekBoosters += count;
        break;
      case 'freeze':
        _freezeBoosters += count;
        break;
      case 'wand':
        _wandBoosters += count;
        break;
      case 'shuffle':
        _shuffleBoosters += count;
        break;
    }
    _saveState();
    notifyListeners();
  }

  bool useBooster(String boosterKey) {
    bool used = false;
    switch (boosterKey) {
      case 'peek':
        if (_peekBoosters > 0) {
          _peekBoosters--;
          used = true;
        }
        break;
      case 'freeze':
        if (_freezeBoosters > 0) {
          _freezeBoosters--;
          used = true;
        }
        break;
      case 'wand':
        if (_wandBoosters > 0) {
          _wandBoosters--;
          used = true;
        }
        break;
      case 'shuffle':
        if (_shuffleBoosters > 0) {
          _shuffleBoosters--;
          used = true;
        }
        break;
    }

    if (used) {
      _saveState();
      notifyListeners();
    }
    return used;
  }
}
