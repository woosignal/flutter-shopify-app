import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_customer_info.dart';
import 'package:woosignal_shopify_api/woosignal_shopify_api.dart';

class LoginEvent implements NyEvent {
  @override
  final listeners = {
    DefaultListener: DefaultListener(),
  };
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic event) async {
    AuthCustomerInfo? authCustomerInfo =
        await WooSignalShopify.instance.authCustomer();

    if (authCustomerInfo == null) {
      return;
    }

    if (authCustomerInfo.uid == null) {
      return;
    }

    WooSignalShopify.instance.setShopifyUserId(authCustomerInfo.uid!);
  }
}
