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
import '/app/models/billing_details.dart';
import '/app/models/checkout_session.dart';
import '/app/models/customer_address.dart';
import '/app/models/customer_country.dart';
import '/bootstrap/helpers.dart';
import 'customer_countries_page.dart';
import '/resources/widgets/app_loader_widget.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/customer_address_input.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/switch_address_tab.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:validated/validated.dart' as validate;
import 'package:woosignal_shopify_api/models/response/auth/auth_customer_address_updated.dart'
    as auth_customer_address_updated;
import 'package:woosignal_shopify_api/models/response/auth/auth_customer_info.dart';
import 'package:woosignal_shopify_api/models/response/shopify_country_response.dart';
import '/app/models/default_shipping.dart';

class CheckoutDetailsPage extends NyStatefulWidget {
  CheckoutDetailsPage() : super(path, child: _CheckoutDetailsPageState());

  static String path = "/checkout-details";
}

class _CheckoutDetailsPageState extends NyState<CheckoutDetailsPage> {
  _CheckoutDetailsPageState();

  bool? _hasDifferentShippingAddress = false,
      valRememberDetails = true,
      isLoggedIn;
  int activeTabIndex = 0;

  // TEXT CONTROLLERS
  final TextEditingController
      // billing
      _txtBillingFirstName = TextEditingController(),
      _txtBillingLastName = TextEditingController(),
      _txtBillingAddressLine = TextEditingController(),
      _txtBillingCity = TextEditingController(),
      _txtBillingPostalCode = TextEditingController(),
      _txtBillingEmailAddress = TextEditingController(),
      _txtBillingPhoneNumber = TextEditingController(),
      // shipping
      _txtShippingFirstName = TextEditingController(),
      _txtShippingLastName = TextEditingController(),
      _txtShippingAddressLine = TextEditingController(),
      _txtShippingCity = TextEditingController(),
      _txtShippingPostalCode = TextEditingController(),
      _txtShippingEmailAddress = TextEditingController();

  CustomerCountry? _billingCountry, _shippingCountry;

  Widget? activeTab;

  Widget tabShippingDetails() => CustomerAddressInput(
        txtControllerFirstName: _txtShippingFirstName,
        txtControllerLastName: _txtShippingLastName,
        txtControllerAddressLine: _txtShippingAddressLine,
        txtControllerCity: _txtShippingCity,
        txtControllerPostalCode: _txtShippingPostalCode,
        txtControllerEmailAddress: _txtShippingEmailAddress,
        customerCountry: _shippingCountry,
        onTapCountry: () => _navigateToSelectCountry(type: "shipping"),
      );

  Widget tabBillingDetails() => CustomerAddressInput(
        txtControllerFirstName: _txtBillingFirstName,
        txtControllerLastName: _txtBillingLastName,
        txtControllerAddressLine: _txtBillingAddressLine,
        txtControllerCity: _txtBillingCity,
        txtControllerPostalCode: _txtBillingPostalCode,
        txtControllerEmailAddress: _txtBillingEmailAddress,
        txtControllerPhoneNumber: _txtBillingPhoneNumber,
        customerCountry: _billingCountry,
        onTapCountry: () => _navigateToSelectCountry(type: "billing"),
      );

  List<ShopifyCountry> countries = [];

  @override
  boot() async {
    isLoggedIn = WooSignalShopify.authUserLoggedIn();

    if (isLoggedIn == true) {
      await _fetchUserDetails();
      return;
    }

    if (CheckoutSession.getInstance.billingDetails?.billingAddress == null) {
      CheckoutSession.getInstance.billingDetails!.initSession();
      CheckoutSession.getInstance.billingDetails!.shippingAddress!
          .initAddress();
      CheckoutSession.getInstance.billingDetails!.billingAddress?.initAddress();
    }
    BillingDetails billingDetails = CheckoutSession.getInstance.billingDetails!;
    _setFieldsFromCustomerAddress(billingDetails.billingAddress,
        type: "billing");
    _setFieldsFromCustomerAddress(billingDetails.shippingAddress,
        type: "shipping");

    _hasDifferentShippingAddress =
        CheckoutSession.getInstance.shipToDifferentAddress;
    valRememberDetails = billingDetails.rememberDetails ?? true;
    if (valRememberDetails == true) {
      await _setCustomersDetailsFromRemember();
      return;
    }
  }

  _setCustomersDetailsFromRemember() async {
    CustomerAddress? sfCustomerBillingAddress =
        await CheckoutSession.getInstance.getBillingAddress();
    _setFieldsFromCustomerAddress(sfCustomerBillingAddress, type: "billing");

    CustomerAddress? sfCustomerShippingAddress =
        await CheckoutSession.getInstance.getShippingAddress();
    _setFieldsFromCustomerAddress(sfCustomerShippingAddress, type: "shipping");
    setState(() {});
  }

