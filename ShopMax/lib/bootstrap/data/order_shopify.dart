//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import '/app/models/billing_details.dart';
import '/app/models/cart.dart';
import '/app/models/cart_line_item.dart';
import '/app/models/checkout_session.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import '/config/storage_keys.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_customer_info.dart';
import 'package:woosignal_shopify_api/models/response/woosignal_app.dart';
import 'package:woosignal_shopify_api/models/shopify_order.dart';

Future<ShopifyOrder> buildOrderShopify({bool markPaid = true}) async {
  ShopifyOrder order = ShopifyOrder();

  WooSignalApp shopifyApp = AppHelper.instance.shopifyAppConfig!;
  CheckoutSession checkoutSession = CheckoutSession.getInstance;

  String total = await checkoutSession.total(withFormat: false);
  Transaction transaction = Transaction(
      currency: shopifyApp.currencyMeta?.code,
      kind: "sale",
      status: "success",
      amount: total,
      test: shopifyApp.appDebug == 1 ? true : false);

  order.sendFulfillmentReceipt = false;
  order.sendReceipt = false;
  order.transactions = [];
  order.transactions?.add(transaction);

  order.test = shopifyApp.appDebug == 1 ? true : false;

  order.currency = shopifyApp.currencyMeta?.code?.toUpperCase();

  if (await Auth.loggedIn(key: StorageKey.shopifyCustomer)) {
    AuthCustomerInfo? customer =
        await appWooSignalShopify((api) => api.authCustomer());
    order.customer = customer?.uid;
    print(['order.customer', order.customer]);
  }
  List<LineItems> lineItems = [];
  List<CartLineItem> cartItems = await Cart.getInstance.getCart();

  for (var cartItem in cartItems) {
    LineItems tmpLineItem = LineItems();

    tmpLineItem.quantity = cartItem.quantity;
    tmpLineItem.productId = cartItem.productId;
    if (cartItem.variationId != null && cartItem.variationId != 0) {
      tmpLineItem.variantId = cartItem.variationId;
    }
    tmpLineItem.price = cartItem.price;
    tmpLineItem.taxable = cartItem.taxable;
    tmpLineItem.requiresShipping = true;

    lineItems.add(tmpLineItem);
  }

  order.lineItems = lineItems;

  BillingDetails? billingDetails = checkoutSession.billingDetails;

  // BILLING
  BillingAddress billing = BillingAddress();
  billing.firstName = billingDetails?.billingAddress?.firstName;
  billing.lastName = billingDetails?.billingAddress?.lastName;
  billing.name = billingDetails?.billingAddress?.nameFull();
  billing.address1 = billingDetails?.billingAddress?.addressLine;
  billing.city = billingDetails?.billingAddress?.city;
  billing.phone = '';
  billing.company = null;
  billing.zip = billingDetails?.billingAddress?.postalCode;
  billing.country = billingDetails?.billingAddress?.customerCountry?.name;
  billing.countryCode = checkoutSession
      .billingDetails?.billingAddress?.customerCountry?.countryCode;
  billing.latitude = null;
  billing.longitude = null;

  if (billingDetails?.billingAddress?.customerCountry?.hasState() ?? false) {
    billing.province =
        billingDetails?.billingAddress?.customerCountry?.state?.name ?? "";
    billing.provinceCode =
        billingDetails?.billingAddress?.customerCountry?.state?.code ?? "";
  }

  order.billingAddress = billing;

  // SHIPPING
  ShippingAddress shipping = ShippingAddress();
  shipping.firstName = billingDetails?.shippingAddress?.firstName;
  shipping.lastName = billingDetails?.shippingAddress?.lastName;
  shipping.name = billingDetails?.shippingAddress?.nameFull();
  shipping.address1 = billingDetails?.shippingAddress?.addressLine;
  shipping.city = billingDetails?.shippingAddress?.city;
  shipping.phone = '';
  shipping.company = null;
  shipping.zip = billingDetails?.shippingAddress?.postalCode;
  shipping.latitude = null;
  shipping.longitude = null;

  if (billingDetails?.shippingAddress?.customerCountry?.hasState() ?? false) {
    shipping.province =
        billingDetails?.shippingAddress?.customerCountry?.state?.name ?? "";
    shipping.provinceCode =
        billingDetails?.shippingAddress?.customerCountry?.state?.code;
  }

  shipping.country = billingDetails?.shippingAddress?.customerCountry?.name;
  shipping.countryCode = checkoutSession
      .billingDetails?.shippingAddress?.customerCountry?.countryCode;

  order.shippingAddress = shipping;

  order.shippingLines = [];
  ShippingLines shippingLine = ShippingLines();
  if (checkoutSession.shippingType?.shippingMethod != null) {
    shippingLine.price = checkoutSession.shippingType?.shippingMethod?.price;
    shippingLine.title = checkoutSession.shippingType?.shippingMethod?.title;
    shippingLine.code = "";

    order.shippingLines?.add(shippingLine);
  }

  double taxAmount = 0;
  order.taxesIncluded = shopifyApp.taxesIncluded;
  taxAmount = double.parse(await Cart.getInstance.taxAmount());
  order.taxLines = [];
  if (taxAmount > 0) {
    order.taxLines?.add(TaxLines(
        title: checkoutSession.taxName,
        rate: checkoutSession.tax,
        price: taxAmount));
  }

  order.financialStatus = "authorized";
  order.email = billingDetails?.billingAddress?.emailAddress;
  order.presentmentCurrency = shopifyApp.currencyMeta?.code;

  return order;
}
