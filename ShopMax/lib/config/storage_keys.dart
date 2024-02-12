/*
|--------------------------------------------------------------------------
| Storage Keys
| Add your storage keys here and then use them later to retrieve data.
| E.g. static String userCoins = "USER_COINS";
| String coins = NyStorage.read( StorageKey.userCoins );
|
| Learn more: https://nylo.dev/docs/5.20.0/storage#storage-keys
|--------------------------------------------------------------------------
*/

import 'package:nylo_framework/nylo_framework.dart';

class StorageKey {
  static String userToken = "USER_TOKEN";
  static String authUser = getEnv('AUTH_USER_KEY', defaultValue: 'AUTH_USER');

  static const String cart = "CART_SESSION";
  static const String customerBillingDetails = "CS_BILLING_DETAILS";
  static const String customerShippingDetails = "CS_SHIPPING_DETAILS";
  static const String wishlistProducts = "CS_WISHLIST_PRODUCTS";
  static const String shopifyCustomer = "shopify_customer";

  /// Add your storage keys here...
}
