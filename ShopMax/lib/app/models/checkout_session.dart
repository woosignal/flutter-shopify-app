//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'dart:convert';
import '/app/models/cart.dart';
import '/app/models/shipping_type.dart';

import '/app/models/billing_details.dart';
import '/app/models/customer_address.dart';
import '/app/models/payment_type.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import '/config/storage_keys.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/discount_code.dart';
import 'package:woosignal_shopify_api/models/response/woosignal_app.dart';

class CheckoutSession {
  bool? shipToDifferentAddress = false;

  CheckoutSession._privateConstructor();
  static final CheckoutSession getInstance =
      CheckoutSession._privateConstructor();

  BillingDetails? billingDetails;
  ShippingType? shippingType;
  PaymentType? paymentType;
  DiscountCode? coupon;
  double? tax;
  String? taxName;

  void initSession() {
    billingDetails = BillingDetails();
    shippingType = null;
  }

  void clear() {
    billingDetails = null;
    shippingType = null;
    paymentType = null;
    coupon = null;
  }

  saveBillingAddress() async {
    CustomerAddress? customerAddress =
        CheckoutSession.getInstance.billingDetails!.billingAddress;

    if (customerAddress == null) {
      return;
    }

    String billingAddress = jsonEncode(customerAddress.toJson());
    await NyStorage.store(StorageKey.customerBillingDetails, billingAddress);
  }

  Future<CustomerAddress?> getBillingAddress() async {
    String? strCheckoutDetails =
        await (NyStorage.read(StorageKey.customerBillingDetails));

    if (strCheckoutDetails != null && strCheckoutDetails != "") {
      return CustomerAddress.fromJson(jsonDecode(strCheckoutDetails));
    }
    return null;
  }

  clearBillingAddress() async =>
      await NyStorage.delete(StorageKey.customerBillingDetails);

  saveShippingAddress() async {
    CustomerAddress? customerAddress =
        CheckoutSession.getInstance.billingDetails!.shippingAddress;
    if (customerAddress == null) {
      return;
    }
    String shippingAddress = jsonEncode(customerAddress.toJson());
    await NyStorage.store(StorageKey.customerShippingDetails, shippingAddress);
  }

  Future<CustomerAddress?> getShippingAddress() async {
    String? strCheckoutDetails =
        await (NyStorage.read(StorageKey.customerShippingDetails));
    if (strCheckoutDetails != null && strCheckoutDetails != "") {
      return CustomerAddress.fromJson(jsonDecode(strCheckoutDetails));
    }
    return null;
  }

  clearShippingAddress() async =>
      await NyStorage.delete(StorageKey.customerShippingDetails);

  Future<String> total({bool withFormat = false}) async {
    double totalCart = parseWcPrice(await Cart.getInstance.getTotal());
    double totalShipping = 0;
    double totalTax = 0;
    WooSignalApp? shopifyApp = AppHelper.instance.shopifyAppConfig;

    if (shopifyApp?.taxesIncluded == true || shopifyApp?.taxShipping == true) {
      totalTax = parseWcPrice(await Cart.getInstance.taxAmount());
    }

    if (shippingType != null && shippingType?.shippingMethod != null) {
      totalShipping = double.parse(shippingType?.shippingMethod?.price ?? "0");
    }

    double total = (totalCart + totalTax + totalShipping);

    if (withFormat == true) {
      return formatDoubleCurrency(total: total);
    }
    return total.toStringAsFixed(2);
  }
}
