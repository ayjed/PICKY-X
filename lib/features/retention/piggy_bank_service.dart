import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/wallet_service.dart';

/// Service managing the Candy Crush-style Piggy Bank savings mechanism.
class PiggyBankService extends ChangeNotifier {
  static const int maxPiggyCapacity = 1000;
  static const int coinsPerWinDeposit = 30;

  static const String keyPiggyCoins = 'pickyx_piggy_bank_coins';

  final SharedPreferences _prefs;
  int _piggyCoins = 0;

  PiggyBankService(this._prefs) {
    _piggyCoins = _prefs.getInt(keyPiggyCoins) ?? 0;
  }

  static Future<PiggyBankService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PiggyBankService(prefs);
  }

  int get piggyCoins => _piggyCoins;
  bool get isFull => _piggyCoins >= maxPiggyCapacity;
  double get fullnessRatio => (_piggyCoins / maxPiggyCapacity).clamp(0.0, 1.0);

  /// Automatically deposits coins into piggy bank after winning a level
  void recordLevelWinDeposit() {
    if (_piggyCoins < maxPiggyCapacity) {
      _piggyCoins = min(maxPiggyCapacity, _piggyCoins + coinsPerWinDeposit);
      _prefs.setInt(keyPiggyCoins, _piggyCoins);
      notifyListeners();
    }
  }

  /// Breaks the piggy bank upon IAP purchase, depositing coins into player's wallet
  int breakPiggyBank(WalletService wallet) {
    final collected = _piggyCoins;
    if (collected > 0) {
      wallet.addCoins(collected);
      _piggyCoins = 0;
      _prefs.setInt(keyPiggyCoins, 0);
      notifyListeners();
    }
    return collected;
  }
}
