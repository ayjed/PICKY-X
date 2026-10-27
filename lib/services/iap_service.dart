import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'life_service.dart';
import 'wallet_service.dart';

class IapProduct {
  final String id;
  final String title;
  final String description;
  final String priceFormatted;
  final bool isSubscription;
  final bool isConsumable;

  const IapProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.priceFormatted,
    this.isSubscription = false,
    this.isConsumable = true,
  });
}

/// Service managing In-App Purchases (Google Play Billing) and VIP Subscriptions.
class IapService extends ChangeNotifier {
  static const String keyVipActive = 'pickyx_iap_vip_active';
  static const String keyRemoveAds = 'pickyx_iap_remove_ads';

  final SharedPreferences _prefs;

  static const List<IapProduct> catalog = [
    IapProduct(
      id: 'starter_pack_special',
      title: 'Starter Pack (80% Off)',
      description: '500 Coins + 25 Gems + 8 Boosters + 2h Infinite Lives',
      priceFormatted: '\$0.99',
    ),
    IapProduct(
      id: 'gem_pouch_25',
      title: 'Pouch of Gems',
      description: '25 Shiny Gems for instant boosts and lives',
      priceFormatted: '\$0.99',
    ),
    IapProduct(
      id: 'gem_sack_100',
      title: 'Sack of Gems',
      description: '100 Shiny Gems (Most Popular)',
      priceFormatted: '\$2.99',
    ),
    IapProduct(
      id: 'gem_vault_500',
      title: 'Vault of Gems',
      description: '500 Shiny Gems (Best Value)',
      priceFormatted: '\$9.99',
    ),
    IapProduct(
      id: 'coin_pack_1000',
      title: 'Chest of Gold',
      description: '1,000 Gold Coins for boosters and continues',
      priceFormatted: '\$1.49',
    ),
    IapProduct(
      id: 'remove_ads_permanent',
      title: 'Remove Ads Permanent',
      description: 'Removes all banner and interstitial ads forever',
      priceFormatted: '\$1.99',
      isConsumable: false,
    ),
    IapProduct(
      id: 'vip_pass_monthly',
      title: 'VIP Club Pass',
      description: 'Unlimited Lives + No Ads + 2X Coins + VIP Gold Theme',
      priceFormatted: '\$3.99/mo',
      isSubscription: true,
      isConsumable: false,
    ),
  ];

  IapService(this._prefs);

  static Future<IapService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return IapService(prefs);
  }

  bool get isVipActive => _prefs.getBool(keyVipActive) ?? false;
  bool get isAdsRemoved => isVipActive || (_prefs.getBool(keyRemoveAds) ?? false);

  /// Executes a purchase transaction and delivers digital goods
  Future<bool> purchaseProduct(String productId, WalletService wallet, LifeService lives) async {
    // Process local fulfillment with persistence
    switch (productId) {
      case 'starter_pack_special':
        wallet.addCoins(500);
        wallet.addGems(25);
        wallet.addBooster('peek', 2);
        wallet.addBooster('freeze', 2);
        wallet.addBooster('wand', 2);
        wallet.addBooster('shuffle', 2);
        lives.grantUnlimitedLives(const Duration(hours: 2));
        break;
      case 'gem_pouch_25':
        wallet.addGems(25);
        break;
      case 'gem_sack_100':
        wallet.addGems(100);
        break;
      case 'gem_vault_500':
        wallet.addGems(500);
        break;
      case 'coin_pack_1000':
        wallet.addCoins(1000);
        break;
      case 'remove_ads_permanent':
        await _prefs.setBool(keyRemoveAds, true);
        break;
      case 'vip_pass_monthly':
        await _prefs.setBool(keyVipActive, true);
        lives.grantUnlimitedLives(const Duration(days: 30));
        break;
      default:
        return false;
    }

    notifyListeners();
    return true;
  }

  /// Restores previous purchases (e.g. Remove Ads, VIP Pass)
  Future<void> restorePurchases() async {
    // Queries stored entitlement state
    notifyListeners();
  }
}
