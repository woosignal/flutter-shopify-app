//  StoreMob
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'dart:convert';

import 'package:collection/collection.dart';
import '/app/models/shopify/cart_line_item.dart';
import '/app/models/shopify/checkout_session.dart';
import '/app/models/shopify/shipping_type.dart';
import '/bootstrap/app_helper.dart';
import '/config/storage_keys.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/woosignal_app.dart';
import '/bootstrap/helpers.dart';

class Cart {
  Cart._privateConstructor();
  static final Cart getInstance = Cart._privateConstructor();

  Future<List<CartLineItem>> getCart() async {
    List<CartLineItem> cartLineItems = [];
    String? currentCartArrJSON = await (NyStorage.read(StorageKey.cart));

    if (currentCartArrJSON != null) {
      cartLineItems = (jsonDecode(currentCartArrJSON) as List<dynamic>)
          .map((i) => CartLineItem.fromJson(i))
          .toList();
    }

    return cartLineItems;
  }

  addToCart({required CartLineItem cartLineItem}) async {
    List<CartLineItem> cartLineItems = await getCart();

    if (cartLineItem.variationId != null) {
      if (cartLineItems.firstWhereOrNull((i) =>
              (i.productId == cartLineItem.productId &&
                  i.variationId == cartLineItem.variationId)) !=
          null) {
        return;
      }
    } else {
      var firstCartItem = cartLineItems
          .firstWhereOrNull((i) => i.productId == cartLineItem.productId);
      if (firstCartItem != null) {
        return;
      }
    }
    cartLineItems.add(cartLineItem);

    await saveCartToPref(cartLineItems: cartLineItems);
  }

  Future<String> getTotal({bool withFormat = false}) async {
    List<CartLineItem> cartLineItems = await getCart();
    double total = 0;
    for (var cartItem in cartLineItems) {
      total += (parseWcPrice(cartItem.price) * (cartItem.quantity ?? 1));
    }

    if (withFormat == true) {
      return formatDoubleCurrency(total: total);
    }
    return total.toStringAsFixed(2);
  }

  Future<String> getSubtotal({bool withFormat = false}) async {
    List<CartLineItem> cartLineItems = await getCart();
    double subtotal = 0;
    for (var cartItem in cartLineItems) {
      subtotal += (parseWcPrice(cartItem.price) * (cartItem.quantity ?? 1));
    }
    if (withFormat == true) {
      return formatDoubleCurrency(total: subtotal);
    }
    return subtotal.toStringAsFixed(2);
  }

  updateQuantity(
      {required CartLineItem cartLineItem,
      required int incrementQuantity}) async {
    List<CartLineItem> cartLineItems = await getCart();
    List<CartLineItem> tmpCartItem = [];
    for (var cartItem in cartLineItems) {
      if (cartItem.variationId == cartLineItem.variationId &&
          cartItem.productId == cartLineItem.productId) {
        if (((cartItem.quantity ?? 1) + incrementQuantity) > 0) {
          cartItem.quantity = (cartItem.quantity! + incrementQuantity);
        }
      }
      tmpCartItem.add(cartItem);
    }
    await saveCartToPref(cartLineItems: tmpCartItem);
  }

  Future<String> cartShortDesc() async {
    List<CartLineItem> cartLineItems = await getCart();
    var tmpShortItemDesc = [];
    for (var cartItem in cartLineItems) {
      tmpShortItemDesc
          .add("${cartItem.quantity.toString()} x | ${cartItem.title}");
    }
    return tmpShortItemDesc.join(",");
  }

  removeCartItemForIndex({required int index}) async {
    List<CartLineItem> cartLineItems = await getCart();
    cartLineItems.removeAt(index);
    await saveCartToPref(cartLineItems: cartLineItems);
  }

  clear() async {
    await NyStorage.delete(StorageKey.cart);
  }

  saveCartToPref({required List<CartLineItem?> cartLineItems}) async {
    String json = jsonEncode(cartLineItems.map((i) => i?.toJson()).toList());
    await NyStorage.store(StorageKey.cart, json);
  }

  Future<String> taxAmount() async {
    double subtotal = 0;
    double taxAmount = 0;
    WooSignalApp? shopifyApp = AppHelper.instance.shopifyAppConfig;
    ShippingType? shippingType = CheckoutSession.getInstance.shippingType;

    if (CheckoutSession.getInstance.billingDetails != null) {
      taxAmount = CheckoutSession.getInstance.billingDetails?.taxAmount() ?? 0;
    }

    List<CartLineItem> taxableCartLines = (await Cart.getInstance.getCart())
        .where((c) => c.taxable == true)
        .toList();

    if (shopifyApp?.taxesIncluded == false &&
        shopifyApp?.taxShipping == true &&
        shippingType != null &&
        shippingType.shippingMethod?.price != null) {
      subtotal = double.parse(
          (parseWcPrice(shippingType.shippingMethod?.price) * taxAmount)
              .toStringAsFixed(2));
    }

    if (taxableCartLines.isEmpty) {
      return subtotal.toString();
    }

    if (shopifyApp?.taxesIncluded == false) {
      subtotal += taxableCartLines
              .map<double>((m) =>
                  parseWcPrice(m.price) *
                  double.parse((m.quantity ?? 0).toString()))
              .reduce((a, b) => a + b) *
          taxAmount;
    }

    return (subtotal).toStringAsFixed(2);
  }
}