  _setFieldsFromCustomerAddress(CustomerAddress? customerAddress,
      {required String type}) {
    assert(type != "");
    if (customerAddress == null) {
      return;
    }
    _setFields(
      firstName: customerAddress.firstName,
      lastName: customerAddress.lastName,
      addressLine: customerAddress.addressLine,
      city: customerAddress.city,
      postalCode: customerAddress.postalCode,
      emailAddress: customerAddress.emailAddress,
      phoneNumber: customerAddress.phoneNumber,
      customerCountry: customerAddress.customerCountry,
      type: type,
    );
  }

  _setFields(
      {required String? firstName,
      required String? lastName,
      required String? addressLine,
      required String? city,
      required String? postalCode,
      required String? emailAddress,
      required String? phoneNumber,
      required CustomerCountry? customerCountry,
      String? type}) {
    if (type == "billing") {
      _txtBillingFirstName.text = firstName ?? "";
      _txtBillingLastName.text = lastName ?? "";
      _txtBillingAddressLine.text = addressLine ?? "";
      _txtBillingCity.text = city ?? "";
      _txtBillingPostalCode.text = postalCode ?? "";
      _txtBillingPhoneNumber.text = phoneNumber ?? "";
      _txtBillingEmailAddress.text = emailAddress ?? "";
    } else if (type == "shipping") {
      _txtShippingFirstName.text = firstName ?? "";
      _txtShippingLastName.text = lastName ?? "";
      _txtShippingAddressLine.text = addressLine ?? "";
      _txtShippingCity.text = city ?? "";
      _txtShippingPostalCode.text = postalCode ?? "";
      _txtShippingEmailAddress.text = emailAddress ?? "";
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          trans("Billing & Shipping Details"),
        ),
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: (isLoading() || isLocked('load_shipping_info'))
            ? AppLoaderWidget()
            : GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (_hasDifferentShippingAddress!)
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Padding(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        SwitchAddressTab(
                                            title: trans("Billing Details"),
                                            currentTabIndex: activeTabIndex,
                                            type: "billing",
                                            onTapAction: () => setState(() {
                                                  activeTabIndex = 0;
                                                  activeTab =
                                                      tabBillingDetails();
                                                })),
                                        SwitchAddressTab(
                                            title: trans("Shipping Address"),
                                            currentTabIndex: activeTabIndex,
                                            type: "shipping",
                                            onTapAction: () => setState(() {
                                                  activeTabIndex = 1;
                                                  activeTab =
                                                      tabShippingDetails();
                                                })),
                                      ],
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                  ),
                                ],
                              ),
                              height: 60,
                            ),
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  color: ThemeColor.get(context)
                                      .backgroundContainer,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: (Theme.of(context).brightness ==
                                          Brightness.light)
                                      ? wsBoxShadow()
                                      : null,
                                ),
                                padding:
                                    EdgeInsets.only(left: 8, right: 8, top: 8),
                                margin: EdgeInsets.only(top: 8),
                                child: (activeTab ?? tabBillingDetails())),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 160,
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                trans("Ship to a different address?"),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Checkbox(
                                value: _hasDifferentShippingAddress,
                                onChanged: _onChangeShipping,
                              )
                            ],
                          ),
                          if (isLoggedIn == true)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  trans("Remember my details"),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Checkbox(
                                  value: valRememberDetails,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      valRememberDetails = value;
                                    });
                                  },
                                )
                              ],
                            ),
                          PrimaryButton(
                            title: trans("USE DETAILS"),
                            action: _useDetailsTapped,
                            isLoading: isLocked('update_shipping'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  _useDetailsTapped() async {
    await lockRelease('update_shipping', perform: () async {
      CustomerAddress customerBillingAddress = _setCustomerAddress(
        firstName: _txtBillingFirstName.text,
        lastName: _txtBillingLastName.text,
        addressLine: _txtBillingAddressLine.text,
        city: _txtBillingCity.text,
        postalCode: _txtBillingPostalCode.text,
        phoneNumber: _txtBillingPhoneNumber.text,
        emailAddress: _txtBillingEmailAddress.text.trim(),
        customerCountry: _billingCountry,
      );

      CheckoutSession.getInstance.billingDetails!.shippingAddress =
          customerBillingAddress;
      CheckoutSession.getInstance.billingDetails!.billingAddress =
          customerBillingAddress;

      if (_hasDifferentShippingAddress == true) {
        CustomerAddress customerShippingAddress = _setCustomerAddress(
            firstName: _txtShippingFirstName.text,
            lastName: _txtShippingLastName.text,
            addressLine: _txtShippingAddressLine.text,
            city: _txtShippingCity.text,
            postalCode: _txtShippingPostalCode.text,
            emailAddress: _txtShippingEmailAddress.text.trim(),
            customerCountry: _shippingCountry);

        if (customerShippingAddress.hasMissingFields()) {
          showToastNotification(
            context,
            title: trans("Oops"),
            description: trans(
                "Invalid shipping address, please check your shipping details"),
            style: ToastNotificationStyleType.WARNING,
          );
          return;
        }

        CheckoutSession.getInstance.billingDetails!.shippingAddress =
            customerShippingAddress;
      }

      BillingDetails billingDetails =
          CheckoutSession.getInstance.billingDetails!;

      // Email validation
      String billingEmail = billingDetails.billingAddress!.emailAddress!;
      String shippingEmail = billingDetails.shippingAddress!.emailAddress!;
      // Billing email is required for Stripe
      if (billingEmail.isEmpty || !validate.isEmail(billingEmail)) {
        showToastOops(description: trans("Please enter a valid billing email"));
        return;
      }

      if (shippingEmail.isNotEmpty && !validate.isEmail(shippingEmail)) {
        showToastOops(
            description: trans("Please enter a valid shipping email"));
        return;
      }

      // Update Shopify shipping info for user
      if (isLoggedIn == true) {
        auth_customer_address_updated.AuthCustomerAddressUpdated?
            authCustomerAddressUpdated =
            await appWooSignalShopify((api) => api.authCustomerUpdateAddress(
                  address1: _txtBillingAddressLine.text,
                  city: _txtBillingCity.text,
                  country: _billingCountry?.name,
                  firstName: _txtBillingFirstName.text,
                  lastName: _txtBillingLastName.text,
                  phone: _txtBillingPhoneNumber.text,
                  zip: _txtBillingPostalCode.text,
                ));

        if (authCustomerAddressUpdated == null) {
          showToastWarning(description: trans("Something went wrong"));
          return;
        }

        if (authCustomerAddressUpdated.isSuccessful() == false) {
          showToastWarning(description: trans("Something went wrong"));
          return;
        }
      }

      if (valRememberDetails == true) {
        await CheckoutSession.getInstance.saveBillingAddress();
        await CheckoutSession.getInstance.saveShippingAddress();
      } else {
        await CheckoutSession.getInstance.clearBillingAddress();
        await CheckoutSession.getInstance.clearShippingAddress();
      }

      CheckoutSession.getInstance.billingDetails?.rememberDetails =
          valRememberDetails;
      CheckoutSession.getInstance.shipToDifferentAddress =
          _hasDifferentShippingAddress;

      CheckoutSession.getInstance.shippingType = null;
      Navigator.pop(context);
    });
  }

  _onChangeShipping(bool? value) async {
    _hasDifferentShippingAddress = value;
    activeTabIndex = 1;
    activeTab = value == true ? tabShippingDetails() : tabBillingDetails();

    CustomerAddress? sfCustomerShippingAddress =
        await CheckoutSession.getInstance.getShippingAddress();
    if (sfCustomerShippingAddress == null) {
      _setFields(
          firstName: "",
          lastName: "",
          addressLine: "",
          city: "",
          postalCode: "",
          phoneNumber: "",
          emailAddress: "",
          customerCountry: CustomerCountry());
    }
    setState(() {});
  }

  CustomerAddress _setCustomerAddress(
      {required String firstName,
      required String lastName,
      required String addressLine,
      required String city,
      required String postalCode,
      required String emailAddress,
      String? phoneNumber,
      required CustomerCountry? customerCountry}) {
    CustomerAddress customerShippingAddress = CustomerAddress();
    customerShippingAddress.firstName = firstName;
    customerShippingAddress.lastName = lastName;
    customerShippingAddress.addressLine = addressLine;
    customerShippingAddress.city = city;
    customerShippingAddress.postalCode = postalCode;
    if (phoneNumber != null && phoneNumber != "") {
      customerShippingAddress.phoneNumber = phoneNumber;
    }
    customerShippingAddress.customerCountry = customerCountry;
    customerShippingAddress.emailAddress = emailAddress;
    return customerShippingAddress;
  }

  _navigateToSelectCountry({required String type}) {
    routeTo(CustomerCountriesPage.path, onPop: (value) {
      if (value == null) return;

      ShopifyCountry shopifyCountry = value as ShopifyCountry;

      DefaultShipping defaultShipping = DefaultShipping(
        shopifyCountry: shopifyCountry,
        code: shopifyCountry.code ?? "",
        country: shopifyCountry.name,
        states: (shopifyCountry.provinces ?? []).map((province) {
          return DefaultShippingState(code: province.code, name: province.name);
        }).toList(),
      );

      if (type == "billing") {
        _billingCountry = CustomerCountry.fromDefaultShipping(
            defaultShipping: defaultShipping);
        activeTab = tabBillingDetails();
      } else if (type == "shipping") {
        _shippingCountry = CustomerCountry.fromDefaultShipping(
            defaultShipping: defaultShipping);
        activeTab = tabShippingDetails();
      }
      setState(() {});
    });
  }

  _fetchUserDetails() async {
    AuthCustomerInfo? authCustomerInfo =
        await appWooSignalShopify((api) => api.authCustomer());
    if (authCustomerInfo == null) {
      showToastNotification(
        context,
        title: trans("Oops!"),
        description: trans("Something went wrong"),
        style: ToastNotificationStyleType.DANGER,
      );
      pop();
      return;
    }

    BillingDetails billingDetails =
        await billingDetailsFromShopifyCustomerInfoResponse(authCustomerInfo);

    _setFieldsFromCustomerAddress(billingDetails.shippingAddress,
        type: "shipping");
    _setFieldsFromCustomerAddress(billingDetails.billingAddress,
        type: "billing");

    setState(() {});
  }
}
