//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '/app/events/firebase_on_message_order_event.dart';
import '/app/events/order_notification_event.dart';
import '/app/events/product_notification_event.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/account_order_detail_page.dart';
import '/bootstrap/app_helper.dart';
import '/resources/widgets/mello_theme_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/woosignal_app.dart';

class HomePage extends NyStatefulWidget {
  static String path = "/home";
  HomePage() : super(path, child: _HomePageState());
}

class _HomePageState extends NyState<HomePage> {
  final WooSignalApp? _wooSignalApp = AppHelper.instance.shopifyAppConfig;

  @override
  init() async {
    _enableFcmNotifications();
  }

  _enableFcmNotifications() {
    bool? firebaseFcmIsEnabled =
        AppHelper.instance.shopifyAppConfig?.firebaseFcmIsEnabled;
    firebaseFcmIsEnabled ??= getEnv('FCM_ENABLED', defaultValue: false);

    if (firebaseFcmIsEnabled != true) return;

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      /// Product notification
      if (message.data.containsKey('product_id')) {
        event<ProductNotificationEvent>(data: {"RemoteMessage": message});
      }

      /// Order notification
      if (message.data.containsKey('order_id')) {
        event<OrderNotificationEvent>(data: {"RemoteMessage": message});
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      /// Order notification
      if (message.data.containsKey('order_id')) {
        event<FirebaseOnMessageOrderEvent>(data: {"RemoteMessage": message});
        _maybeShowSnackBar(message);
      }
    });
  }

  /// Attempt to show a snackbar if the user is on the same page
  _maybeShowSnackBar(RemoteMessage message) async {
    if (!(await canSeeRemoteMessage(message))) {
      return;
    }
    _showSnackBar(message.notification?.body, onPressed: () {
      routeTo(AccountOrderDetailPage.path,
          data: message.data['order_id'].toString());
    });
  }

  _showSnackBar(String? message, {Function()? onPressed}) {
    SnackBar snackBar = SnackBar(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${'New notification received'.tr()} 🚨',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          if (message != null) Text(message)
        ],
      ),
      action: onPressed == null
          ? null
          : SnackBarAction(
              label: 'View'.tr(),
              onPressed: onPressed,
            ),
      duration: Duration(milliseconds: 4500),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    Widget theme = MelloThemeWidget(wooSignalApp: _wooSignalApp);
    return theme;
  }
}
