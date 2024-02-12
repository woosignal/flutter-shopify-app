import '/config/storage_keys.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_user.dart';

/* AUTH
|--------------------------------------------------------------------------
| Authenticate your users.
|-------------------------------------------------------------------------- */

login() async {
  String keyShopify = StorageKey.shopifyCustomer;

  await Auth.loginModel(keyShopify, (data) => AuthCustomer.fromJson(data));
}
