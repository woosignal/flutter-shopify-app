import 'package:woosignal_shopify_api/woosignal_shopify_api.dart';
import '/resources/pages/login_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* AuthProfile Route Guard
|-------------------------------------------------------------------------- */

class AuthProfileRouteGuard extends NyRouteGuard {
  @override
  onRequest(PageRequest pageRequest) async {
    bool isLoggedIn = WooSignalShopify.authUserLoggedIn();

    if (!isLoggedIn) {
      return redirect(LoginPage.path, data: {"showBackButton": true});
    }

    return pageRequest;
  }
}
