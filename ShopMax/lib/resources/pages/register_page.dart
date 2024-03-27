//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/events/login_event.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_user.dart';
import 'package:woosignal_shopify_api/models/response/woosignal_app.dart';

class RegisterPage extends StatefulWidget {
  static const path = "/register";

  RegisterPage();

  @override
  createState() => _RegisterPageState();
}

class _RegisterPageState extends NyState<RegisterPage> {
  _RegisterPageState();

  final TextEditingController _tfEmailAddressController =
          TextEditingController(),
      _tfPasswordController = TextEditingController(),
      _tfFirstNameController = TextEditingController(),
      _tfLastNameController = TextEditingController();

  final WooSignalApp? _wooSignalApp = AppHelper.instance.shopifyAppConfig;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(trans("Register")),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeAreaWidget(
        child: Column(
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextEditingRow(
                        heading: trans("First Name"),
                        controller: _tfFirstNameController,
                        shouldAutoFocus: true,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    Flexible(
                      child: TextEditingRow(
                        heading: trans("Last Name"),
                        controller: _tfLastNameController,
                        shouldAutoFocus: false,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                )),
            TextEditingRow(
              heading: trans("Email address"),
              controller: _tfEmailAddressController,
              shouldAutoFocus: false,
              keyboardType: TextInputType.emailAddress,
            ),
            TextEditingRow(
              heading: trans("Password"),
              controller: _tfPasswordController,
              shouldAutoFocus: true,
              obscureText: true,
            ),
            Padding(
              child: PrimaryButton(
                title: trans("Sign up"),
                isLoading: isLocked('register_user'),
                action: _signUpTapped,
              ),
              padding: EdgeInsets.only(top: 10),
            ),
            Padding(
              child: InkWell(
                child: RichText(
                  text: TextSpan(
                    text:
                        '${trans("By tapping \"Register\" you agree to ")} ${AppHelper.instance.shopifyAppConfig?.appName!}\'s ',
                    children: <TextSpan>[
                      TextSpan(
                          text: trans("terms and conditions"),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '  ${trans("and")}  '),
                      TextSpan(
                          text: trans("privacy policy"),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                    style: TextStyle(
                        color:
                            (Theme.of(context).brightness == Brightness.light)
                                ? Colors.black45
                                : Colors.white70),
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: _viewTOSModal,
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ],
        ),
      ),
    );
  }

  _signUpTapped() async {
    String email = _tfEmailAddressController.text,
        password = _tfPasswordController.text,
        firstName = _tfFirstNameController.text,
        lastName = _tfLastNameController.text;

    if (email.isNotEmpty) {
      email = email.trim();
    }

    validate(
        rules: {
          "email": [
            email,
            "email",
            "${trans("Oops")}|${trans("That email address is not valid")}"
          ],
          "password": [password, "password_v1"],
          "first name": [firstName, "email"],
          "last name": [lastName, "email"],
        },
        onSuccess: () async {
          AuthCustomer? authCustomer =
              await appWooSignalShopify((api) => api.authCustomerRegister(
                    email: email,
                    password: password,
                    loginUser: true,
                  ));

          if (authCustomer == null) {
            showToastOops(
                description: "Please check your details and try again".tr());
            return;
          }

          event<LoginEvent>(data: {'authCustomer': authCustomer});

          showToastNotification(context,
              title: "${trans("Hello")} $firstName",
              description: trans("you're now logged in"),
              style: ToastNotificationStyleType.SUCCESS,
              icon: Icons.account_circle);

          navigatorPush(context,
              routeName: UserAuth.instance.redirect, forgetLast: 2);
        },
        lockRelease: "register_user");
  }

  _viewTOSModal() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(trans("Actions")),
        content: Text(trans("View Terms and Conditions or Privacy policy")),
        actions: <Widget>[
          MaterialButton(
            onPressed: _viewTermsConditions,
            child: Text(trans("Terms and Conditions")),
          ),
          MaterialButton(
            onPressed: _viewPrivacyPolicy,
            child: Text(trans("Privacy Policy")),
          ),
          Divider(),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewTermsConditions() {
    Navigator.pop(context);
    openBrowserTab(url: _wooSignalApp!.appTermsLink!);
  }

  void _viewPrivacyPolicy() {
    Navigator.pop(context);
    openBrowserTab(url: _wooSignalApp!.appPrivacyLink!);
  }
}
