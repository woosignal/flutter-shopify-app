//  ShopMax
//
//  Created by Anthony Gordon.
//  2025, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/forms/login_form.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/app/events/login_event.dart';
import 'forgot_password_page.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/register_page.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_user.dart';

class LoginPage extends NyStatefulWidget {
  static RouteView path = ("/login", (_) => LoginPage());

  LoginPage({super.key}) : super(child: () => _LoginPageState());
}

class _LoginPageState extends NyPage<LoginPage> {
  bool get showBackButton => data(defaultValue: false) != false ? true : false;

  LoginForm form = LoginForm();

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            StoreLogo(height: 100),

            Container(
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow:
                (Theme.of(context).brightness == Brightness.light)
                    ? wsBoxShadow()
                    : null,
                color: ThemeColor.get(context).backgroundContainer,
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 8),
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: NyForm(form: form, footer: Button.primary(text: trans("Login"), submitForm: (form, (data) async {
                await _loginUser(data['email'], data['password']);
              })),),
            ),

            Expanded(child: Container()),

            TextButton(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
            showBackButton
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

  _loginUser(String email, String password) async {
    if (email.isNotEmpty) {
      email = email.trim();
    }

    AuthCustomer? authCustomer = await appWooSignalShopify((api) =>
        api.authCustomerLogin(
            email: email, password: password, loginUser: true));
    if (authCustomer == null) {
      showToastOops(description: 'Invalid email or password'.tr());
      return;
    }

    event<LoginEvent>(data: {'authCustomer': authCustomer});

    showToastNotification(context,
        title: trans("Hello"),
        description: trans("Welcome back"),
        style: ToastNotificationStyleType.success,
        icon: Icons.account_circle);
    navigatorPush(context,
        routeName: UserAuth.instance.redirect, forgetLast: 1);
  }
}
