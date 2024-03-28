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
import 'package:firebase_messaging/firebase_messaging.dart';
import '/app/models/cart.dart';
import '/app/models/notification_item.dart';
import '/app/models/billing_details.dart';
import '/app/models/checkout_session.dart' as shopify;
import '/app/models/default_shipping.dart';
import '/app/models/payment_type.dart';
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
import '/resources/themes/styles/color_styles.dart';
import 'package:flutter/services.dart' show rootBundle;

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
          symbol:
              AppHelper.instance.shopifyAppConfig?.currencyMeta?.symbolNative,
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

checkoutShopify(
    Function(String total, BillingDetails? billingDetails, Cart cart)
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

Future<List<String>> getWishlistProducts() async {
  List<String> currentProductsJSON =
      await (NyStorage.readCollection(StorageKey.wishlistProducts));

  return currentProductsJSON;
}

Future<bool> hasAddedWishlistProduct(int? productId) async {
  List<String> favouriteProducts = await getWishlistProducts();
  return favouriteProducts.contains(productId.toString());
}

saveWishlistProduct({required String productId}) async {
  await NyStorage.addToCollection(StorageKey.wishlistProducts,
      item: productId, allowDuplicates: false);
}

removeWishlistProduct({required String productId}) async {
  await NyStorage.deleteFromCollectionWhere((value) => value == productId,
      key: StorageKey.wishlistProducts);
}

Future<BillingDetails> billingDetailsFromShopifyCustomerInfoResponse(
    AuthCustomerInfo customerInfo) async {
  BillingDetails billingDetails = BillingDetails();
  billingDetails.initSession();

  billingDetails.billingAddress?.firstName = customerInfo.firstName;
  billingDetails.billingAddress?.lastName = customerInfo.lastName;

  billingDetails.billingAddress?.addressLine =
      customerInfo.defaultAddress?.address1;
  billingDetails.billingAddress?.city = customerInfo.defaultAddress?.city;
  billingDetails.billingAddress?.phoneNumber =
      customerInfo.defaultAddress?.phone;
  billingDetails.billingAddress?.emailAddress = customerInfo.email;

  billingDetails.billingAddress?.customerCountry?.name =
      customerInfo.defaultAddress?.country;
  billingDetails.billingAddress?.customerCountry?.countryCode =
      customerInfo.defaultAddress?.countryCode?.toLowerCase();
  billingDetails.billingAddress?.customerCountry?.state?.name =
      customerInfo.defaultAddress?.province;
  billingDetails.billingAddress?.customerCountry?.state?.code =
      customerInfo.defaultAddress?.provinceCode;

  billingDetails.billingAddress?.postalCode = customerInfo.defaultAddress?.zip;

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

class NyNotification {
  static final String _storageKey = "app_notifications";

  static String storageKey() => _storageKey;

  /// Add a notification
  static addNotification(String title, String message,
      {String? id, Map<String, dynamic>? meta}) async {
    NotificationItem notificationItem = NotificationItem.fromJson({
      "id": id,
      "title": title,
      "message": message,
      "meta": meta,
      "has_read": false,
      "created_at": DateTime.now().toDateTimeString()
    });
    await NyStorage.addToCollection(storageKey(),
        item: notificationItem, allowDuplicates: false);
  }

  /// Get all notifications
  static Future<List<NotificationItem>> allNotifications() async {
    List<NotificationItem> notifications =
        await NyStorage.readCollection("app_notifications");
    String? userId = await WooSignalShopify.authUserId();
    notifications.removeWhere((notification) {
      if (notification.meta != null &&
          notification.meta!.containsKey('user_id')) {
        if (notification.meta?['user_id'] != userId) {
          return true;
        }
      }
      return false;
    });

    await NyStorage.saveCollection(storageKey(), notifications);

    return notifications;
  }

  /// Get all notifications not read
  static Future<List<NotificationItem>> allNotificationsNotRead() async {
    List<NotificationItem> notifications = await allNotifications();
    return notifications.where((element) => element.hasRead == false).toList();
  }

  /// Mark notification as read by index
  static markReadByIndex(int index) async {
    await NyStorage.updateCollectionByIndex(index, (item) {
      item as NotificationItem;
      item.hasRead = true;
      return item;
    }, key: storageKey());
  }

  /// Mark all notifications as read
  static markReadAll() async {
    List<NotificationItem> notifications = await allNotifications();
    for (var i = 0; i < notifications.length; i++) {
      await markReadByIndex(i);
    }
  }

  /// Clear all notifications
  static clearAllNotifications() async {
    await NyStorage.deleteCollection(storageKey());
  }

  /// Render notifications
  static Widget renderNotifications(
      Widget Function(List<NotificationItem> notificationItems) child,
      {Widget? loading}) {
    return NyFutureBuilder(
        future: allNotifications(),
        child: (context, data) {
          if (data == null) {
            return SizedBox.shrink();
          }
          return child(data);
        },
        loading: loading);
  }

  /// Render list of notifications
  static Widget renderListNotifications(
      Widget Function(NotificationItem notificationItems) child,
      {Widget? loading}) {
    return NyFutureBuilder(
        future: allNotifications(),
        child: (context, data) {
          if (data == null) {
            return SizedBox.shrink();
          }
          return NyListView(child: (context, item) {
            item as NotificationItem;
            return child(item);
          }, data: () async {
            return data.reversed.toList();
          });
        },
        loading: loading);
  }

  /// Render list of notifications
  static Widget renderListNotificationsWithSeparator(
      Widget Function(NotificationItem notificationItems) child,
      {Widget? loading}) {
    return NyFutureBuilder(
        future: allNotifications(),
        child: (context, data) {
          if (data == null) {
            return SizedBox.shrink();
          }
          return NyListView.separated(
            child: (context, item) {
              item as NotificationItem;
              return child(item);
            },
            data: () async {
              return data.reversed.toList();
            },
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.grey.shade100,
              );
            },
          );
        },
        loading: loading);
  }
}

Future<bool> canSeeRemoteMessage(RemoteMessage message) async {
  if (!message.data.containsKey('user_id')) {
    return true;
  }

  String userId = message.data['user_id'];

  if (WooSignalShopify.authUserLoggedIn() != true) {
    return false;
  }

  String? currentUserId = await WooSignalShopify.authUserId();
  if (currentUserId != userId) {
    return false;
  }
  return true;
}

bool isFirebaseEnabled() {
  bool? firebaseFcmIsEnabled =
      AppHelper.instance.shopifyAppConfig?.firebaseFcmIsEnabled;
  firebaseFcmIsEnabled ??= getEnv('FCM_ENABLED', defaultValue: false);

  return firebaseFcmIsEnabled == true;
}
