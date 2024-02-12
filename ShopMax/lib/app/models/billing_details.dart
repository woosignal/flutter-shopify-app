//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import '/app/models/customer_address.dart';
import '/app/models/shopify/checkout_session.dart';

class BillingDetails {
  CustomerAddress? billingAddress;
  CustomerAddress? shippingAddress;
  bool? rememberDetails;

  BillingDetails();

  /// Initialize the session
  void initSession() {
    billingAddress = CustomerAddress();
    billingAddress?.initAddress();
    shippingAddress = CustomerAddress();
    shippingAddress?.initAddress();
  }

  double? taxAmount() {
    if (shippingAddress == null || shippingAddress?.customerCountry == null) {
      return null;
    }
    CheckoutSession checkoutSession = CheckoutSession.getInstance;
    double? amount = checkoutSession.tax;
    // if (shippingAddress?.customerCountry?.hasState() ?? false) {
    //   amount = shippingAddress?.country?.provinces.tax;
    // }
    return amount;
  }

  /// Create a map of the billing details for Stripe
  Map<String, dynamic> createStripeDetails() => {
        'address': {
          if (billingAddress?.addressLine != null)
            'line1': billingAddress?.addressLine,
          if (billingAddress?.city != null) 'city': billingAddress?.city,
          if (billingAddress?.postalCode != null)
            'postal_code': billingAddress?.postalCode,
          if (billingAddress?.customerCountry?.state?.name != null)
            'state': billingAddress?.customerCountry?.state?.name,
          if (billingAddress?.customerCountry?.countryCode != null)
            'country': billingAddress?.customerCountry?.countryCode,
        },
        'shipping': {
          if (shippingAddress?.nameFull() != null)
            'name': shippingAddress?.nameFull(),
          if (shippingAddress?.city != null) 'city': shippingAddress?.city,
          if (shippingAddress?.postalCode != null)
            'postal_code': shippingAddress?.postalCode,
          if (shippingAddress?.customerCountry?.state?.name != null)
            'state': shippingAddress?.customerCountry?.state?.name,
          if (shippingAddress?.customerCountry?.countryCode != null)
            'country': shippingAddress?.customerCountry?.countryCode,
        },
        if (billingAddress?.emailAddress != null)
          'email': billingAddress?.emailAddress,
        if (billingAddress?.nameFull() != null)
          'name': billingAddress?.nameFull(),
        if (billingAddress?.phoneNumber != null)
          'phone': billingAddress?.phoneNumber
      };

  /// Create a map of the shipping address for Stripe
  Map<String, String?> getShippingAddressStripe() => {
        "name": shippingAddress?.nameFull(),
        "line1": shippingAddress!.addressLine,
        "city": shippingAddress!.city,
        "postal_code": shippingAddress!.postalCode,
        "country": (shippingAddress?.customerCountry?.name ?? "")
      };

  fromWpMeta(Map<String, String> data) async {
    final Map<String, String> shippingDetailsWpMeta = <String, String>{},
        billingDetailsWpMeta = <String, String>{};

    shippingDetailsWpMeta.addEntries(data.entries
        .where((element) => element.key.startsWith("shipping_"))
        .map((shippingMeta) => MapEntry(
            shippingMeta.key.replaceAll("shipping_", ""), shippingMeta.value)));
    billingDetailsWpMeta.addEntries(data.entries
        .where((element) => element.key.startsWith("billing_"))
        .map((billingMeta) => MapEntry(
            billingMeta.key.replaceAll("billing_", ""), billingMeta.value)));

    CustomerAddress billingCustomerAddress = CustomerAddress();
    await billingCustomerAddress.fromWpMetaData(billingDetailsWpMeta);

    CustomerAddress shippingCustomerAddress = CustomerAddress();
    await shippingCustomerAddress.fromWpMetaData(shippingDetailsWpMeta);

    billingAddress = billingCustomerAddress;
    shippingAddress = shippingCustomerAddress;
  }
}
