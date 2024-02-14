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

import 'package:flutter/widgets.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/shopify/checkout_status_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/order_created_response.dart';
import 'package:woosignal_shopify_api/models/shopify_order.dart';

// CALL THE BELOW METHOD TO SHOW AND HIDE LOADER
// state.reloadState(showLoader: false);

// CHECKOUT HELPER
// IT WILL RETURN THE ORDER TOTAL, BILLING DETAILS AND CART
// await checkout(taxRate, (total, billingDetails, cart) async {
//
// });

// TO USE A PAYMENT GATEWAY, FIRST OPEN /config/payment_gateways.dart.
// THEN ADD A NEW PAYMENT LIKE IN THE BELOW EXAMPLE
//
// addPayment(
//     id: 6,
//     name: "My Payment",
//     description: trans("Debit or Credit Card"),
//     assetImage: "payment_logo.png",  E.g. /public/assets/images/payment_logo.png
//     pay: examplePay,
//   ),

examplePay(context) async {
  // HANDLE YOUR PAYMENT INTEGRATION HERE
  // ...
  // ...
  // ...
  // THEN ON SUCCESS OF A PAYMENT YOU CAN DO SOMETHING SIMILAR BELOW

  // CREATES ORDER MODEL
  ShopifyOrder orderShopify = ShopifyOrder();

  // CREATES ORDER IN Shopify
  OrderCreatedResponse? orderCreatedResponse =
      await (appWooSignalShopify((api) => api.createOrder(orderShopify)));

  // CHECK IF ORDER IS NULL
  if (orderCreatedResponse == null) {
    showToastNotification(
      context,
      title: trans("Error"),
      description: trans("Something went wrong, please contact our store"),
    );
    // updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
    return;
  }

  Navigator.pushNamed(context, CheckoutStatusPage.path,
      arguments: orderCreatedResponse);
}
