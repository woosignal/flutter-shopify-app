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
import '/app/models/shopify/shipping_type.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/shopify_shipping_method.dart';
import 'package:woosignal_shopify_api/models/shopify_shipping_zone.dart';
import '/app/models/shopify/cart.dart';

class CheckoutShippingTypePage extends NyStatefulWidget {
  static String path = "/checkout-shipping-type";
  CheckoutShippingTypePage()
      : super(path, child: _CheckoutShippingTypePageState());
}

class _CheckoutShippingTypePageState extends NyState<CheckoutShippingTypePage> {
  _CheckoutShippingTypePageState();

  final List<ShippingMethod> _shippingMethods = [];
  ShopifyShippingZone? _shipping;

  @override
  boot() async {
    await _getShippingMethods();
  }

  _getShippingMethods() async {
    _shipping = await appWooSignalShopify((api) => api.fetchShippingZones());

    CheckoutSession checkoutSession = CheckoutSession.getInstance;

    if (_shipping == null) {
      return;
    }

    List<ShippingZones> shippingZones =
        (_shipping!.shippingZones ?? []).where((shippingZone) {
      Countries? shippingZones = shippingZone.countries.firstWhere(
        (country) {
          if (country?.code ==
              checkoutSession.billingDetails?.shippingAddress?.customerCountry
                  ?.countryCode) {
            if ((country?.provinces ?? []).isNotEmpty) {
              String provinceCode = checkoutSession.billingDetails
                      ?.shippingAddress?.customerCountry?.state?.code ??
                  "";

              if (provinceCode.isNotEmpty) {
                List<String> provinceMeta = provinceCode.split(":");
                if (provinceMeta.isNotEmpty) {
                  String customerProvinceCode = provinceMeta.last;
                  Provinces? province = country?.provinces.firstWhere(
                      (province) => province?.code == customerProvinceCode,
                      orElse: () => null);

                  if (province != null) {
                    CheckoutSession.getInstance.tax = province.tax;
                    CheckoutSession.getInstance.taxName = province.taxName;
                    return true;
                  }
                  return false;
                }
              }
            }

            CheckoutSession.getInstance.tax = country?.tax;
            CheckoutSession.getInstance.taxName = country?.taxName;
            return true;
          }
          return false;
        },
        orElse: () => null,
      );
      if (shippingZones != null) {
        return true;
      }
      return false;
    }).toList();

    double cartTotal =
        parseWcPrice(await checkoutSession.total(withFormat: false));
    List<CartLineItem> cart = await Cart.getInstance.getCart();

    for (var shippingZone in shippingZones) {
      // Price base shipping
      shippingZone.priceBasedShippingRates?.where((priceBasedShipping) {
        if (priceBasedShipping.minOrderSubtotal == null &&
            priceBasedShipping.maxOrderSubtotal == null) {
          return true;
        }

        String? minOrderSubtotal = '0.00';
        String? maxOrderSubtotal;

        if (priceBasedShipping.minOrderSubtotal != null) {
          minOrderSubtotal = priceBasedShipping.minOrderSubtotal;
        }

        if (priceBasedShipping.maxOrderSubtotal != null) {
          maxOrderSubtotal = priceBasedShipping.maxOrderSubtotal;
        }

        if (cartTotal >= parseWcPrice(minOrderSubtotal) &&
            (maxOrderSubtotal != null
                ? parseWcPrice(maxOrderSubtotal) >= cartTotal
                : true)) {
          return true;
        }

        return false;
      }).forEach((e) {
        _shippingMethods
            .add(ShippingMethod(code: e.name, price: e.price, title: e.name));
      });

      // weight base shipping
      shippingZone.weightBasedShippingRates?.where((weightBasedShipping) {
        if (weightBasedShipping.weightLow == null &&
            weightBasedShipping.weightHigh == null) {
          return true;
        }

        double? cartMaxWeight = cart
            .map((e) => e.weight)
            .toList()
            .reduce((a, b) => (a ?? 0) + (b ?? 0));

        int? weightLow = 0;
        int? weightHigh;

        if (weightBasedShipping.weightLow != null) {
          weightLow = weightBasedShipping.weightLow;
        }

        if (weightBasedShipping.weightHigh != null) {
          weightHigh = weightBasedShipping.weightHigh;
        }

        if ((cartMaxWeight ?? 0) >= (weightLow ?? 0) &&
            (weightHigh != null ? weightHigh <= (cartMaxWeight ?? 0) : true)) {
          return true;
        }

        return false;
      }).forEach((e) {
        _shippingMethods.add(ShippingMethod(price: e.price, title: e.name));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(trans("Shipping Methods")),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  child: Center(
                    child: Image.asset(
                      getImageAsset('shipping_icon.png'),
                      height: 100,
                      color: (Theme.of(context).brightness == Brightness.light)
                          ? null
                          : Colors.white,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  padding: EdgeInsets.only(top: 20),
                ),
                SizedBox(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: afterLoad(
                              child: () => NyListView.separated(
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                      color: Colors.black12,
                                    ),
                                    child:
                                        (BuildContext context, shippingMethod) {
                                      shippingMethod as ShippingMethod;

                                      return ListTile(
                                        contentPadding: EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                        ),
                                        title: Text(
                                          shippingMethod.title ?? "",
                                        ),
                                        selected: true,
                                        subtitle: RichText(
                                          text: TextSpan(
                                            text: '',
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: <TextSpan>[
                                              TextSpan(
                                                text:
                                                    "${trans("Price")}: ${formatStringCurrency(total: shippingMethod.price)}",
                                              ),
                                            ],
                                          ),
                                        ),
                                        trailing: (CheckoutSession.getInstance
                                                        .shippingType !=
                                                    null &&
                                                CheckoutSession
                                                        .getInstance
                                                        .shippingType
                                                        ?.shippingMethod ==
                                                    shippingMethod
                                            ? Icon(Icons.check)
                                            : null),
                                        onTap: () => _handleCheckoutTapped(shippingMethod),
                                      );
                                    },
                                    empty: Text(
                                      trans(
                                          "Shipping is not supported for your location, sorry"),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    data: () async {
                                      return _shippingMethods;
                                    },
                                  )),
                        ),
                        LinkButton(
                          title: trans("CANCEL"),
                          action: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColor.get(context).backgroundContainer,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow:
                          (Theme.of(context).brightness == Brightness.light)
                              ? wsBoxShadow()
                              : null,
                    ),
                    padding: EdgeInsets.all(8),
                  ),
                  height: (constraints.maxHeight - constraints.minHeight) * 0.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _handleCheckoutTapped(ShippingMethod shippingMethod) async {
    ShippingType shippingType = ShippingType();
    shippingType.shippingMethod = shippingMethod;

    CheckoutSession.getInstance.shippingType = shippingType;

    Navigator.pop(context);
  }
}
