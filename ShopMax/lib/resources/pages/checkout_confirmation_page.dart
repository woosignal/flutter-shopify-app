//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/app/models/checkout_session.dart';
import '/app/models/payment_type.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/app_loader_widget.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/checkout_payment_type_widget.dart';
import '/resources/widgets/checkout_shipping_type_widget.dart';
import '/resources/widgets/checkout_store_heading_widget.dart';
import '/resources/widgets/checkout_user_details_widget.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/woosignal_app.dart';

class CheckoutConfirmationPage extends NyStatefulWidget {
  static String path = "/checkout";
  CheckoutConfirmationPage()
      : super(path, child: CheckoutConfirmationPageState());
}

class CheckoutConfirmationPageState extends NyState<CheckoutConfirmationPage> {
  CheckoutConfirmationPageState();

  bool _showFullLoader = false;
  final WooSignalApp? _wooSignalApp = AppHelper.instance.shopifyAppConfig;

  @override
  init() async {
    CheckoutSession.getInstance.coupon = null;
    List<PaymentType?> paymentTypes = await getShopifyPaymentTypes();

    if (CheckoutSession.getInstance.paymentType == null &&
        paymentTypes.isNotEmpty) {
      CheckoutSession.getInstance.paymentType = paymentTypes.firstWhere(
          (paymentType) => paymentType?.id == 1,
          orElse: () => paymentTypes.first);
    }
  }

  @override
  stateUpdated(dynamic data) async {
    if (data == null) return;
    if (data['reloadState'] != null) {
      reloadState(showLoader: data['reloadState']);
    }
    if (data['refresh'] != null) {
      setState(() {});
    }
  }

  /// Reloads the state of the page
  reloadState({required bool showLoader}) {
    setState(() {
      _showFullLoader = showLoader;
    });
  }

  @override
  Widget build(BuildContext context) {
    CheckoutSession checkoutSession = CheckoutSession.getInstance;

    if (_showFullLoader == true) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AppLoaderWidget(),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  "${trans("One moment")}...",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(trans("Checkout")),
            Text(_wooSignalApp?.appName ?? getEnv('APP_NAME'))
                .bodySmall(context),
          ],
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            CheckoutSession.getInstance.coupon = null;
            Navigator.pop(context);
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeAreaWidget(
        child: Container(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  CheckoutStoreHeadingWidget(),
                  CheckoutUserDetailsWidget(
                    context: context,
                    checkoutSession: checkoutSession,
                  ),
                  CheckoutPaymentTypeWidget(
                    context: context,
                    checkoutSession: checkoutSession,
                  ),
                  CheckoutShippingTypeWidget(
                    context: context,
                    checkoutSession: checkoutSession,
                    wooSignalApp: _wooSignalApp,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: wsBoxShadow(),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    margin: EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Icon(Icons.receipt),
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                              ),
                              Text(trans("Order Summary")).fontWeightBold()
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(padding: EdgeInsets.only(top: 16)),
                            ShopifyCheckoutSubtotal(
                              title: trans("Subtotal"),
                            ),
                            CheckoutMetaLine(
                              title: trans("Shipping fee"),
                              amount: CheckoutSession
                                          .getInstance.shippingType ==
                                      null
                                  ? trans("Select shipping")
                                  : CheckoutSession.getInstance.shippingType!
                                      .getTotal(withFormatting: true),
                            ),
                            ShopifyCheckoutTaxTotal(),
                            Padding(
                                padding:
                                    EdgeInsets.only(top: 8, left: 8, right: 8)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  text:
                                      '${trans('By completing this order, I agree to all')} ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontSize: 12,
                                      ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = _openTermsLink,
                                      text: trans("Terms and conditions")
                                          .toLowerCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: ThemeColor.get(context)
                                                .primaryAccent,
                                            fontSize: 12,
                                          ),
                                    ),
                                    TextSpan(
                                      text: ".",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: Colors.black87,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    ShopifyCheckoutTotal(title: trans("Total")),
                    Padding(padding: EdgeInsets.only(bottom: 8)),
                    PrimaryButton(
                      title: isLocked('payment')
                          ? "${trans("PROCESSING")}..."
                          : trans("CHECKOUT"),
                      action: () async {
                        lockRelease('payment', perform: () async {
                          await _handleCheckout();
                        });
                      },
                    ),
                  ],
                ),
              )
            ],
          ).expanded(),
        ),
      ),
    );
  }

  _openTermsLink() => openBrowserTab(
      url: AppHelper.instance.shopifyAppConfig?.appTermsLink ?? "");

  _handleCheckout() async {
    CheckoutSession checkoutSession = CheckoutSession.getInstance;
    if (checkoutSession.billingDetails!.billingAddress == null) {
      showToastNotification(
        context,
        title: trans("Oops"),
        description:
            trans("Please select add your billing/shipping address to proceed"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.local_shipping,
      );
      return;
    }

    if (checkoutSession.billingDetails?.billingAddress?.hasMissingFields() ??
        true) {
      showToastNotification(
        context,
        title: trans("Oops"),
        description: trans("Your billing/shipping details are incomplete"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.local_shipping,
      );
      return;
    }

    if (!(_wooSignalApp?.disableShipping ?? false) &&
        checkoutSession.shippingType == null) {
      showToastNotification(
        context,
        title: trans("Oops"),
        description: trans("Please select a shipping method to proceed"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.local_shipping,
      );
      return;
    }

    if (checkoutSession.paymentType == null) {
      showToastNotification(
        context,
        title: trans("Oops"),
        description: trans("Please select a payment method to proceed"),
        style: ToastNotificationStyleType.WARNING,
        icon: Icons.payment,
      );
      return;
    }

    bool appStatus = await (appWooSignalShopify((api) => api.checkAppStatus()));

    if (!appStatus) {
      showToastNotification(context,
          title: trans("Sorry"),
          description: trans("Retry later"),
          style: ToastNotificationStyleType.INFO,
          duration: Duration(seconds: 3));
      return;
    }

    try {
      await checkoutSession.paymentType!.pay(context);
    } on Exception catch (e) {
      NyLogger.debug(e.toString());
    }
  }
}
