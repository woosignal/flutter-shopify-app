//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'dart:convert';
import 'package:collection/collection.dart' show IterableExtension;
import '/app/models/billing_details.dart';
import '/app/models/shopify/checkout_session.dart'
    as shopify;
import '/app/models/default_shipping.dart';
import '/app/models/payment_type.dart';
import '/app/models/user.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/enums/symbol_position_enums.dart';
import '/bootstrap/extensions.dart';
import '/config/currency.dart';
import '/config/payment_gateways.dart';
import '/config/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:status_alert/status_alert.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_customer_info.dart';
import 'package:woosignal_shopify_api/woosignal_shopify_api.dart';
import '/app/models/shopify/cart.dart';
import '/resources/themes/styles/color_styles.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<User?> getUser() async =>
    (await (NyStorage.read<User>(StorageKey.authUser)));

Future appWooSignalShopify(Function(WooSignalShopify api) api) async {
  return await api(WooSignalShopify.instance);
}

/// helper to find correct color from the [context].
class ThemeColor {
  static ColorStyles get(BuildContext context, {String? themeId}) =>
      nyColorStyle<ColorStyles>(context, themeId: themeId);

  static Color fromHex(String hexColor) => nyHexColor(hexColor);
}

/// helper to set colors on TextStyle
extension ColorsHelper on TextStyle {
  TextStyle setColor(
      BuildContext context, Color Function(BaseColorStyles? color) newColor) {
    return copyWith(color: newColor(ThemeColor.get(context)));
  }
}

extension WooSignalDateTime on DateTime? {
  bool isNewProduct() {
    return isProductNew(this);
  }
}
bool isProductNew(DateTime? createdAt) {
  if (createdAt == null) false;
  try {
    return createdAt.isBetween(
        DateTime.now().subtract(Duration(days: 2)), DateTime.now()) ??
        false;
  } on Exception catch (e) {
    NyLogger.error(e.toString());
  }
  return false;
}

Future<List<PaymentType?>> getShopifyPaymentTypes() async {
  List<PaymentType?> paymentTypes = [];

  if (!appPaymentGateways.contains('Stripe') &&
      AppHelper.instance.shopifyAppConfig?.stripeEnabled == true) {
    paymentTypes.add(paymentTypeList
        .firstWhereOrNull((element) => element.name == "Stripe"));
  }
  if (!appPaymentGateways.contains('PayPal') &&
      AppHelper.instance.shopifyAppConfig?.paypalEnabled == true) {
    paymentTypes.add(paymentTypeList
        .firstWhereOrNull((element) => element.name == "PayPal"));
  }
  if (!appPaymentGateways.contains('CashOnDelivery') &&
      AppHelper.instance.shopifyAppConfig?.codEnabled == true) {
    paymentTypes.add(paymentTypeList
        .firstWhereOrNull((element) => element.name == "CashOnDelivery"));
  }

  for (var appPaymentGateway in appPaymentGateways) {
    paymentTypes.add(paymentTypeList.firstWhereOrNull(
            (paymentTypeList) => paymentTypeList.name == appPaymentGateway));
  }

  return paymentTypes.where((v) => v != null).toList();
}

dynamic envVal(String envVal, {dynamic defaultValue}) =>
    (getEnv(envVal) ?? defaultValue);

PaymentType addPayment(
        {required int id,
        required String name,
        required String description,
        required String assetImage,
        required Function pay}) =>
    PaymentType(
      id: id,
      name: name,
      desc: description,
      assetImage: assetImage,
      pay: pay,
    );

showStatusAlert(context,
    {required String title,
    required String subtitle,
    IconData? icon,
    int? duration}) {
  StatusAlert.show(
    context,
    duration: Duration(seconds: duration ?? 2),
    title: title,
    subtitle: subtitle,
    configuration: IconConfiguration(icon: icon ?? Icons.done, size: 50),
  );
}

String parseHtmlString(String? htmlString) {
  var document = parse(htmlString);
  return parse(document.body!.text).documentElement!.text;
}

