import 'package:woosignal_shopify_api/woosignal_shopify_api.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/cart.dart';

class LogoutEvent implements NyEvent {
  @override
  final listeners = {DefaultListener: DefaultListener()};
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic event) async {
    await WooSignalShopify.authLogout();
    await Cart.getInstance.clear();
    await routeToInitial();
  }
}
