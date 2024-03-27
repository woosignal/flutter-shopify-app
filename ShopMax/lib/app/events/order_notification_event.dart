import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:woosignal_shopify_api/woosignal_shopify_api.dart';
import '/resources/pages/account_order_detail_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

class OrderNotificationEvent implements NyEvent {
  @override
  final listeners = {
    DefaultListener: DefaultListener(),
  };
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic event) async {
    RemoteMessage message = event['RemoteMessage'];

    if (!message.data.containsKey('order_id')) {
      return;
    }
    if (!message.data.containsKey('user_id')) {
      return;
    }

    String userId = message.data['user_id'];

    if (!WooSignalShopify.authUserLoggedIn()) {
      return;
    }

    String? currentUserId = await WooSignalShopify.authUserId();
    if (currentUserId != userId) {
      return;
    }

    routeTo(AccountOrderDetailPage.path,
        data: int.parse(message.data['order_id']));
  }
}
