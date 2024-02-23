//  ShopMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'forgot_password_page.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/register_page.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_user.dart';

class LoginPage extends NyStatefulWidget {
  static const path = "/login";
  final bool showBackButton;
  LoginPage({this.showBackButton = true})
      : super(path, child: _LoginPageState());
}

class _LoginPageState extends NyState<LoginPage> {
  final TextEditingController _tfEmailController = TextEditingController(),
      _tfPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  StoreLogo(height: 100),
                  Flexible(
                    child: Container(
                      height: 70,
                      padding: EdgeInsets.only(bottom: 20),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        trans("Login"),
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow:
                          (Theme.of(context).brightness == Brightness.light)
                              ? wsBoxShadow()
                              : null,
                      color: ThemeColor.get(context).backgroundContainer,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TextEditingRow(
                          heading: trans("Email"),
                          controller: _tfEmailController,
                          keyboardType: TextInputType.emailAddress,
                          dummyData: "",
                        ),
                        TextEditingRow(
                          heading: trans("Password"),
                          controller: _tfPasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          dummyData: "",
                        ),
                        PrimaryButton(
                          title: trans("Login"),
                          isLoading: isLocked('login_button'),
                          action: _loginUser,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.account_circle,
                    color: (Theme.of(context).brightness == Brightness.light)
                        ? Colors.black38
                        : Colors.white70,
                  ),
                  Padding(
                    child: Text(
                      trans("Create an account"),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    padding: EdgeInsets.only(left: 8),
                  )
                ],
              ),
              onPressed: () => routeTo(RegisterPage.path),
            ),
            LinkButton(
                title: trans("Forgot Password"),
                action: () {
                  routeTo(ForgotPasswordPage.path);
                }),
            widget.showBackButton
                ? Column(
                    children: [
                      Divider(),
                      LinkButton(
                        title: trans("Back"),
                        action: pop,
                      ),
                    ],
                  )
                : Padding(
                    padding: EdgeInsets.only(bottom: 20),
                  )
          ],
        ),
      ),
    );
  }

  _loginUser() async {
    String email = _tfEmailController.text;
    String password = _tfPasswordController.text;
    if (email.isNotEmpty) {
      email = email.trim();
    }

    validate(
        rules: {
          "email": [email, "email"],
          "password": [password, "not_empty"],
        },
        onSuccess: () async {
          AuthCustomer? authCustomer = await appWooSignalShopify((api) =>
              api.authCustomerLogin(
                  email: email, password: password, loginUser: true));
          if (authCustomer == null) {
            return;
          }

          showToastNotification(context,
              title: trans("Hello"),
              description: trans("Welcome back"),
              style: ToastNotificationStyleType.SUCCESS,
              icon: Icons.account_circle);
          navigatorPush(context,
              routeName: UserAuth.instance.redirect, forgetLast: 1);
        },
        lockRelease: "login_button");
  }
}
