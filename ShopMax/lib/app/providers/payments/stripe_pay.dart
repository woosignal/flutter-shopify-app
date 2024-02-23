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

import 'package:flutter/material.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/data/order_shopify.dart';
import '/bootstrap/helpers.dart';
import '../../../resources/pages/checkout_confirmation_page.dart';
import '../../../resources/pages/checkout_status_page.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/woosignal_app.dart';
import 'package:woosignal_shopify_api/models/shopify_order.dart';
import 'package:woosignal_shopify_api/models/response/order_created_response.dart';

stripePay(context) async {
  WooSignalApp? wooSignalApp = AppHelper.instance.shopifyAppConfig;

  bool liveMode = getEnv('STRIPE_LIVE_MODE') == null
      ? !wooSignalApp!.stripeLiveMode!
      : getEnv('STRIPE_LIVE_MODE', defaultValue: false);

  // CONFIGURE STRIPE
  Stripe.stripeAccountId =
      getEnv('STRIPE_ACCOUNT') ?? wooSignalApp!.stripeAccount;

  Stripe.publishableKey = liveMode
      ? "pk_live_IyS4Vt86L49jITSfaUShumzi"
      : "pk_test_0jMmpBntJ6UkizPkfiB8ZJxH"; // Don't change this value
  await Stripe.instance.applySettings();

  if (Stripe.stripeAccountId == '') {
    NyLogger.error(
        'You need to connect your Stripe account to WooSignal via the dashboard https://woosignal.com/dashboard');
    return;
  }

  try {
    Map<String, dynamic>? rsp = {};
    //   // CHECKOUT HELPER
    await checkoutShopify((total, billingDetails, cart) async {
      String cartShortDesc = await cart.cartShortDesc();

      rsp = await appWooSignalShopify((api) => api.stripePaymentIntent(
            amount: total,
            email: billingDetails?.billingAddress?.emailAddress,
            desc: cartShortDesc,
            shipping: billingDetails?.getShippingAddressStripe(),
            customerDetails: billingDetails?.createStripeDetails(),
          ));
    });

    if (rsp == null) {
      showToastNotification(context,
          title: trans("Oops!"),
          description: trans("Something went wrong, please try again."),
          icon: Icons.payment,
          style: ToastNotificationStyleType.WARNING);
      updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
      return;
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
          style: Theme.of(context).brightness == Brightness.light
              ? ThemeMode.light
              : ThemeMode.dark,
          merchantDisplayName:
              envVal('APP_NAME', defaultValue: wooSignalApp?.appName),
          customerId: rsp!['customer'],
          paymentIntentClientSecret: rsp!['client_secret'],
          customerEphemeralKeySecret: rsp!['ephemeral_key'],
          setupIntentClientSecret: rsp!['setup_intent_secret']),
    );

    await Stripe.instance.presentPaymentSheet();

    PaymentIntent paymentIntent =
        await Stripe.instance.retrievePaymentIntent(rsp!['client_secret']);

    if (paymentIntent.status == PaymentIntentsStatus.Unknown) {
      showToastNotification(
        context,
        title: trans("Oops!"),
        description: trans("Something went wrong, please try again."),
        icon: Icons.payment,
        style: ToastNotificationStyleType.WARNING,
      );
    }

    if (paymentIntent.status != PaymentIntentsStatus.Succeeded) {
      return;
    }

    updateState(CheckoutConfirmationPage.path, data: {"reloadState": true});

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
  } on StripeException catch (e) {
    if (getEnv('APP_DEBUG', defaultValue: true)) {
      NyLogger.error(e.error.message!);
    }
    showToastNotification(
      context,
      title: trans("Oops!"),
      description: e.error.localizedMessage!,
      icon: Icons.payment,
      style: ToastNotificationStyleType.WARNING,
    );
    updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
  } catch (e) {
    if (getEnv('APP_DEBUG', defaultValue: true)) {
      NyLogger.error(e.toString());
    }
    showToastNotification(
      context,
      title: trans("Oops!"),
      description: trans("Something went wrong, please try again."),
      icon: Icons.payment,
      style: ToastNotificationStyleType.WARNING,
    );
    updateState(CheckoutConfirmationPage.path, data: {"showLoader": false});
  }
}
