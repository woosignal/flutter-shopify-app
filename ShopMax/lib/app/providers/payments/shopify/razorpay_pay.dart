//
//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//

import 'package:nylo_framework/nylo_framework.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:woosignal_shopify_api/models/response/order_created_response.dart';
import 'package:woosignal_shopify_api/models/shopify_order.dart';

import '/bootstrap/data/order_shopify.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/shopify/checkout_confirmation_page.dart';
import '/resources/pages/shopify/checkout_status_page.dart';

razorPay(context) async {
  Razorpay razorpay = Razorpay();

  razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
      (PaymentSuccessResponse response) async {
        ShopifyOrder orderShopify = await buildOrderShopify(markPaid: true);
        OrderCreatedResponse? order =
        await (appWooSignalShopify((api) => api.createOrder(orderShopify)));

        if (order == null) {
          showToastNotification(
            context,
            title: trans("Error"),
            description: trans("Something went wrong, please contact our store"),
          );
          updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
          return;
        }
        routeTo(CheckoutStatusPage.path,
            navigationType: NavigationType.pushAndForgetAll, data: order);
  });

  razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
    showToastNotification(context,
        title: trans("Error"),
        description: response.message ?? "",
        style: ToastNotificationStyleType.WARNING);
    updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
  });

  razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

  // CHECKOUT HELPER
  await checkoutShopify((total, billingDetails, cart) async {
    var options = {
      'key': getEnv('RAZORPAY_API_KEY'),
      'amount': (double.parse(total) * 100).toInt(),
      'name': getEnv('APP_NAME'),
      'description': await cart.cartShortDesc(),
      'prefill': {
        "name": [
          billingDetails!.billingAddress?.firstName,
          billingDetails.billingAddress?.lastName
        ].where((t) => t != null || t != "").toList().join(" "),
        "method": "card",
        'email': billingDetails.billingAddress?.emailAddress ?? ""
      }
    };

    updateState(CheckoutConfirmationPage.path, data: {"reloadState": true});

    razorpay.open(options);
  });
}

void _handleExternalWallet(ExternalWalletResponse response) {}
