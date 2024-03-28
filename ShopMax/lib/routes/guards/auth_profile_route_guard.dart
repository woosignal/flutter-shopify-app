import 'package:flutter/material.dart';
import 'package:woosignal_shopify_api/woosignal_shopify_api.dart';
import '/resources/pages/login_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* AuthProfile Route Guard
|-------------------------------------------------------------------------- */

class AuthProfileRouteGuard extends NyRouteGuard {
  AuthProfileRouteGuard();

  @override
  Future<bool> canOpen(BuildContext? context, NyArgument? data) async {
    bool isLoggedIn = WooSignalShopify.authUserLoggedIn();
    return isLoggedIn;
  }

  @override
  redirectTo(BuildContext? context, NyArgument? data) async {
    routeTo(LoginPage.path);
  }
}
