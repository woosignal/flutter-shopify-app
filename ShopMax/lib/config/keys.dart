import 'package:nylo_framework/nylo_framework.dart';

/* Keys
|--------------------------------------------------------------------------
| Storage keys are used to read and write to local storage.
| E.g. static StorageKey coins = "SK_COINS";
| String coins = await Keys.coins.read();
|
| Learn more: https://nylo.dev/docs/6.x/storage#storage-keys
|-------------------------------------------------------------------------- */

class Keys {
  // Define the keys you want to be synced on boot
  static syncedOnBoot() => () async {
        return [
          auth,
          // coins.defaultValue(10), // give the user 10 coins by default
        ];
      };

  static StorageKey auth = getEnv('SK_USER', defaultValue: 'SK_USER');

  static String userToken = "USER_TOKEN";
  static const String cart = "CART_SESSION";
  static const String customerBillingDetails = "CS_BILLING_DETAILS";
  static const String customerShippingDetails = "CS_SHIPPING_DETAILS";
  static const String wishlistProducts = "CS_WISHLIST_PRODUCTS";

  // static StorageKey coins = 'SK_COINS';

  /// Add your storage keys here...
}
