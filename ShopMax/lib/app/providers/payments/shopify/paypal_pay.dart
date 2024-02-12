//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/models/shopify/cart_line_item.dart';
import '/app/models/shopify/checkout_session.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/shopify/checkout_confirmation_page.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/order_created_response.dart';
import 'package:woosignal_shopify_api/models/shopify_order.dart';
import '/bootstrap/data/order_shopify.dart';
import '/resources/pages/shopify/checkout_status_page.dart';

payPalPay(context) async {

  await checkoutShopify((total, billingDetails, cart) async {
    List<CartLineItem> cartLineItems = await cart.getCart();
    String cartTotal = await cart.getTotal();
    String? currencyCode = AppHelper.instance.shopifyAppConfig?.currencyMeta?.code;

    String shippingTotal = CheckoutSession.getInstance.shippingType?.getTotal() ?? "0";

    String description = "(${cartLineItems.length}) items from ${getEnv('APP_NAME')}".tr(arguments: {"appName": getEnv('APP_NAME')});

    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => PaypalCheckoutView(
      sandboxMode: getEnv('PAYPAL_LIVE_MODE') != true,
      clientId:  getEnv('PAYPAL_CLIENT_ID'),
      secretKey: getEnv('PAYPAL_SECRET_KEY'),
          note: "Contact us for any questions on your order.".tr(),
      transactions: [
        {
          "amount": {
            "total": total,
            "currency": currencyCode?.toUpperCase(),
            "details": {
              "subtotal": cartTotal,
              "shipping": shippingTotal,
              "shipping_discount": 0
            }
          },
          "description": description,
          "item_list": {
            "items": cartLineItems.map((item) => {
              "name": item.title,
              "quantity": item.quantity,
              "price": item.price,
              "currency": currencyCode?.toUpperCase()
            }).toList(),

            "shipping_address": {
                "recipient_name": "${billingDetails?.shippingAddress?.nameFull()}",
                "line1": billingDetails?.shippingAddress?.addressLine,
                "line2": "",
                "city": billingDetails?.shippingAddress?.city,
                "country_code": billingDetails?.shippingAddress?.customerCountry?.countryCode,
                "postal_code": billingDetails?.shippingAddress?.postalCode,
                "phone": billingDetails?.shippingAddress?.phoneNumber,
                "state": billingDetails?.shippingAddress?.customerCountry?.state?.name
             },
          }
        }
      ],
      onSuccess: (Map params) async {
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
      },
      onError: (error) {
        NyLogger.error(error.toString());
        showToastNotification(
          context,
          title: trans("Error"),
          description:
          trans("Something went wrong, please contact our store"),
        );
        updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
      },
      onCancel: () {
        showToastNotification(
          context,
          title: trans("Payment Cancelled"),
          description: trans("The payment has been cancelled"),
        );
        updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
      },
    ),),);
  });
}
