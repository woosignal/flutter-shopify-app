import 'package:flutter/material.dart';
import '/config/storage_keys.dart';
import '/resources/pages/shopify/login_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

/*
|--------------------------------------------------------------------------
| AuthProfile Route Guard
|--------------------------------------------------------------------------
*/

class AuthProfileRouteGuard extends NyRouteGuard {
  AuthProfileRouteGuard();

  @override
  Future<bool> canOpen(BuildContext? context, NyArgument? data) async {
    bool isLoggedIn = await Auth.loggedIn(key: StorageKey.shopifyCustomer);
    return isLoggedIn;
  }

  @override
  redirectTo(BuildContext? context, NyArgument? data) async {
    routeTo(LoginPage.path);
  }
}
