//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/shopify/account_landing_page.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_customer_info.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_customer_updated_response.dart';

class AccountProfileUpdatePage extends NyStatefulWidget {
  static String path = "/account-update";
  AccountProfileUpdatePage()
      : super(path, child: _AccountProfileUpdatePageState());
}

class _AccountProfileUpdatePageState extends NyState<AccountProfileUpdatePage> {
  _AccountProfileUpdatePageState();

  final TextEditingController _tfFirstName = TextEditingController(),
      _tfLastName = TextEditingController();

  @override
  boot() async {
    await _fetchUserDetails();
  }

  @override
  bool get useSkeletonizer => true;

  @override
  Widget loading(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          trans("Update Details"),
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: TextEditingRow(
                              heading: trans("First Name"),
                              controller: _tfFirstName,
                              keyboardType: TextInputType.text,
                            ),
                          ),
                          Flexible(
                            child: TextEditingRow(
                              heading: trans("Last Name"),
                              controller: _tfLastName,
                              keyboardType: TextInputType.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                    ),
                    PrimaryButton(
                      title: trans("Update Details"),
                      isLoading: isLocked('update_details'),
                      action: _updateDetails,
                    )
                  ],
                ),
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _fetchUserDetails() async {
    AuthCustomerInfo? authCustomerInfo = await appWooSignalShopify((api) => api.authCustomer());
    _tfFirstName.text = authCustomerInfo?.firstName ?? "";
    _tfLastName.text = authCustomerInfo?.lastName ?? "";
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          trans("Update Details"),
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  child: TextEditingRow(
                                    heading: trans("First Name"),
                                    controller: _tfFirstName,
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                                Flexible(
                                  child: TextEditingRow(
                                    heading: trans("Last Name"),
                                    controller: _tfLastName,
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                          ),
                          PrimaryButton(
                            title: trans("Update Details"),
                            isLoading: isLocked('update_details'),
                            action: _updateDetails,
                          )
                        ],
                      ),
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  _updateDetails() async {
    String firstName = _tfFirstName.text;
    String lastName = _tfLastName.text;

    validate(rules: {
      "First name": [firstName, 'not_empty'],
      "Last name": [lastName, 'not_empty'],
    }, onSuccess: () async {

      AuthCustomerUpdateResponse? authCustomerUpdateResponse = await appWooSignalShopify((api) => api.authCustomerUpdate(firstName: firstName, lastName: lastName));

      if (authCustomerUpdateResponse == null) {
        showToastOops(description: 'Failed to update account');
        return;
      }

      if (authCustomerUpdateResponse.status != 200) {
        showToastOops(description: 'Failed to update account');
        return;
      }

      updateState(AccountLandingPage.path, data: {
        'action' : 'refresh-page',
      });

      showToastNotification(context,
          title: trans("Success"),
          description: trans("Account updated"),
          style: ToastNotificationStyleType.SUCCESS);
      pop();

    }, lockRelease: 'update_details');
  }
}
