//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:woosignal_shopify_api/woosignal_shopify_api.dart';
import '/app/models/cart.dart';
import '/app/models/checkout_session.dart';
import '/app/models/customer_address.dart';
import '/app/models/cart_line_item.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/checkout_confirmation_page.dart';
import '/resources/widgets/buttons.dart';
import '/resources/pages/account_landing_page.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/text_row_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/widgets/cart_item_container_widget.dart';

class CartPage extends NyStatefulWidget {
  static String path = "/cart";
  CartPage() : super(path, child: _CartPageState());
}

class _CartPageState extends NyState<CartPage> {
  List<CartLineItem> _cartLines = [];

  @override
  boot() async {
    await _cartCheck();
    CheckoutSession.getInstance.coupon = null;
  }

  _cartCheck() async {
    List<CartLineItem> cart = await Cart.getInstance.getCart();

    if (cart.isEmpty) return;

    List<Map<String, dynamic>> cartJSON = cart.map((c) => c.toJson()).toList();

    List<dynamic> cartRes =
        await appWooSignalShopify((api) => api.cartCheck(cartJSON));

    if (cartRes.isEmpty) {
      Cart.getInstance.saveCartToPref(cartLineItems: []);
      return;
    }
    _cartLines = cartRes.map((json) => CartLineItem.fromJson(json)).toList();
    if (_cartLines.isNotEmpty) {
      Cart.getInstance.saveCartToPref(cartLineItems: _cartLines);
    }
  }

  void _actionProceedToCheckout() async {
    List<CartLineItem> cartLineItems = await Cart.getInstance.getCart();

    if (isLoading()) {
      return;
    }

    if (cartLineItems.isEmpty) {
      showToastNotification(
        context,
        title: trans("Cart"),
        description: trans("You need items in your cart to checkout"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.shopping_cart,
      );
      return;
    }

    if (!cartLineItems.every((c) => c.inStock())) {
      showToastNotification(
        context,
        title: trans("Cart"),
        description: trans("There is an item out of stock"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.shopping_cart,
      );
      return;
    }

    CheckoutSession.getInstance.initSession();
    CustomerAddress? sfCustomerAddress =
        await CheckoutSession.getInstance.getBillingAddress();

    if (sfCustomerAddress != null) {
      CheckoutSession.getInstance.billingDetails!.billingAddress =
          sfCustomerAddress;
      CheckoutSession.getInstance.billingDetails!.shippingAddress =
          sfCustomerAddress;
    }

    if (!WooSignalShopify.authUserLoggedIn()) {
      // show modal to ask customer if they would like to checkout as guest or login
      showAdaptiveDialog(
          context: context,
          builder: (context) {
            return AlertDialog.adaptive(
              content: Text("Checkout as guest or login to continue".tr())
                  .headingMedium(context),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    routeTo(CheckoutConfirmationPage.path);
                  },
                  child: Text("Checkout as guest".tr()),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    UserAuth.instance.redirect = CheckoutConfirmationPage.path;
                    routeTo(AccountLandingPage.path);
                  },
                  child: Text("Login / Create an account".tr()),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel".tr()),
                )
              ],
            );
          });
      return;
    }

    routeTo(CheckoutConfirmationPage.path);
  }

  actionIncrementQuantity({required CartLineItem cartLineItem}) async {
    if (cartLineItem.inventoryPolicy == "deny" &&
        (cartLineItem.quantity! + 1) > cartLineItem.inventoryQuantity!) {
      showToastNotification(
        context,
        title: trans("Cart"),
        description: trans("Maximum stock reached"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.shopping_cart,
      );
      return;
    }
    await Cart.getInstance
        .updateQuantity(cartLineItem: cartLineItem, incrementQuantity: 1);
    int cartVal = cartLineItem.quantity ?? 1;
    cartLineItem.quantity = (cartVal += 1);
    setState(() {});
  }

  actionDecrementQuantity({required CartLineItem cartLineItem}) async {
    if (cartLineItem.quantity == null) {
      return;
    }
    if (cartLineItem.quantity! - 1 <= 0) {
      return;
    }
    await Cart.getInstance
        .updateQuantity(cartLineItem: cartLineItem, incrementQuantity: -1);
    int cartVal = cartLineItem.quantity ?? 0;
    cartLineItem.quantity = (cartVal -= 1);
    setState(() {});
  }

  actionRemoveItem({required int index}) async {
    await Cart.getInstance.removeCartItemForIndex(index: index);
    _cartLines.removeAt(index);
    showToastNotification(
      context,
      title: trans("Updated"),
      description: trans("Item removed"),
      style: ToastNotificationStyleType.WARNING,
      icon: Icons.remove_shopping_cart,
    );
    setState(() {});
  }

  _clearCart() async {
    await Cart.getInstance.clear();
    _cartLines = [];
    showToastNotification(context,
        title: trans("Success"),
        description: trans("Cart cleared"),
        style: ToastNotificationStyleType.SUCCESS,
        icon: Icons.delete_outline);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          trans("Shopping Cart"),
        ),
        elevation: 1,
        actions: <Widget>[
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Align(
              child: Padding(
                child: Text(
                  trans("Clear Cart"),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                padding: EdgeInsets.only(right: 8),
              ),
              alignment: Alignment.centerLeft,
            ),
            onTap: _clearCart,
          )
        ],
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: afterLoad(
                  child: () => _cartLines.isEmpty
                      ? FractionallySizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Icon(
                                Icons.shopping_cart,
                                size: 100,
                                color: Colors.black45,
                              ),
                              Padding(
                                child: Text(
                                  trans("Empty Basket"),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                padding: EdgeInsets.only(top: 10),
                              )
                            ],
                          ),
                          heightFactor: 0.5,
                          widthFactor: 1,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _cartLines.length,
                          itemBuilder: (BuildContext context, int index) {
                            CartLineItem cartLineItem = _cartLines[index];
                            return CartItemContainer(
                              cartLineItem: cartLineItem,
                              actionIncrementQuantity: () =>
                                  actionIncrementQuantity(
                                      cartLineItem: cartLineItem),
                              actionDecrementQuantity: () =>
                                  actionDecrementQuantity(
                                      cartLineItem: cartLineItem),
                              actionRemoveItem: () =>
                                  actionRemoveItem(index: index),
                            );
                          })),
            ),
            Divider(
              color: Colors.black45,
            ),
            NyFutureBuilder<String>(
              future: Cart.getInstance.getTotal(withFormat: true),
              child: (BuildContext context, data) => Padding(
                child: TextRowWidget(
                  title: trans("Total"),
                  text: isLoading() ? '' : data,
                ),
                padding: EdgeInsets.only(bottom: 15, top: 15),
              ),
              loading: SizedBox.shrink(),
            ),
            PrimaryButton(
              title: trans("PROCEED TO CHECKOUT"),
              action: _actionProceedToCheckout,
            ),
          ],
        ),
      ),
    );
  }
}
