//  ShopMax
//
//  Created by Anthony Gordon.
//  2025, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/app/forms/register_form.dart';
import '/app/events/login_event.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/safearea_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/auth/auth_user.dart';
import 'package:woosignal_shopify_api/models/response/woosignal_app.dart';

class RegisterPage extends NyStatefulWidget {
  static RouteView path = ("/register", (_) => RegisterPage());

  RegisterPage({super.key}) : super(child: () => _RegisterPageState());
}

class _RegisterPageState extends NyPage<RegisterPage> {
  RegisterForm form = RegisterForm();

  final WooSignalApp? _wooSignalApp = AppHelper.instance.shopifyAppConfig;

  @override
  Widget view(BuildContext context) {
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
        child: NyForm.list(
          form: form,
          children: [
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
    form.submit(onSuccess: (data) async {
      String email = data['email'],
          password = data['password'],
          firstName = data['first_name'];

      if (email.isNotEmpty) {
        email = email.trim();
      }

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
          style: ToastNotificationStyleType.success,
          icon: Icons.account_circle);

      navigatorPush(context,
          routeName: UserAuth.instance.redirect, forgetLast: 2);
    });
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
