import '/config/storage_keys.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/shopify/cart.dart';

class LogoutEvent implements NyEvent {
  @override
  final listeners = {DefaultListener: DefaultListener()};
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic event) async {
    await Auth.logout(key: StorageKey.shopifyCustomer);
    await Cart.getInstance.clear();
    await routeToInitial();
  }
}
