//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/models/shopify/checkout_session.dart';
import '/app/models/customer_address.dart';
import '/resources/pages/shopify/checkout_confirmation_page.dart';
import '/resources/pages/shopify/checkout_shipping_type_page.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/woosignal_app.dart';

class CheckoutShippingTypeWidget extends StatelessWidget {
  const CheckoutShippingTypeWidget(
      {super.key,
      required this.context,
      required this.wooSignalApp,
      required this.checkoutSession});

  final CheckoutSession checkoutSession;
  final BuildContext context;
  final WooSignalApp? wooSignalApp;

  @override
  Widget build(BuildContext context) {
    bool hasDisableShipping = wooSignalApp!.disableShipping == 1;
    if (hasDisableShipping == true) {
      return SizedBox.shrink();
    }
    bool hasSelectedShippingType = checkoutSession.shippingType != null;
    return CheckoutRowLine(
      heading: trans(
          hasSelectedShippingType ? "Shipping selected" : "Select shipping"),
      leadImage: Icon(Icons.local_shipping),
      leadTitle: hasSelectedShippingType
          ? checkoutSession.shippingType!.getTitle()
          : trans("Select a shipping option"),
      action: _actionSelectShipping,
      showBorderBottom: true,
    );
  }

  _actionSelectShipping() {
    CustomerAddress? shippingAddress =
        checkoutSession.billingDetails!.shippingAddress;
    if (shippingAddress == null || shippingAddress.customerCountry == null) {
      showToastNotification(
        context,
        title: trans("Oops"),
        description: trans("Add your shipping details first"),
        icon: Icons.local_shipping,
      );
      return;
    }
    routeTo(CheckoutShippingTypePage.path, onPop: (value) {
      updateState(CheckoutConfirmationPage.path, data: {"refresh": true});
    });
  }
}
