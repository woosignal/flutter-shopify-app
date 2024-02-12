//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_customer_address_updated.dart' as auth_customer_address_updated;
import '/app/models/billing_details.dart';
import '/app/models/customer_address.dart';
import '/app/models/customer_country.dart';
import '/app/models/default_shipping.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/app_loader_widget.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/shopify/customer_address_input.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/shopify/switch_address_tab.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_customer_info.dart';

class AccountShippingDetailsPage extends NyStatefulWidget {
  static String path = "/account-shipping-details";
  AccountShippingDetailsPage()
      : super(path, child: _AccountShippingDetailsPageState());
}

class _AccountShippingDetailsPageState
    extends NyState<AccountShippingDetailsPage> {
  _AccountShippingDetailsPageState();

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
      _txtShippingPostalCode = TextEditingController();

  CustomerCountry? _billingCountry, _shippingCountry;

  Widget? activeTab;

  Widget tabShippingDetails() => CustomerAddressInput(
      txtControllerFirstName: _txtShippingFirstName,
      txtControllerLastName: _txtShippingLastName,
      txtControllerAddressLine: _txtShippingAddressLine,
      txtControllerCity: _txtShippingCity,
      txtControllerPostalCode: _txtShippingPostalCode,
      customerCountry: _shippingCountry,
      onTapCountry: () => _navigateToSelectCountry(type: "shipping"));

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

  @override
  boot() async {
    await _fetchUserDetails();
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
      _billingCountry = customerCountry;
    } else if (type == "shipping") {
      _txtShippingFirstName.text = firstName ?? "";
      _txtShippingLastName.text = lastName ?? "";
      _txtShippingAddressLine.text = addressLine ?? "";
      _txtShippingCity.text = city ?? "";
      _txtShippingPostalCode.text = postalCode ?? "";
      _shippingCountry = customerCountry;
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
        child: isLoading()
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
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                                activeTab = tabBillingDetails();
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
                      margin: EdgeInsets.only(top: 16),
                      height: 160,
                      child: Column(
                        children: <Widget>[
                          PrimaryButton(
                            title: trans("USE DETAILS"),
                            action: _useDetailsTapped,
                            isLoading: isLocked('update_details'),
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
    String billingEmail = _txtBillingEmailAddress.text;

    validate(rules: {
      "Billing email address": [billingEmail, 'email', "${trans("Oops")}|${trans("Please enter a valid shipping email")}"],
    }, onSuccess: () async {

      CustomerAddress userBillingAddress = _setCustomerAddress(
        firstName: _txtBillingFirstName.text,
        lastName: _txtBillingLastName.text,
        addressLine: _txtBillingAddressLine.text,
        city: _txtBillingCity.text,
        postalCode: _txtBillingPostalCode.text,
        phoneNumber: _txtBillingPhoneNumber.text,
        emailAddress: _txtBillingEmailAddress.text.trim(),
        customerCountry: _billingCountry,
      ), userShippingAddress = _setCustomerAddress(
            firstName: _txtShippingFirstName.text,
            lastName: _txtShippingLastName.text,
            addressLine: _txtShippingAddressLine.text,
            city: _txtShippingCity.text,
            postalCode: _txtShippingPostalCode.text,
            customerCountry: _shippingCountry,
          );

      auth_customer_address_updated.AuthCustomerAddressUpdated? authCustomerAddressUpdated = await appWooSignalShopify((api) => api.authCustomerUpdateAddress(
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

      showToastNotification(context,
          title: trans("Success"),
          description: trans("Account updated"),
          style: ToastNotificationStyleType.SUCCESS);

    }, lockRelease: 'update_details');
  }

  CustomerAddress _setCustomerAddress(
      {required String firstName,
      required String lastName,
      required String addressLine,
      required String city,
      required String postalCode,
      String? emailAddress,
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
    Navigator.pushNamed(context, "/customer-countries").then((value) {
      if (value == null) {
        return;
      }

      if (type == "billing") {
        _billingCountry = CustomerCountry.fromDefaultShipping(
            defaultShipping: value as DefaultShipping);
        activeTab = tabBillingDetails();
      } else if (type == "shipping") {
        _shippingCountry = CustomerCountry.fromDefaultShipping(
            defaultShipping: value as DefaultShipping);
        activeTab = tabShippingDetails();
      }
      setState(() {});
    });
  }

  _fetchUserDetails() async {
    AuthCustomerInfo? authCustomerInfo = await appWooSignalShopify((api) => api.authCustomer());

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