String moneyFormatter(double amount) {
  if (AppHelper.instance.shopifyAppConfig != null) {
    MoneyFormatter fmf = MoneyFormatter(
      amount: amount,
      settings: MoneyFormatterSettings(
          symbol: AppHelper.instance.shopifyAppConfig?.currencyMeta?.symbolNative,
          symbolAndNumberSeparator: ""),
    );
    if (appCurrencySymbolPosition == SymbolPositionType.left) {
      return fmf.output.symbolOnLeft;
    } else if (appCurrencySymbolPosition == SymbolPositionType.right) {
      return fmf.output.symbolOnRight;
    }
    return fmf.output.symbolOnLeft;
  }
  return "";
}

String formatDoubleCurrency({required double total}) {
  return moneyFormatter(total);
}

String formatStringCurrency({required String? total}) {
  double tmpVal = 0;
  if (total != null && total != "") {
    tmpVal = parseWcPrice(total);
  }
  return moneyFormatter(tmpVal);
}

String workoutSaleDiscount(
    {required String? salePrice, required String? priceBefore}) {
  double dSalePrice = parseWcPrice(salePrice);
  double dPriceBefore = parseWcPrice(priceBefore);
  return ((dPriceBefore - dSalePrice) * (100 / dPriceBefore))
      .toStringAsFixed(0);
}

openBrowserTab({required String url}) async {
  await FlutterWebBrowser.openWebPage(
    url: url,
    customTabsOptions: CustomTabsOptions(
      defaultColorSchemeParams:
          CustomTabsColorSchemeParams(toolbarColor: Colors.white70),
    ),
  );
}

bool isNumeric(String? str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}

checkoutShopify(Function(String total, BillingDetails? billingDetails, Cart cart)
        completeCheckout) async {
  String cartTotal =
      await shopify.CheckoutSession.getInstance.total(withFormat: false);
  BillingDetails? billingDetails =
      shopify.CheckoutSession.getInstance.billingDetails;
  Cart cart = Cart.getInstance;
  return await completeCheckout(cartTotal, billingDetails, cart);
}

double? strCal({required String sum}) {
  if (sum == "") {
    return 0;
  }
  Parser p = Parser();
  Expression exp = p.parse(sum);
  ContextModel cm = ContextModel();
  return exp.evaluate(EvaluationType.REAL, cm);
}

navigatorPush(BuildContext context,
    {required String routeName,
    Object? arguments,
    bool forgetAll = false,
    int? forgetLast}) {
  if (forgetAll) {
    Navigator.of(context).pushNamedAndRemoveUntil(
        routeName, (Route<dynamic> route) => false,
        arguments: arguments);
  }
  if (forgetLast != null) {
    int count = 0;
    Navigator.of(context).popUntil((route) {
      return count++ == forgetLast;
    });
  }
  Navigator.of(context).pushNamed(routeName, arguments: arguments);
}

double parseWcPrice(String? price) => (double.tryParse(price ?? "0") ?? 0);

class UserAuth {
  UserAuth._privateConstructor();
  static final UserAuth instance = UserAuth._privateConstructor();

  String redirect = "/home";
}

Future<List<DefaultShipping>> getDefaultShipping() async {
  String data =
      await rootBundle.loadString('public/assets/json/default_shipping.json');
  dynamic dataJson = json.decode(data);
  List<DefaultShipping> shipping = [];

  dataJson.forEach((key, value) {
    DefaultShipping defaultShipping =
        DefaultShipping(code: key, country: value['country'], states: []);
    if (value['states'] != null) {
      value['states'].forEach((key1, value2) {
        defaultShipping.states
            .add(DefaultShippingState(code: key1, name: value2));
      });
    }
    shipping.add(defaultShipping);
  });
  return shipping;
}

Future<DefaultShipping?> findCountryMetaForShipping(String countryCode) async {
  List<DefaultShipping> defaultShipping = await getDefaultShipping();
  List<DefaultShipping> shippingByCountryCode =
      defaultShipping.where((element) => element.code == countryCode).toList();
  if (shippingByCountryCode.isNotEmpty) {
    return shippingByCountryCode.first;
  }
  return null;
}

