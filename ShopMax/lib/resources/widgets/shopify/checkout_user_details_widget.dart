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
import '/resources/pages/shopify/checkout_confirmation_page.dart';
import '/resources/pages/shopify/checkout_details_page.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CheckoutUserDetailsWidget extends StatelessWidget {
  const CheckoutUserDetailsWidget({
    super.key,
    required this.context,
    required this.checkoutSession,
  });
  final CheckoutSession checkoutSession;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    bool hasUserCheckoutInfo = (checkoutSession.billingDetails != null &&
        checkoutSession.billingDetails!.billingAddress != null);
    return CheckoutRowLine(
      heading: trans("Billing/shipping details"),
      leadImage: Icon(Icons.home),
      leadTitle: hasUserCheckoutInfo
          ? (checkoutSession.billingDetails == null ||
                  (checkoutSession.billingDetails?.billingAddress
                          ?.hasMissingFields() ??
                      true)
              ? trans("Billing address is incomplete")
              : checkoutSession.billingDetails!.billingAddress?.addressFull())
          : trans("Add billing & shipping details"),
      action: _actionCheckoutDetails,
      showBorderBottom: true,
    );
  }

  _actionCheckoutDetails() {
    routeTo(CheckoutDetailsPage.path, onPop: (value) {
      updateState(CheckoutConfirmationPage.path, data: {"refresh": true});
    });
  }
}