DefaultShippingState? findDefaultShippingStateByCode(
    DefaultShipping defaultShipping, String code) {
  List<DefaultShippingState> defaultShippingStates =
      defaultShipping.states.where((state) => state.code == code).toList();
  if (defaultShippingStates.isEmpty) {
    return null;
  }
  DefaultShippingState defaultShippingState = defaultShippingStates.first;
  return DefaultShippingState(
      code: defaultShippingState.code, name: defaultShippingState.name);
}

String truncateString(String data, int length) {
  return (data.length >= length) ? '${data.substring(0, length)}...' : data;
}

Future<List<dynamic>> getWishlistProducts() async {
  List<dynamic> favouriteProducts = [];
  String? currentProductsJSON =
      await (NyStorage.read(StorageKey.wishlistProducts));
  if (currentProductsJSON != null) {
    favouriteProducts = (jsonDecode(currentProductsJSON)).toList();
  }
  return favouriteProducts;
}

hasAddedWishlistProduct(int? productId) async {
  List<dynamic> favouriteProducts = await getWishlistProducts();
  List<int> productIds =
      favouriteProducts.map((e) => e['id']).cast<int>().toList();
  if (productIds.isEmpty) {
    return false;
  }
  return productIds.contains(productId);
}

saveWishlistProduct({required dynamic product}) async {
  List<dynamic> products = await getWishlistProducts();
  if (products.any((wishListProduct) => wishListProduct['id'] == product!.id) ==
      false) {
    products.add({"id": product!.id});
  }
  String json = jsonEncode(products.map((i) => {"id": i['id']}).toList());
  await NyStorage.store(StorageKey.wishlistProducts, json);
}

removeWishlistProduct({required dynamic product}) async {
  List<dynamic> products = await getWishlistProducts();
  products.removeWhere((element) => element['id'] == product!.id);

  String json = jsonEncode(products.map((i) => {"id": i['id']}).toList());
  await NyStorage.store(StorageKey.wishlistProducts, json);
}

Future<BillingDetails> billingDetailsFromShopifyCustomerInfoResponse(
    AuthCustomerInfo customerInfo) async {
  BillingDetails billingDetails = BillingDetails();
  billingDetails.initSession();

  billingDetails.billingAddress?.firstName = customerInfo.firstName;
  billingDetails.billingAddress?.lastName = customerInfo.lastName;

  billingDetails.billingAddress?.addressLine = customerInfo.defaultAddress?.address1;
  billingDetails.billingAddress?.city = customerInfo.defaultAddress?.city;
  billingDetails.billingAddress?.phoneNumber = customerInfo.defaultAddress?.phone;
  billingDetails.billingAddress?.emailAddress = customerInfo.email;

  billingDetails.billingAddress?.customerCountry?.name = customerInfo.defaultAddress?.country;
  billingDetails.billingAddress?.customerCountry?.countryCode = customerInfo.defaultAddress?.countryCode?.toLowerCase();
  billingDetails.billingAddress?.customerCountry?.state?.name = customerInfo.defaultAddress?.province;
  billingDetails.billingAddress?.customerCountry?.state?.code = customerInfo.defaultAddress?.provinceCode;

  billingDetails.billingAddress?.postalCode = customerInfo.defaultAddress?.zip;

  print(['billingDetails.billingAddress.toJson()', billingDetails.billingAddress?.toJson()]);

  return billingDetails;
}

bool shouldEncrypt() {
  String? encryptKey = getEnv('ENCRYPT_KEY', defaultValue: "");
  if (encryptKey == null || encryptKey == "") {
    return false;
  }
  String? encryptSecret = getEnv('ENCRYPT_KEY', defaultValue: "");
  if (encryptSecret == null || encryptSecret == "") {
    return false;
  }
  return true;
}

Map<String, dynamic>? getThemeColorForTemplate() {
  if (AppHelper.instance.shopifyAppConfig != null) {
    return AppHelper.instance.shopifyAppConfig?.themeColors;
  }
  return {};
}